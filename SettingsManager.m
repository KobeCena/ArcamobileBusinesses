//
//  SettingsMagnager.m
//  eDirectory
//
//  Created by Rafael Gustavo Gali on 07/10/10.
//  Copyright 2010 Arca Solutions. All rights reserved.
//

#import "SettingsManager.h"
#import "EdirectoryParserToWSSoapAdapter.h"
#import "ARCAserver_businesses.h"

@implementation SettingsManager

@synthesize socialNetworkEnabled, reviewListingEnabled, needLoginToListingReview, openIdEnabled, facebookEnabled, facebookApiKey, twitterApiKey, twitterApiSecret, defaultTagline;
@synthesize parserDidFinish, eDirectoryConnection, eDirectoryData, currentItem, promotionForceRedeemFacebook;
@synthesize twilioEnabled;

- (void)dealloc {
	[facebookApiKey   release];
	[twitterApiKey    release];
	[twitterApiSecret release];
	[currentItem      release];
	[eDirectoryData   release];
    [super            dealloc];
}


-(id) init 
{

	if (self == [super init] ) 
	{
		
		parserDidFinish = NO;

        /* OLD WAY - PHP REQUEST LIKE A REST WS
         *
         *		
		NSString *path = [[NSBundle mainBundle] pathForResource:@"ConnectionStrings" ofType:@"plist"];		
		NSDictionary *connPlist = [NSDictionary dictionaryWithContentsOfFile:path];
		NSString *url = [connPlist objectForKey:@"SettingsManager"];
		NSString* userAgent = @"Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en)";
		NSMutableURLRequest *eDirectoryURLRequest = [[[NSMutableURLRequest alloc] init] autorelease];
		[eDirectoryURLRequest setURL: [NSURL URLWithString:url]];
		[eDirectoryURLRequest setValue:userAgent forHTTPHeaderField:@"User-Agent"];
		eDirectoryConnection = [[[NSURLConnection alloc] initWithRequest:eDirectoryURLRequest delegate:self] autorelease];  
         */
        
        
        
        
        /** WS-SOAP WAY **/
        EdirectoryParserToWSSoapAdapter *adapter = [EdirectoryParserToWSSoapAdapter sharedInstance];
        ARCAserver_businesses * service = [ARCAserver_businesses service];
        [service setHeaders: [adapter getDomainToken] ];
        [service loadSettings:self action:@selector(loadSettingsHandler:)];
        
        
		while (![self parserDidFinish] && [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
		
	}
    
	

    

    
	return self;
}

-(id) initWithNoWhait
{
	
	if (self == [super init] ) 
	{
		
        
        /** WS-SOAP WAY **/
        
        EdirectoryParserToWSSoapAdapter *adapter = [EdirectoryParserToWSSoapAdapter sharedInstance];
        ARCAserver_businesses * service = [ARCAserver_businesses service];
        [service setHeaders: [adapter getDomainToken] ];
        [service setLogging:NO];
        [service loadSettings:self action:@selector(loadSettingsHandler:)];            
        
        /* OLD WAY - PHP REQUEST LIKE A REST WS
         *
         *        
		NSString *path = [[NSBundle mainBundle] pathForResource:@"ConnectionStrings" ofType:@"plist"];		
		NSDictionary *connPlist = [NSDictionary dictionaryWithContentsOfFile:path];
		NSString *url = [connPlist objectForKey:@"SettingsManager"];
        NSLog(@" Settings manager URL --> %@", url);
		NSString* userAgent = @"Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en)";
		NSMutableURLRequest *eDirectoryURLRequest = [[[NSMutableURLRequest alloc] init] autorelease];
		[eDirectoryURLRequest setURL: [NSURL URLWithString:url]];
		[eDirectoryURLRequest setValue:userAgent forHTTPHeaderField:@"User-Agent"];
		eDirectoryConnection = [[[NSURLConnection alloc] initWithRequest:eDirectoryURLRequest delegate:self] autorelease];
         */
		
	}
	
	return self;
}

/** WS-SOAP WAY **/
- (void) loadSettingsHandler: (id) value {
    
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
        NSLog(@"There's an error %@", value);
		return;
	}
    
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"There's an error %@", value);
		return;
	}
    
    
	// Do something with the ARCASettings* result
    ARCASettings* arcaSettings = (ARCASettings*)value;
	NSLog(@"loadSettings returned the value: %@", arcaSettings);
    
    [self setSocialNetworkEnabled:[[arcaSettings socialnetwork_enabled] boolValue]];
    [self setReviewListingEnabled:[[arcaSettings review_listing_enabled] boolValue]];
    [self setNeedLoginToListingReview:[[arcaSettings need_login_to_listing_review] boolValue]];
    [self setOpenIdEnabled:[[arcaSettings openid_enabled] boolValue]];
    [self setFacebookEnabled:[[arcaSettings facebook_enabled] boolValue]];
    [self setFacebookApiKey: [arcaSettings facebook_apikey] ];
    [self setTwitterApiKey:[arcaSettings twitter_apikey]];
    [self setTwitterApiSecret:[arcaSettings twitter_apisecret]];
    [self setPromotionForceRedeemFacebook:[[arcaSettings promotion_force_redeem_by_facebook] boolValue]];
    [self setDefaultTagline:[arcaSettings default_tagline]];
    [self setTwilioEnabled: [[arcaSettings twilioEnabled] boolValue]];
    
    
    parserDidFinish = YES;
    
}


/* OLD WAY - PHP REQUEST LIKE A REST WS
 *
 *
//PARSER DELEGATE
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	currentItem = elementName;
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	currentItem = nil;
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	//NSLog(@"foundChacacters: %@: %@", currentItem, string);
	
	if ([currentItem isEqualToString:@"socialnetwork_enabled"]) {
		socialNetworkEnabled = [string boolValue];
	} else if ([currentItem isEqualToString:@"review_listing_enabled"]) {
		reviewListingEnabled = [string boolValue];
	} else if ([currentItem isEqualToString:@"need_login_to_listing_review"]) {
		needLoginToListingReview = [string boolValue];
	} else if ([currentItem isEqualToString:@"openid_enabled"]) {
		//openIdEnabled = [string boolValue];
		openIdEnabled = NO;
	} else if ([currentItem isEqualToString:@"facebook_enabled"]) {
		facebookEnabled = [string boolValue];
	} else if ([currentItem isEqualToString:@"facebook_apikey"]) {
		[self setFacebookApiKey:string];
	} else if ([currentItem isEqualToString:@"twitter_apikey"]) {
		[self setTwitterApiKey:string];
		//[self setTwitterApiKey:@"8QiREG6YNfoNEBbQBNm6kA"];
	} else if ([currentItem isEqualToString:@"twitter_apisecret"]) {
		[self setTwitterApiSecret:string];
		//[self setTwitterApiSecret:@"OtlUldFv28T0QDCBlj3Kq0mxpwvVIX1elmJUIutbg"];
	} else if ([currentItem isEqualToString:@"promotion_force_redeem_by_facebook"]) {
		promotionForceRedeemFacebook = [string boolValue];
	} else if ([currentItem isEqualToString:@"default_tagline"]){
        [self setDefaultTagline:string];
    }
	
}
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"There's an error %@", parseError);
}

- (void)parserDidEndDocument:(NSXMLParser *)parser{
	
	NSLog(@"socialNetworkEnabled: %d", socialNetworkEnabled);
	NSLog(@"reviewListingEnabled: %d bool: %@", reviewListingEnabled, (reviewListingEnabled) ? @"yes" : @"no");
	NSLog(@"needLoginToListingReview: %d", needLoginToListingReview);
	NSLog(@"openIdEnabled: %d", openIdEnabled);
	NSLog(@"facebookEnabled: %d", facebookEnabled);
	NSLog(@"facebookApiKey: %@", facebookApiKey);
	NSLog(@"twitterApiKey: %@", twitterApiKey);
	NSLog(@"twitterApiSecret: %@", twitterApiSecret);
    NSLog(@"default_tagline: %@", defaultTagline);
	parserDidFinish = YES;

}

- (void)parserDidEndParsingData:(NSArray *)objectResults{
    NSLog(@"parserDidEndParsingData with %i results", [objectResults count]);    
}

//XML
#pragma mark NSURLConnection delegate methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.eDirectoryData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.eDirectoryData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
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
}
 */

//*/=*/=*/=*/=*/=*/=*/=*/=*/=*/=



@end
