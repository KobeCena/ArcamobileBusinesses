//
//  RpDashBoardButton.m
//  ArcaMobileDeals
//
//  Created by Ricardo Silva on 6/1/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import "RpDashBoardButton.h"


@implementation RpDashBoardButton

@synthesize badgeNumber = _badgeNumber;
@synthesize buttonIndex;
@synthesize buttonImageURL;

- (void)dealloc {
    [_badgeNumber release];
    [buttonIndex release];
    [buttonImageURL release];
    [super       dealloc];
}


+(id)buttonWithType:(UIButtonType)buttonType{

    return [super buttonWithType:buttonType];
    
}

@end
