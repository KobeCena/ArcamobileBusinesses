//
//  Deal.h
//  ArcaMobileDeals
//
//  Created by Ricardo Silva on 5/11/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Listing.h"


@interface Deal : Listing {
    
	NSInteger               promotionID;
	NSString               *promotionName;
	double                  promotionRealValue;
	double                  promotionDealValue;
    double                  promotionDistance;    
	NSInteger               promotionAmount;
	NSString               *promotionDescription;
	NSString               *promotionConditions;
	NSInteger               promotionDeals;	
	NSInteger               promotionVisibilityStart;
	NSInteger               promotionVisibilityEnd;
    NSInteger               dealTotalGrabbed;
	NSDate                 *promotionStart;
	NSDate                 *promotionEnd;
	NSString               *promotionFriendlyURL;
    NSString               *dealTos;
    NSString               *grabbedDealStatus;
    NSString               *redeemCode;
    UIImage                *dealImage;
}

@property (nonatomic, assign) NSInteger  promotionID;
@property (nonatomic, retain) NSString  *promotionName;
@property (nonatomic, assign) double     promotionRealValue;
@property (nonatomic, assign) double     promotionDealValue;
@property (nonatomic, assign) double     promotionDistance;
@property (nonatomic, assign) NSInteger  promotionAmount;
@property (nonatomic, retain) NSString  *promotionDescription;
@property (nonatomic, retain) NSString  *promotionConditions;
@property (nonatomic, assign) NSInteger  promotionDeals;
@property (nonatomic, assign) NSInteger  promotionVisibilityStart;
@property (nonatomic, assign) NSInteger  promotionVisibilityEnd;
@property (nonatomic, assign) NSInteger  dealTotalGrabbed;
@property (nonatomic, retain) NSDate    *promotionStart;
@property (nonatomic, retain) NSDate    *promotionEnd;
@property (nonatomic, retain) NSString  *promotionFriendlyURL;
@property (nonatomic, retain) NSString  *dealTos;
@property (nonatomic, retain) NSString  *grabbedDealStatus;
@property (nonatomic, retain) NSString  *redeemCode;
@property (nonatomic, retain) UIImage   *image;


@end
