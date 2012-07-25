//
//  Review.m
//  eDirectory
//
//  Created by Rafael Gustavo Gali on 19/10/10.
//  Copyright 2010 Arca Solutions. All rights reserved.
//

#import "Review.h"


@implementation Review

@synthesize reviewID, item_id, member_id, added, ip, title, review, reviewerName, reviewerEmail, reviewerLocation, rate;


-(void)dealloc {
	[added            release];
	[ip               release];
	[title            release];
	[review           release];
	[reviewerName     release];
	[reviewerEmail    release];
	[reviewerLocation release];
	[super            dealloc];
}

@end
