/*
 ######################################################################
 #                                                                    #
 # Copyright 2005 Arca Solutions, Inc. All Rights Reserved.           #
 #                                                                    #
 # This file may not be redistributed in whole or part.               #
 # eDirectory is licensed on a per-domain basis.                      #
 #                                                                    #
 # ---------------- eDirectory IS NOT FREE SOFTWARE ----------------- #
 #                                                                    #
 # http://www.edirectory.com | http://www.edirectory.com/license.html #
 ######################################################################
 */

#import "EdirectoryXMLParser.h"
#import <CFNetwork/CFNetwork.h>
#import <Foundation/NSXMLParser.h>
#import "RpCacheController.h"

#import "objc/runtime.h"

static const char* getPropertyType(objc_property_t property) {
    // parse the property attribues. this is a comma delimited string. the type of the attribute starts with the
    // character 'T' should really just use strsep for this, using a C99 variable sized array.
    const char *attributes = property_getAttributes(property);
	char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer;
	char *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && strlen(attribute)>2) {
            // return a pointer scoped to the autorelease pool. Under GC, this will be a separate block.
            return (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute)-4] bytes];
        }else if (attribute[0] == 'T' && strlen(attribute)==2) {
			return (const char *)[[NSData dataWithBytes:(attribute + 1) length:strlen(attribute)] bytes];
		}
    }
    return "@";
}

@implementation EdirectoryXMLParser

@synthesize currentObject, currentObjectName, objectList, eDirectoryConnection, eDirectoryData, currentParsedCharacterData, currentParseBatch, delegate, maximumNumberOfObjectsToParse, setSelector, selector, dicPropertiesObject, lastUpdate, logEnabled;

@synthesize rootElementName;

- (void)dealloc {
    
    [self setDelegate:nil];
    [delegate release];    
    
	[selector release];
	[dicPropertiesObject release];
	[setSelector release];
	[currentObject release];
	[currentObjectName release];
	[objectList release];
    
    [eDirectoryConnection cancel];
	[eDirectoryConnection release];
    
	[eDirectoryData release];
	[currentParsedCharacterData release];
	[currentParseBatch release];
    [lastUpdate release];
    [super dealloc];
}

- (double) getSearchResultsLatitude{
	return searchResultsLatitude;
}
- (double) getSearchResultsLongitude{
	return searchResultsLongitude;
}

- (EdirectoryXMLParser *) initXMLParserDelegate{
	[super init];
	//Sets the default value to limit the number of parsed listings.
	[self setMaximumNumberOfObjectsToParse:20];
	entry = NO;
	return self;
    
    dicPropertiesObject = [[NSMutableDictionary alloc] init];    
}


- (void)loadObjectsDataFromDisk:(NSString *)fileName{
	// Initialize the array of listings and pass a reference to that list to the delegate.
    self.objectList = [NSMutableArray array];
    
	//Tells the Delegate that the ResultsArray was created
	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parserDidCreatedResultsArray:)]) {
		[self.delegate parserDidCreatedResultsArray:self.objectList];
	}
    
    //NSLog(@"[CACHE] Trying to get cache from %@.", fileName);
    
    
    self.eDirectoryData = [NSMutableData data];
    [self.eDirectoryData appendData:[RpCacheController getFileFromCache: fileName]];
    
    NSString * str = [[NSString alloc] initWithData:self.eDirectoryData encoding:NSStringEncodingConversionAllowLossy];
    NSLog(@"DISk XML %@", str);
    
    // Spawn a thread to fetch the eDirectory data so that the UI is not blocked while the application parses the XML data.
    //
    // IMPORTANT! - Don't access UIKit objects on secondary threads.
    //
    [NSThread detachNewThreadSelector:@selector(parseEDirectoryData:) toTarget:self withObject:eDirectoryData];
    
	// eDirectoryData will be retained by the thread until parseEDirectoryData: has finished executing, so we no longer need
    // a reference to it in the main thread.
    self.eDirectoryData = nil;
    
    
}

//This is the "Main Entry Point" method for this class when called from NearbyViewController.
- (void)loadObjectsData:(NSString *)parameters{
	// Initialize the array of listings and pass a reference to that list to the delegate.
    self.objectList = [NSMutableArray array];
	
	//Tells the Delegate that the ResultsArray was created
	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parserDidCreatedResultsArray:)]) {
		[self.delegate parserDidCreatedResultsArray:self.objectList];
	}
	
	//It's necessary set the userAgent for the url request
	NSString* userAgent = @"Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en)";
	NSMutableURLRequest *eDirectoryURLRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:parameters]];
	[eDirectoryURLRequest setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    self.eDirectoryConnection = [[[NSURLConnection alloc] initWithRequest:eDirectoryURLRequest delegate:self] autorelease];
	NSAssert(self.eDirectoryConnection != nil, @"Failure to create URL connection.");
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

#pragma mark NSURLConnection delegate methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.eDirectoryData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.eDirectoryData appendData:data];
//	[self.eDirectoryData writeToFile:@"/Users/ricardo/dataDownloaded.txt" atomically:NO]; 
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
//	NSLog(@"willCacheResponse!!!");
	//return cachedResponse;
	return nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    if ([error code] == kCFURLErrorNotConnectedToInternet) {
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"No Connection Error", @"Sorry! You need an internet connection to proceed with this action.") forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain code:kCFURLErrorNotConnectedToInternet userInfo:userInfo];
        [self handleError:noConnectionError];
    } else {
        // otherwise handle the error generically
        [self handleError:error];
    }
    self.eDirectoryConnection = nil;
    [self.eDirectoryConnection release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.eDirectoryConnection = nil;
    [self.eDirectoryConnection release];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    
    if ([self.delegate respondsToSelector:@selector(parserDidReceivedRawData:)]) {
        [self.delegate parserDidReceivedRawData:self.eDirectoryData];
    }
    
    // Spawn a thread to fetch the eDirectory data so that the UI is not blocked while the application parses the XML data.
    //
    // IMPORTANT! - Don't access UIKit objects on secondary threads.
    //
    [NSThread detachNewThreadSelector:@selector(parseEDirectoryData:) toTarget:self withObject:eDirectoryData];
    
	// eDirectoryData will be retained by the thread until parseEDirectoryData: has finished executing, so we no longer need
    // a reference to it in the main thread.
    self.eDirectoryData = nil;
}


- (void)parseEDirectoryData:(NSData *)data {
    // You must create a autorelease pool for all secondary threads.
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    self.currentParseBatch = [NSMutableArray array];
    self.currentParsedCharacterData = [NSMutableString string];
    //
    // It's also possible to have NSXMLParser download the data, by passing it a URL, but this is not desirable
    // because it gives less control over the network, particularly in responding to connection errors.
    //
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
	
	[parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
	
    [parser parse];
	
    // depending on the total number of Listings parsed, the last batch might not have been a "full" batch, and thus
    // not been part of the regular batch transfer. So, we check the count of the array and, if necessary, send it to the main thread.
    if ([self.currentParseBatch count] > 0) {
        [self performSelectorOnMainThread:@selector(addObjectsToList:) withObject:self.currentParseBatch waitUntilDone:YES];
    }
    self.currentParseBatch = nil;
    self.currentObject = nil;
	//self.dicPropertiesObject = nil;
    self.currentParsedCharacterData = nil;
	
    [parser release];        
    [pool release];
}


- (void)handleError:(NSError *)error {
	//Notifies the delegate about the error when downloading
	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parserEndWithError:)]) {
		[self.delegate parserEndWithError:YES];
	} else {
        NSString *errorMessage = [error localizedDescription];
        UIAlertView *alertView = [[UIAlertView alloc] 
                                  initWithTitle:NSLocalizedString(@"DownloadingError", nil) 
                                  message:errorMessage 
                                  delegate:nil 
                                  cancelButtonTitle:@"OK" 
                                  otherButtonTitles:nil
                                  ];
        [alertView show];
        [alertView release];
    }
}

- (void)addObjectsToList:(NSArray *)objects {
    [self.objectList addObjectsFromArray:objects];

	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parserDidUpdateData:)]) {
		[self.delegate parserDidUpdateData:self.objectList];
	} 
	if (searchResultsLatitude != 0  || searchResultsLongitude !=0 ) {
		if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parserDidReceiveSearchResultsPosition:withLongitude:)]) {
			[self.delegate parserDidReceiveSearchResultsPosition:searchResultsLatitude withLongitude:searchResultsLongitude];
		}	
	}
}

#pragma mark Parser constants

static NSUInteger const cSizeOfObjectsBatch = 1;

// These are the constants used for the Parser
static NSString * const cAmountObjectsOfDataElementName= @"amount";
static NSString * const cNumberOfPagesElementName= @"numberOfPages";
static NSString * const cActualPageElementName= @"actualPage";
static NSString * const cObjectDataElementName = @"ObjectData";
static NSString * const cEntryElementName = @"entry";
static NSString * const cLastUpdateElementName = @"lastUpdate";


static NSString * const cLocationInfoElementName = @"LocationInfo";
static NSString * const cLatitudeElementName = @"latitude";
static NSString * const cLongitudeElementName = @"longitude";


#pragma mark NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    // If the number of parsed earthquakes is greater than kMaximumNumberOfEarthquakesToParse, abort the parse.
    if (parsedObjectsCounter >= [self maximumNumberOfObjectsToParse]) {
        // Use the flag didAbortParsing to distinguish between this deliberate stop and other parser errors.
        didAbortParsing = YES;
        [parser abortParsing];
    }
    //NSLog(@"Element Name: %@", elementName);
    //NSLog(@"Root Element Name: %@", [self rootElementName]);
	if ([elementName isEqualToString: [self rootElementName] ]) {
		//Use the flag hasListingData to proceed or not with the parse
        NSString *relAttribute = [attributeDict valueForKey:cAmountObjectsOfDataElementName];
        //NSLog(@"relAttribute: %@", relAttribute);
		if ([relAttribute intValue]==0) {
			hasListingData = FALSE;
		}else {
			hasListingData = TRUE;
		}
		
		int numberOfPages = 0;
		int actualPage = 0;
        
        if ([attributeDict valueForKey:cLastUpdateElementName]) {            
			NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
			[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
			NSDate *aDate = [dateFormat dateFromString:[attributeDict valueForKey:cLastUpdateElementName]];  
            self.lastUpdate = aDate;
			[dateFormat release];         
        }
        
		
		if (([attributeDict valueForKey:cNumberOfPagesElementName] != nil) && ([attributeDict valueForKey:cActualPageElementName] != nil))  {
			NSScanner *scanner = [NSScanner scannerWithString:[attributeDict valueForKey:cNumberOfPagesElementName]];
			[scanner scanInteger:&numberOfPages];
			scanner = [NSScanner scannerWithString:[attributeDict valueForKey:cActualPageElementName]];
			[scanner scanInteger:&actualPage];
		}

		if (([attributeDict valueForKey:@"object"] != nil) && ([attributeDict valueForKey:@"object"] != nil))  {
			[self setCurrentObjectName: [attributeDict valueForKey:@"object"]];
		}
		
		if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parserDidReceivePagingNumbers:wichPage:)]) {
			[self.delegate parserDidReceivePagingNumbers:numberOfPages wichPage:actualPage];
		}
    }
	
	if ([elementName isEqualToString:cLocationInfoElementName]){
		searchResultsLatitude  = [[attributeDict valueForKey:cLatitudeElementName] doubleValue];
		searchResultsLongitude = [[attributeDict valueForKey:cLongitudeElementName] doubleValue];
		
		if (searchResultsLatitude > 0 ) {
			if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parserDidReceiveSearchResultsPosition:withLongitude:)]) {
				[self.delegate parserDidReceiveSearchResultsPosition:searchResultsLatitude withLongitude:searchResultsLongitude];
			}
		}
	}
	
	if(hasListingData){
		if ([elementName isEqualToString:cEntryElementName]) {
			entry = YES;
            accumulatingParsedCharacterData = YES;
            
            // The mutable string needs to be reset to empty.
            [currentParsedCharacterData setString:@""];
            
			Class myClass = NSClassFromString(currentObjectName);
			NSObject *myObject = [[myClass alloc] init];
            [self setCurrentObject:myObject];
			[myObject release];
            
            if (self.logEnabled) {
                NSLog(@"Dinamically creating the object %@ ",currentObjectName );
                NSLog(@"The clazz created is: %@ ",[myClass description] );                
                NSLog(@"The object created is: %@ ",[self.currentObject description] );
            }
            
			
			dicPropertiesObject = [[self propertDictionary:currentObject withSuperClassProperties:YES] copy];
            
            
		}

		if (entry == YES)
		{
			[self setSelector: elementName];
			NSString *capitalizedSentence = [elementName stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[elementName  substringToIndex:1] capitalizedString]];
			[self setSetSelector: [NSString stringWithFormat:@"set%@:" , capitalizedSentence]];
		}
	}
}


//Method to get property type and name of a given object
- (NSMutableDictionary *)propertDictionary:(NSObject *) objt withSuperClassProperties:(BOOL) getPropertiesFromSuperClass{
	unsigned int outCount, i;       
	NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:1]; 
    objc_property_t *properties = class_copyPropertyList([objt class], &outCount);
    for(i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
			const char *propType = getPropertyType(property);
			NSString *propertyName = [NSString stringWithCString:propName encoding:NSUTF8StringEncoding];
			NSString *propertyType = [NSString stringWithCString:propType encoding:NSUTF8StringEncoding];
			[dic setValue:propertyType forKey:propertyName];
        }
    }
    free(properties);
    
    //gets all properties from SuperClass
    if (getPropertiesFromSuperClass) {
        Class superClass = NSClassFromString([[objt superclass] description]);
        NSObject *superObject = [[superClass alloc] init];
        
        NSMutableDictionary * superDic = [[self propertDictionary:superObject withSuperClassProperties:NO] copy];
        
        for (id theKey in superDic) {
            [dic setValue:[superDic objectForKey:theKey] forKey:theKey];
        }
        
        [superDic release];
        [superObject release];
    }
    
	return dic;
}

-(NSDate *) convertString2Date:(id)pStrDate pFormat:(NSString *)pFormat {
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:pFormat];
	return [dateFormatter dateFromString:[NSString stringWithFormat:pStrDate]];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	//only proceeds with the parsing if there`s some data
	if(hasListingData) {
		if ([elementName isEqualToString:cEntryElementName]) {
			entry = NO;
			[self.currentParseBatch addObject:self.currentObject];
			parsedObjectsCounter++;
			if (parsedObjectsCounter % cSizeOfObjectsBatch == 0) {
				[self performSelectorOnMainThread:@selector(addObjectsToList:) withObject:self.currentParseBatch waitUntilDone:YES];
				self.currentParseBatch = [NSMutableArray array];
			}
		}
        
        if ([elementName isEqualToString:selector]) {
            NSString *prop = [dicPropertiesObject valueForKey:selector];
            
            
            
            
            NSString * tempStr = [currentParsedCharacterData stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [currentParsedCharacterData setString:@""];
            [currentParsedCharacterData setString: isEmpty(tempStr)?@"":tempStr];
            

            if ([self logEnabled]) {
                NSLog(@"Selector:::::::: %@", selector);
                NSLog(@"setSelector::::: %@", setSelector);
                NSLog(@"Property:::::::: %@", prop);
                NSLog(@"String:::::::::: %@", currentParsedCharacterData);
            }
            
            
            if ([prop isEqualToString:@"NSString"]) {
                NSString *aString = [NSString stringWithString:currentParsedCharacterData];
                [self invokeSignature:setSelector withClassName:currentObjectName withObject:currentObject withArgument:&aString];
            } else if ([prop isEqualToString:@"NSDate"]) { 
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                //[dateFormat setDateFormat:@"mm/dd/yyyy"];
                [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSDate *aDate = [dateFormat dateFromString:currentParsedCharacterData];  
                [dateFormat release];
				
                if (aDate == nil) {
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                    [dateFormat setDateFormat:@"yyyy-MM-dd"];
                    aDate = [dateFormat dateFromString:currentParsedCharacterData];
                    [dateFormat release];
                }
                
                [self invokeSignature:setSelector withClassName:currentObjectName withObject:currentObject withArgument:&aDate];
            } else if ([prop isEqualToString:@"NSNumber"]) { //NSNumber
                NSNumber *aNumber = [NSNumber numberWithDouble:[currentParsedCharacterData doubleValue]] ;
                [self invokeSignature:setSelector withClassName:currentObjectName withObject:currentObject withArgument:&aNumber];
            } else if ([prop isEqualToString:@"d"]) { //double
                double aDouble = [currentParsedCharacterData doubleValue];
                [self invokeSignature:setSelector withClassName:currentObjectName withObject:currentObject withArgument:&aDouble];
            } else if ([prop isEqualToString:@"f"]) { //float
                float aFloat = [currentParsedCharacterData floatValue];
                [self invokeSignature:setSelector withClassName:currentObjectName withObject:currentObject withArgument:&aFloat];
            } else if ([prop isEqualToString:@"i"]) { //integer
                NSInteger aInt = [currentParsedCharacterData intValue];
                [self invokeSignature:setSelector withClassName:currentObjectName withObject:currentObject withArgument:&aInt];
            } else if ([prop isEqualToString:@"c"]) { //boolean
                BOOL b = ([currentParsedCharacterData isEqualToString:@"yes"] || [currentParsedCharacterData isEqualToString:@"true"] || [currentParsedCharacterData isEqualToString:@"y"] || [currentParsedCharacterData isEqualToString:@"1"]);
                [self invokeSignature:setSelector withClassName:currentObjectName withObject:currentObject withArgument:&b];
            }

        }
        accumulatingParsedCharacterData = NO;
	}	
}



- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock{
    
	if (entry == YES) {
        // The mutable string needs to be reset to empty.
        [currentParsedCharacterData setString:@""];
		
        if (! isEmpty(CDATABlock)) {
            
            NSString *content = [NSString stringWithUTF8String:[CDATABlock bytes]];
            
            if (! isEmpty(content)) {
                [self.currentParsedCharacterData appendString:content];
            }
            
        }
	}
	
}

// This method is called by the parser when it find parsed character data ("PCDATA") in an element. The parser is not
// guaranteed to deliver all of the parsed character data for an element in a single invocation, so it is necessary to
// accumulate character data until the end of the element is reached.
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (entry == YES) {
		
        if (accumulatingParsedCharacterData) {
            [self.currentParsedCharacterData appendString:string];
        }
	}
}

-(void)invokeSignature:(NSString *)newSelector withClassName:(NSString *)newClassName withObject:(NSObject *)newObject withArgument:(void *)newArgumentLocation{
    
    NSLog(@"INvoking the clazz: %@", newClassName);
    NSLog(@"INvoking with objz: %@", [newObject description]);    
    
    
	NSMethodSignature * mySignature = [NSClassFromString(newClassName) instanceMethodSignatureForSelector:NSSelectorFromString(newSelector)];
	
    
    NSInvocation * myInvocation = [NSInvocation invocationWithMethodSignature:mySignature];
	
    [myInvocation setTarget:newObject];
	[myInvocation setSelector:NSSelectorFromString(newSelector)];
	[myInvocation setArgument:newArgumentLocation atIndex:2];
	[myInvocation invoke];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	//clean the counter to be able to process new data
	parsedObjectsCounter = 0;
    // If the number of listings records received is greater than cMaximumNumberOfListingsToParse, we abort parsing.
    // The parser will report this as an error, but we don't want to treat it as an error. The flag didAbortParsing is
    // how we distinguish real errors encountered by the parser.
    if (didAbortParsing == NO) {
        // Pass the error to the main thread for handling.
        [self performSelectorOnMainThread:@selector(handleError:) withObject:parseError waitUntilDone:NO];
    }else {
		parsedObjectsCounter = 0;
		
		if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parserDidEndParsingData:)]) {
			[self.delegate parserDidEndParsingData:self.objectList];
		}
	}
}


- (void)parserDidEndDocument:(NSXMLParser *)parser{
	//clean the counter to be able to process new data
	parsedObjectsCounter = 0;
	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parserDidEndParsingData:)]) {
		[self.delegate parserDidEndParsingData:self.objectList];

        self.currentParseBatch = nil;        
        
	}
	//Parser didn't find any results to process
	if (! hasListingData) {
		if (self.delegate != nil && [self.delegate respondsToSelector:@selector(noResultsWereFound)]) {
			[self.delegate noResultsWereFound];
		}	
	}
}

@end
