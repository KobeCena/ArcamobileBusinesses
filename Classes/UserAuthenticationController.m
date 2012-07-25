//
//  UserAuthenticationController.m
//  eDirectory
//
//  Created by Ricardo Silva on 3/25/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import "UserAuthenticationController.h"
#import "ProfileContact.h"
#import "ARCAserver_businesses.h"
#import "EdirectoryParserToWSSoapAdapter.h"
#import "ARCAStandardReturn.h"


@interface UserAuthenticationController()
-(void)postNotificationAboutSuccessfulInAuthentication;
-(void)postNotificationAboutFailurelInAuthentication;
@end


@implementation UserAuthenticationController


@synthesize profile, userPassword, eDirectoryConnection, eDirectoryData, currentItem, authMessage;

/*
- (id)initWithCredentials:(ProfileContact *)profileData usingPassword:(NSString *) password{
    self = [super init];
    if (self) {
        // Custom initialization
        self.profile = profileData;
        userPassword = password;
    }
    return self;
}
*/
- (void)dealloc
{
    [profile                release];
    [userPassword           release];
    [eDirectoryData         release];
    [currentItem            release];
    [authMessage            release];
    [super                  dealloc];
}


- (void)handleError:(NSString *)errorMessage {

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Downloading Error", @"Title for alert displayed when download or parse error occurs.") message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}


#pragma mark -
#pragma mark Authentication Method
-(void)startAuthenticationPhaseWithCredentials:(ProfileContact *)profileData usingPassword:(NSString *) password{

    self.profile = profileData;
    
    
    /** WS_SOAP WAY **/
    ARCAserver_businesses* service = [ARCAserver_businesses service];
    EdirectoryParserToWSSoapAdapter *adapter = [EdirectoryParserToWSSoapAdapter sharedInstance];
    [service setHeaders:[adapter getDomainToken]];
    service.logging = NO;
    
    [service loginWithProfile:self 
                       action:@selector(loginWithProfileHandler:) 
                     username:[self.profile userName] 
                     password:password];
    
    
    
    /* OLD WAY - PHP REQUEST LIKE A REST WS
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ConnectionStrings" ofType:@"plist"];		
	NSDictionary *connPlist = [NSDictionary dictionaryWithContentsOfFile:path];
	NSString *url = [connPlist objectForKey:@"Login"];
	
	NSString* userAgent = @"Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en)";
	NSString *post = [NSString stringWithFormat:@"username=%@&password=%@", [profile userName], password ];
    
    
    NSLog(@"URL: %@ - post: %@", url, post);
    NSLog(@"profile Data: %@ - profile: %@", [profileData userName], [profile userName]);
    
	NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat: @"%d", [postData length]];
    
	NSMutableURLRequest *eDirectoryURLRequest = [[[NSMutableURLRequest alloc] init] autorelease];	
    [eDirectoryURLRequest setURL: [NSURL URLWithString:url]];
	[eDirectoryURLRequest setHTTPMethod:@"POST"];
	[eDirectoryURLRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[eDirectoryURLRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"]; 
	[eDirectoryURLRequest setHTTPBody:postData];  
	[eDirectoryURLRequest setValue:userAgent forHTTPHeaderField:@"User-Agent"];
	eDirectoryConnection = [[[NSURLConnection alloc] initWithRequest:eDirectoryURLRequest delegate:self] autorelease];
     */

}

// Handle the response from loginWithProfile.
- (void) loginWithProfileHandler: (id) value {
    
        // Handle errors
        if([value isKindOfClass:[NSError class]]) {
            //locates the error message
            NSError* error = (NSError *)value;
            
            //show the error message to user
            [self handleError:[error localizedDescription]];
            
            //Post notification about failure
            [self postNotificationAboutFailurelInAuthentication];
            return;
        }
        
        // Handle faults
        if([value isKindOfClass:[SoapFault class]]) {
            //locates the error message
            SoapFault* fault = (SoapFault *)value;
            
            //show the error message to user
            [self handleError:[fault faultString]];
            
            //Post notification about failure
            [self postNotificationAboutFailurelInAuthentication];
            return;
        }				
        
        
        // Do something with the ARCAStandardReturn* result
        ARCAStandardReturn* result = (ARCAStandardReturn*)value;
        
        if (result.Status == NO)
        {

            //show the error message to user
            //[self handleError:[result Message]];
            self.authMessage = [result Message];
            
            //Post notification about failure
            [self postNotificationAboutFailurelInAuthentication];
            
        } else {
            //Post notification about success
            [self postNotificationAboutSuccessfulInAuthentication];            
            
        }    
    
}



#pragma mark Post messages to Notification Center
-(void)postNotificationAboutSuccessfulInAuthentication {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AUTHOK" object:self];
}

-(void)postNotificationAboutFailurelInAuthentication {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AUTHNOK" object:self];
}


/* OLD WAY - PHP REQUEST LIKE A REST WS
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
    self.eDirectoryConnection = nil;
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
	if (authenticateAccount == YES)
	{	
		[self postNotificationAboutSuccessfulInAuthentication];
		
	} else {
        [self postNotificationAboutFailurelInAuthentication];
	}				  
}


//PARSER DELEGATE
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	currentItem = elementName;
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	currentItem = nil;
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if ([currentItem isEqualToString:@"authenticateAccount"]) 
	{
		//if ([string isEqualToString:@"yes"]) {
		if ([string boolValue]) {
			authenticateAccount = YES;
		} else {
			authenticateAccount = NO;
		}
	} else if ([currentItem isEqualToString:@"authmessage"]) {
		//authMessage = string;
		[self setAuthMessage:string];
	} else if ([currentItem isEqualToString:@"id"]) {
		[profile setProfileID:[NSNumber numberWithInt:[string intValue]]] ;
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
	}
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
}

- (void)parserDidEndDocument:(NSXMLParser *)parser{
}

- (void)parserDidEndParsingData:(NSArray *)objectResults{
}
*/

@end
