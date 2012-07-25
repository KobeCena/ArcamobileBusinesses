//
//  ProfileContact.m
//  eDirectory
//
//  Created by Rafael Gustavo Gali on 13/10/10.
//  Copyright 2010 Arca Solutions. All rights reserved.
//

#import "ProfileContact.h"

@implementation ProfileContact

@synthesize profileID, userName, name, firstName, lastName, email, location, ip;


-(void)dealloc {
	[profileID release];
	[userName  release];
	[name      release];
	[firstName release];
	[lastName  release];
	[email     release];
	[location  release];
	[ip        release];
	[super     dealloc];
}


@end
