//
//  FacebookLogin.m
//  eDirectory
//
//  Created by Rafael Gustavo Gali on 04/10/10.
//  Copyright 2010 Arca Solutions. All rights reserved.
//

#import "FacebookLogin.h"
#import "FBConnect.h"

static NSString* kAppId = nil;

@implementation FacebookLogin

@synthesize delegate, facebookProfile, login;

-(id)initWithAuthorize
{
	if (self = [super init] ) 
	{
		//_permissions =  [[NSArray arrayWithObjects: @"read_stream", @"offline_access",nil] retain];	
		//_permissions =  [[NSArray arrayWithObjects: nil] retain];
		_permissions = [[NSArray arrayWithObjects: @"offline_access",@"user_about_me",@"email" , @"publish_stream", @"share_item", nil] retain];
		_facebook = [[Facebook alloc] init];
		[_facebook authorize:kAppId permissions:_permissions delegate:self];
		facebookProfile = [[FacebookProfileContact alloc] init];
		
	}
	return self;
}

-(id)init
{
	if (self = [super init] ) 
	{
		_facebook = [[Facebook alloc] init];
	}
	return self;
}

-(void)logout
{
	[_facebook logout:self];
}

- (void)dealloc {
	[_facebook release];
	[delegate release];
	[facebookProfile release];
    [super dealloc];
}

-(void) fbDidLogin {
	login = YES;
	[_facebook requestWithGraphPath:@"me" andDelegate:self];
	[[self delegate] facebookDidLogin];
}

- (void)fbDidNotLogin:(BOOL)cancelled {
	login = NO;
	[[self delegate] facebookDidNotLogin];
}

-(void) fbDidLogout {
	NSLog(@"Please log in");
}

// FBRequestDelegate
- (void)request:(FBRequest*)request didReceiveResponse:(NSURLResponse*)response{
	NSLog(@"received response");
};

- (void)request:(FBRequest*)request didFailWithError:(NSError*)error{
	NSLog(@"error");
};

- (void)request:(FBRequest*)request didLoad:(id)result {
	/*
	//Getting keys and values of Dictionary
	NSLog(@"=====Dictionary FBRequest======");
	for (id key in result) {
        NSLog(@"key: %@, value: %@", key, [result objectForKey:key]);
    }
	NSLog(@"===============================");
	*/
	
	[facebookProfile setProfileID:      [NSNumber numberWithInt:0]];
	[facebookProfile setEmail:          [result objectForKey: @"email"]];
	//[facebookProfile setUserName:       [result objectForKey: @"name"]];

	NSString *userName = [NSString stringWithFormat:@"facebook::%@%@_%@", [result objectForKey: @"first_name"], [result objectForKey: @"last_name"], [result objectForKey: @"id"]];

	//[facebookProfile setUserName:       [[userName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString]];
	[facebookProfile setUserName:       [[userName stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString]];

	[facebookProfile setName:           [result objectForKey: @"name"]];
	[facebookProfile setFirstName:      [result objectForKey: @"first_name"]];
	[facebookProfile setLastName:       [result objectForKey: @"last_name"]];
	[facebookProfile setLocation:       [result objectForKey: @"locale"]];
	[facebookProfile setFacebookID:     [result objectForKey: @"id"]];
	[facebookProfile setAccessToken:    [_facebook accessToken]];
	[facebookProfile setExpirationDate: [_facebook expirationDate]];
	
	LoginData *loginData = [[LoginData alloc] init];
	[loginData setFacebookProfile:facebookProfile];
	[loginData saveFacebookProfileData];
	[loginData release];
	
	[[self delegate] facebookRequestReturn];
	
};

// FBDialogDelegate
- (void)dialogDidComplete:(FBDialog*)dialog{
	NSLog(@"publish successfully");
}

@end
