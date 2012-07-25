//
//  LoginData.m
//  eDirectory
//
//  Created by Rafael Gustavo Gali on 20/10/10.
//  Copyright 2010 Arca Solutions. All rights reserved.
//

#import "LoginData.h"

@implementation LoginData

@synthesize profile, facebookProfile, profileExist, facebookProfileExist;

-(void)dealloc {
	[profile         release];
	[facebookProfile release];
	[super           dealloc];
}

- (NSString *)dataFilePath:(NSString *)fileName;
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:fileName];
}

-(void)logoutProfile
{
	NSString *filePath = [self dataFilePath:kFilename];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
		[[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];		
}

-(void)logoutFacebookProfile
{
	NSString *filePath = [self dataFilePath:kFilenameFacebook];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
		[[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];		
}


-(id)init 
{
	NSString *filePath;
	
	profile = [[ProfileContact alloc] init];
	filePath = [self dataFilePath:kFilename];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
	{
		profileExist = YES;
		NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
		[profile setProfileID:      [array objectAtIndex: 0]];
		[profile setUserName:       [array objectAtIndex: 1]];
		[profile setName:           [array objectAtIndex: 2]];
		[profile setFirstName:      [array objectAtIndex: 3]];
		[profile setLastName:       [array objectAtIndex: 4]];
		[profile setEmail:          [array objectAtIndex: 5]];
		[profile setLocation:       [array objectAtIndex: 6]];
		[profile setIp:             [array objectAtIndex: 7]];
		[array release];
	} else 
		profileExist = NO;

	
	facebookProfile = [[FacebookProfileContact alloc] init];
	filePath = [self dataFilePath:kFilenameFacebook];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
	{
		facebookProfileExist = YES;
		NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
		[facebookProfile setProfileID:      [array objectAtIndex: 0]];
		[facebookProfile setUserName:       [array objectAtIndex: 1]];
		[facebookProfile setName:           [array objectAtIndex: 2]];
		[facebookProfile setFirstName:      [array objectAtIndex: 3]];
		[facebookProfile setLastName:       [array objectAtIndex: 4]];
		[facebookProfile setEmail:          [array objectAtIndex: 5]];
		[facebookProfile setLocation:       [array objectAtIndex: 6]];
		[facebookProfile setIp:             [array objectAtIndex: 7]];
		[facebookProfile setFacebookID:     [array objectAtIndex: 8]];
		[facebookProfile setAccessToken:    [array objectAtIndex: 9]];
		[facebookProfile setExpirationDate: [array objectAtIndex:10]];
		[array release];
	} else 
		facebookProfileExist = NO;
	
	return self;
}


-(void)saveProfileData
{
	NSMutableArray *array = [[NSMutableArray alloc] init];
	
	[array addObject:[profile profileID]];
	[array addObject:[profile userName]];
	[array addObject:[profile name]];
	[array addObject:([profile firstName]      != nil    )  ?  [profile firstName]      : @""                                     ];
	[array addObject:([profile lastName]       != nil    )  ?  [profile lastName]       : @""                                     ];
	[array addObject:[profile email]];
	[array addObject:[profile location]];
	[array addObject:([profile ip]             != nil    )  ?  [profile ip]             : @""                                     ];
	
	[array writeToFile:[self dataFilePath:kFilename] atomically:YES];
	
	[array release];
}

-(void)saveFacebookProfileData
{
	NSMutableArray *array = [[NSMutableArray alloc] init];
	
	[array addObject:[facebookProfile profileID]];
	[array addObject:[facebookProfile userName]];
	[array addObject:[facebookProfile name]];
	[array addObject:([facebookProfile firstName]      != nil    )  ?  [facebookProfile firstName]      : @""                                     ];
	[array addObject:([facebookProfile lastName]       != nil    )  ?  [facebookProfile lastName]       : @""                                     ];
	[array addObject:([facebookProfile email]          != nil    )  ?  [facebookProfile email]          : @""                                     ];
	[array addObject:[facebookProfile location]];
	[array addObject:([facebookProfile ip]             != nil    )  ?  [facebookProfile ip]             : @""                                     ];
	[array addObject:([facebookProfile facebookID]     != nil    )  ?  [facebookProfile facebookID]     : @""                                     ];
	[array addObject:([facebookProfile accessToken]    != nil    )  ?  [facebookProfile accessToken]    : @""                                     ];
	[array addObject:([facebookProfile expirationDate] != nil    )  ?  [facebookProfile expirationDate] : [NSDate dateWithTimeIntervalSince1970:0]];
	
	[array writeToFile:[self dataFilePath:kFilenameFacebook] atomically:YES];
	
	[array release];
}




@end
