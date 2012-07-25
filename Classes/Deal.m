//
//  Deal.m
//  ArcaMobileDeals
//
//  Created by Ricardo Silva on 5/11/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import "Deal.h"


@implementation Deal

@synthesize promotionID;
@synthesize promotionName;
@synthesize promotionRealValue;
@synthesize promotionDealValue;
@synthesize promotionDistance;
@synthesize promotionAmount;
@synthesize promotionDescription;
@synthesize promotionConditions;
@synthesize promotionDeals;
@synthesize promotionVisibilityStart;
@synthesize promotionVisibilityEnd;
@synthesize promotionStart;
@synthesize promotionEnd;
@synthesize promotionFriendlyURL;
@synthesize dealTotalGrabbed;
@synthesize dealTos;
@synthesize grabbedDealStatus;
@synthesize redeemCode;
@synthesize image;



- (void)dealloc {
	[promotionFriendlyURL release];
	[promotionStart       release];
	[promotionEnd         release];
	[promotionName        release];
	[promotionDescription release];
	[promotionConditions  release];
    [dealTos              release];
    [grabbedDealStatus    release];
    [redeemCode           release];
    [image                release];
    [super dealloc];
}

@end

