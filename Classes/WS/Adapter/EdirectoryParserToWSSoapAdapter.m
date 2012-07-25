//
//  EdirectoryParserToWSSoapAdapter.m
//  ArcaMobileBusinesses
//
//  Created by Ricardo Silva on 8/24/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import "EdirectoryParserToWSSoapAdapter.h"
#import "CoreUtility.h"

#import "ARCAserver_businesses.h"
#import "SoapArray.h"
#import "ARCAResultsInfo.h"

#import "Utility.h"

#pragma mark Static Variables
static EdirectoryParserToWSSoapAdapter *sharedInstance = nil;


@interface EdirectoryParserToWSSoapAdapter ()

#pragma mark - private properties
@property(nonatomic, assign) ARCAserver_businesses * service;
@property(nonatomic, retain) SoapRequest * soapRequest;

#pragma mark - methods
-(void)initService;
#pragma mark - get a dictionary with DomainToken from a plistfile
-(NSDictionary *) getDomainToken;
    
@end


@implementation EdirectoryParserToWSSoapAdapter

@synthesize delegate;
@synthesize service;
@synthesize soapRequest;
@synthesize errorMessage;


#pragma mark -
#pragma mark Singleton Pattern Methods
+ (id) sharedInstance{
	
	//synchronized block
	@synchronized(self){
		if (!sharedInstance) {
			sharedInstance = [[super allocWithZone:NULL] init];
		}
	}
	
	return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [[self sharedInstance] retain];
}
- (id)copyWithZone:(NSZone *)zone {
    return self;
}
- (id)retain {
    return self;
}
- (unsigned)retainCount {
    return UINT_MAX; //denotes an object that cannot be released
}
- (oneway void)release{
    // never release
}
- (id)autorelease {
    return self;
}

-(void)initService{
    self.service = [ARCAserver_businesses service];
    self.service.logging = YES;
}

-(void)cancel{
    if (!isEmpty([self soapRequest])) {
        [soapRequest cancel];
    }
}

- (void)dealloc {
    [errorMessage release];
    [super dealloc];
}

#pragma mark - SoapDelegate Methods
- (void) onload: (id) value{
    
    
    
    //Testing the value returned from server against ARCAStandardReturn    
    if([value isKindOfClass:[ARCAStandardReturn class]]){
        if (! [(ARCAStandardReturn*)value Status] ) {
            //some problem hapened when post the review
            //hold the error message
            [self setErrorMessage: [(ARCAStandardReturn*)value Message] ];
            
            //Notifies the delegate about the error
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parserEndWithError:)]) {
                [self.delegate parserEndWithError:YES];
            }	    
            //notifies delegate that there's no results from server 
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(noResultsWereFound)]) {
                [self.delegate noResultsWereFound];
            }            
            
        }else{
            //notifies delegate that parser ends and pass along the results array
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parserDidEndParsingData:)]) {
                [self.delegate parserDidEndParsingData: (NSArray *)value ];
            }
        }
    }
    
    //Testing the value returned from server against SoapArray
    if ([value isKindOfClass: [SoapArray class] ]) {
        //verifies if there's data in the response
        int resultsAmount = [(SoapArray *)value count];
        
        if (resultsAmount == 0) {
            //notifies delegate that there's no results from server 
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(noResultsWereFound)]) {
                [self.delegate noResultsWereFound];
            }            
            
        }else{
            
            NSMutableArray *mutArray = [NSMutableArray array]; 
            
            /*
            ARCAArrayBusinesses * businessArray = (ARCAArrayBusinesses *)value;
            for (ARCABusinesses * businessObj in businessArray) {
                [mutArray addObject:businessObj];
            }
             */
            
            SoapArray * businessArray = (SoapArray *)value;
            for (SoapObject * businessObj in businessArray) {
                [mutArray addObject:businessObj];
            }
            
            NSArray *resultsArray = [NSArray arrayWithArray:mutArray];            
            
            id deserializeTo = [[ARCAResultsInfo alloc] autorelease];
            id output;
            
            //process the ARCAResultsInfo object from response
            NSError *error;
            CXMLDocument* doc = [[[CXMLDocument alloc] initWithData: self.soapRequest.receivedData options: 0 error: &error] autorelease];
            
            CXMLNode* element = [[Soap getNode: [doc rootElement] withName: @"Body"] childAtIndex:0];

            if([deserializeTo respondsToSelector: @selector(initWithNode:)]) {
                element = [element childAtIndex:1];
                output = [deserializeTo initWithNode: element];
            } else {
                NSString* value = [[[element childAtIndex:1] childAtIndex:0] stringValue];
                output = [Soap convert: value toType: deserializeTo];
            }
            
            
            //Testing the value returned from server against ARCAREsultsInfo
            if ( [output isKindOfClass: [ARCAResultsInfo class] ] ) {
                
                
                if (! isEmpty([(ARCAResultsInfo *) output AmountOfPages]) ){
                    
                    int numberOfPages = [[(ARCAResultsInfo *) output AmountOfPages] intValue];
                    int actualPage = [[(ARCAResultsInfo *) output ActualPage] intValue];
                    
                    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parserDidReceivePagingNumbers:wichPage:)]) {
                        [self.delegate parserDidReceivePagingNumbers:numberOfPages wichPage:actualPage];
                    }            
                }
                
                float latitude = [[(ARCAResultsInfo *) output BaseLatitude] floatValue];
                float longitude = [[(ARCAResultsInfo *) output BaseLongitude] floatValue];            
                
                if (latitude != 0  || longitude !=0 ) {
                    
                    //notifies delegate about geolocation values received from server
                    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parserDidReceiveSearchResultsPosition:withLongitude:)]) {
                        [self.delegate parserDidReceiveSearchResultsPosition: latitude withLongitude:longitude];
                    }	
                }
            }            
            
            //Notifies the Delegate that the ResultsArray was created
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parserDidCreatedResultsArray:)]) {
                [self.delegate parserDidCreatedResultsArray:resultsArray ];
            }
            
            //Notifies the delegate about data in results, so it can update Data
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parserDidUpdateData:)]) {
                [self.delegate parserDidUpdateData:resultsArray];
            } 
            
            
            //notifies delegate that parser ends and pass along the results array
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parserDidEndParsingData:)]) {
                [self.delegate parserDidEndParsingData: resultsArray  ];
            }
        }
    }
    
}

- (void) onerror: (NSError*) error{

	//Notifies the delegate about the error
	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parserEndWithError:)]) {
		[self.delegate parserEndWithError:YES];
	}	    
    
    //Tells the Delegate that the errors were received 
	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(noResultsWereFound)]) {
		[self.delegate noResultsWereFound];
	}
    
    
}

- (void) onfault: (SoapFault*) fault{
    
	//Notifies the delegate about the error
	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parserEndWithError:)]) {
		[self.delegate parserEndWithError:YES];
	}	    
    
    
    //Tells the Delegate that the errors were received 
	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(noResultsWereFound)]) {
		[self.delegate noResultsWereFound];
	}

}

#pragma mark - get a dictionary with DomainToken from a plistfile
-(NSDictionary *) getDomainToken{
    NSDictionary * dic = [CoreUtility getDictionaryFromPlistNamed:@"DomainToken"];
    NSMutableDictionary * dicR = [NSMutableDictionary dictionaryWithObject:dic forKey:@"DomainKeyDict"];
    
    NSDictionary * dicL = [NSDictionary dictionaryWithObject:[[NSLocale preferredLanguages] objectAtIndex:0] forKey:@"AppLanguage"];
    
    [dicR setValue:dicL forKey:@"AppLanguageDict"];
    
    return dicR;
}

#pragma mark - Adapter methods
- (void) getAllCategories{
    [self initService];
    [service setHeaders:[self getDomainToken]];
    
    self.service.logging = YES;
    [self setSoapRequest:[self.service getAllCategories:(self)]];
}

-(void) getAllBusinessForCategory:(NSDecimalNumber *)categoryID forPage:(int) pageNumber{
    [self initService];
    [service setHeaders:[self getDomainToken]];
    
    [self setSoapRequest: [service SearchBusinesses:self 
                                       typeOfSearch: [Utility getLocationSearchOptionsObject:pageNumber 
                                                                                       keyword:@"" 
                                                                                         order:0 
                                                                                    categoryId:[categoryID intValue] 
                                                                                       zipCode:@"" 
                                                                                      latitude:0 
                                                                                     longitude:0] ]];
    
}

-(void) getAllBusinessForKeyword: (NSString *)keyword orderBy:(NSDecimalNumber *)order_by categoryID:(NSDecimalNumber *)categoryID latitude: (float)latitude longitude: (float)longitude page: (NSDecimalNumber*) page nearbyType:(NSString *)nearbyType zipcode:(NSString *)zipcode {
    
    [self initService];
    [service setHeaders:[self getDomainToken]];
//    
//    [self setSoapRequest: [service SearchBusinesses:self typeOfSearch: [Utility getLocationSearchOptionsObject:[page intValue] 
//                                                                                                       keyword:keyword 
//                                                                                                         order:[order_by intValue] 
//                                                                                                    categoryId:[categoryID intValue] 
//                                                                                                       zipCode:zipcode 
//                                                                                                      latitude:latitude 
//                                                                                                     longitude:longitude] ]];
//    
//    
    
    
    [self setSoapRequest:[service getAllBusinessForKeyword:self keyword:keyword orderBy:order_by categoryID:categoryID latitude:latitude longitude:longitude distanceUnit:@"mile" page:page nearbyType:nearbyType zipcode:zipcode]];
    
}

-(void) getAllNearbyBusiness:(NSString *) keyword nearbyType:(NSString *)nearbyType zipCode:(NSString *)zipcode nearbyRange:(int)nearbyRange latitude:(float)latitude longitude:(float)longitude page:(int)page {
    
    [self initService];    
    
    [service setHeaders:[self getDomainToken]];

    [self setSoapRequest: [service SearchBusinesses:self typeOfSearch: [Utility getLocationSearchOptionsObject:page 
                                                                                                       keyword:keyword 
                                                                                                         order:0 
                                                                                                    categoryId:0 
                                                                                                       zipCode:zipcode 
                                                                                                      latitude:latitude 
                                                                                                     longitude:longitude] ]];
    
}


- (void) postReview:(NSString *) moduleName itemID: (NSDecimalNumber *) itemID userName:(NSString *) userName rateValue:(NSDecimalNumber *) rateValue shareInFacebook:(BOOL)shareInFacebook shareInTwitter:(BOOL)shareInTwitter twitter_oauth_token:(NSString *) twitter_oauth_token twitter_oauth_secret: (NSString *) twitter_oauth_secret shareInEmail:(NSString *)shareInEmail reviewText:(NSString *) reviewText reviewImage:(NSData *)reviewImage imagetype:(NSString *)imagetype foursquare_id: (NSString *) foursquare_id {
    
    [self initService];
    
    [service setHeaders:[self getDomainToken]];
    
    [self setSoapRequest:[service postReview:self module:moduleName itemID:itemID username:userName rateValue:rateValue shareInFacebook:shareInFacebook shareInTwitter:shareInTwitter twitter_oauth_token:twitter_oauth_token twitter_oauth_secret:twitter_oauth_secret shareInEmail:shareInEmail reviewText:reviewText reviewImage:reviewImage imagetype:imagetype foursquare_id:foursquare_id]];
    
}

- (void)getAllCountries{
    [self initService];
    [self.service setHeaders:[self getDomainToken]];
    self.service.logging = YES;
    
    [self setSoapRequest:[service getAllCountries:self]];    
}

- (void) getStatesForCountry:(NSDecimalNumber *)countryID{
    [self initService];
    [self.service setHeaders:[self getDomainToken]];
    self.service.logging = YES;
    
    [self setSoapRequest:[service getStatesForCountry:self countryID:countryID]];
}

- (void) getCitiesForState:(NSDecimalNumber *)stateID andLetter:(NSString *) letter{
    [self initService];
    [self.service setHeaders:[self getDomainToken]];
    self.service.logging = YES;

    [self setSoapRequest:[service getCitiesForState:self stateID:stateID letter:letter]];
}


- (void)getReviews:(NSString *) username businessID:(NSDecimalNumber *) businessID foursquare_id: (NSString *) foursquare_id module: (NSString *) module page: (NSDecimalNumber *)page{
    
    [self initService];
    [self.service setHeaders:[self getDomainToken]];
    
    self.service.logging = YES;
    
    [self setSoapRequest: [service getReviews:self 
                                     userName:username 
                                   businessID:businessID
                                 foursquare_id: foursquare_id module:module page:page] ];
    
}



@end
