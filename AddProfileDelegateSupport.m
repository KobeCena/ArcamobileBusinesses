//
//  AddProfileDelegateSupport.m
//  ArcaMobileDeals
//
//  Created by Ricardo Silva on 6/13/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import "AddProfileDelegateSupport.h"
#import "LoginData.h"
#import "ARCAserver_businesses.h"
#import "EdirectoryParserToWSSoapAdapter.h"
#import "ARCAStandardReturn.h"

@implementation AddProfileDelegateSupport

@synthesize currentItem;
@synthesize authMessage;
@synthesize dic;
@synthesize profile;
@synthesize eDirectoryData;
@synthesize delegate;
@synthesize userInfoDict;


- (id)init {
    self = [super init];
    if (self) {
        profile = [[ProfileContact alloc] init];
        dic = [[NSMutableDictionary alloc] init];

    }
    return self;
}

- (void)dealloc {
    [currentItem    release];
    [authMessage    release];
    [dic            release];
    [profile        release];
    [eDirectoryData release];
    [userInfoDict   release];
    
    [super dealloc];
}

- (void)handleError{
	
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle:nil
                          message: [self authMessage]
                          delegate:nil 
                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}



/** WS-SOAP WAY **/
-(void)createUserProfileWithData:(NSDictionary *)userInfoDic{

    
    ARCAserver_businesses* service = [ARCAserver_businesses service];
    EdirectoryParserToWSSoapAdapter *adapter = [EdirectoryParserToWSSoapAdapter sharedInstance];
    [service setHeaders:[adapter getDomainToken]];
    service.logging = YES;
 
    
    //since the WS_SOAP doesn't return the user profile, we need to create a "fake" one
    [self.profile setProfileID:[NSNumber numberWithInt:1]];
    [self.profile setUserName: [userInfoDic objectForKey:@"USERNAME"] ];
    [self.profile setName:[userInfoDic objectForKey:@"EMAIL"]];
    [self.profile setFirstName:[userInfoDic objectForKey:@"USERNAME"]];
    [self.profile setEmail:[userInfoDic objectForKey:@"EMAIL"]];
    [self.profile setLocation:@"LOCATION"];
    
    [service createNewProfile:self 
                       action:@selector(createNewProfileHandler:) 
                    loginName:[userInfoDic objectForKey:@"USERNAME"] 
                     password:[userInfoDic objectForKey:@"PASSWORD"] 
              retypedPassword:[userInfoDic objectForKey:@"RETYPEDPASSWORD"] 
              defaultLanguage:[userInfoDic objectForKey:@"DEFAULTLANGUAGE"] 
                     userName:[userInfoDic objectForKey:@"EMAIL"] 
                        email:[userInfoDic objectForKey:@"EMAIL"]];
    
}

// Handle the response from createNewProfile.
- (void) createNewProfileHandler: (id) value {

	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
        //locates the error message
        NSError* error = (NSError *)value;
        [self setAuthMessage: [error localizedDescription] ];
        
        //show the error message to user
        [self handleError];
        
        [[self delegate] addProfileDidNotLogin];        
		return;
	}
    
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
        //locates the error message
        SoapFault* fault = (SoapFault *)value;
        [self setAuthMessage: [fault faultString] ];
        
        //show the error message to user
        [self handleError];

        [[self delegate] addProfileDidNotLogin];        
		return;
	}				
    
    
	// Do something with the ARCAStandardReturn* result
    ARCAStandardReturn* result = (ARCAStandardReturn*)value;
    
	if (result.Status == NO)
	{
        //locate the error message from server
        [self setAuthMessage: [result Message] ];
        //show the error message to user
        [self handleError];
        
        //call delegate
		[[self delegate] addProfileDidNotLogin];
        
	} else {
		//the new user profile was successfull created in server
		LoginData *login = [[LoginData alloc] init];
		[login setProfile:profile];
		[login saveProfileData];
		[login release];
		
		[[self delegate] addProfileDidLogin];
		
	}    
    
}


/** OLD WAY - PHP REQUEST LIKE A REST WS
 
#pragma mark NSURLConnection delegate methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.eDirectoryData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.eDirectoryData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
	if ([error code] == kCFURLErrorNotConnectedToInternet) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"No Connection Error", @"Sorry! You need an internet connection to proceed with this action.") forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain code:kCFURLErrorNotConnectedToInternet userInfo:userInfo];
        [self handleError:noConnectionError];
    } else {
        [self handleError:error];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData: eDirectoryData];
	[parser setDelegate:self];
	[parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
	[parser release];
	self.eDirectoryData = nil;
    
	if (validate == NO)
	{
        
		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle:nil
							  message: [self authMessage]
							  delegate:nil 
							  cancelButtonTitle:NSLocalizedString(@"OK", @"")
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
        
        
		[[self delegate] addProfileDidNotLogin];
        
	} else {
		
		LoginData *login = [[LoginData alloc] init];
		[login setProfile:profile];
		[login saveProfileData];
		[login release];
		
		[[self delegate] addProfileDidLogin];
		
	}
    
}


//PARSER DELEGATE
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	currentItem = elementName;
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	currentItem = nil;
//	if (isLanguageParser && [elementName isEqualToString:@"entry_language"]) 
//	{
//		NSLog(@"languageName: %@", languageName);
//		NSLog(@"languageID: %@", languageID);
//		[dic setObject:languageName forKey:languageID];
//	}
	
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
	if ([currentItem isEqualToString:@"message"]) 
	{
		//authMessage = string;
		[self setAuthMessage:string];
	} else if ([currentItem isEqualToString:@"validate"]) {
        validate = [string boolValue] ? YES : NO ;
	} else if ([currentItem isEqualToString:@"authmessage"]) {
		[self setAuthMessage:string];
		//authMessage = string;
	} else if ([currentItem isEqualToString:@"id"]) {
		[profile setProfileID:[NSNumber numberWithInt:[string intValue]]];
	} else if ([currentItem isEqualToString:@"username"]) {
		[profile setUserName:string];
	} else if ([currentItem isEqualToString:@"name"]) {
		[profile setName:string];
	} else if ([currentItem isEqualToString:@"first_name"]) {
		[profile setFirstName:string];
	} else if ([currentItem isEqualToString:@"last_name"]) {
		[profile setLastName:string];
	} else if ([currentItem isEqualToString:@"email"]) {
		[profile setEmail:string];
	} else if ([currentItem isEqualToString:@"location"]) {
		[profile setLocation:string];
	} else if ([currentItem isEqualToString:@"ip"]) {
		[profile setIp:string];
	} else if ([currentItem isEqualToString:@"language_id"]) {
		//[self setLanguageID:string];
	} else if ([currentItem isEqualToString:@"language_name"]) {
		//[self setLanguageName:string];
	}
	
}
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSLog(@"parserErrorOcurred");
}

- (void)parserDidEndDocument:(NSXMLParser *)parser{
	//NSLog(@"didEndDocument: isLanguageParser: %@", isLanguageParser);
	
//	if (isLanguageParser == YES) {
//		[pickerLocation reloadComponent:0];
//	}
	
}

- (void)parserDidEndParsingData:(NSArray *)objectResults{
}
*/

@end
