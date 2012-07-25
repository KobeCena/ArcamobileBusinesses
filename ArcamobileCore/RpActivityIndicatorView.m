//
//  RpActivityIndicatorView.m
//  ArcaMobileDeals
//
//  Created by Ricardo Silva on 6/29/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import "RpActivityIndicatorView.h"


@implementation RpActivityIndicatorView

@synthesize activityIndex;

- (void)dealloc {
    [activityIndex release];
    [super dealloc];
}

@end
