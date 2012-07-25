//
//  ProfileContact.m
//  eDirectory
//
//  Created by Rafael Gustavo Gali on 13/10/10.
//  Copyright 2010 Arca Solutions. All rights reserved.
//

#import "FacebookProfileContact.h"

@implementation FacebookProfileContact

@synthesize profileID, userName, name, firstName, lastName, email, location, ip, facebookID, accessToken, expirationDate;

-(void)dealloc {
	[profileID      release];
	[userName       release];
	[name           release];
	[firstName      release];
	[lastName       release];
	[email          release];
	[location       release];
	[ip             release];
	[facebookID     release];
	[accessToken    release];
	[expirationDate release];
	[super          dealloc];
}

@end
