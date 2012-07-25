//
//  PostShareToTwitter.h
//  ArcaMobileDeals
//
//  Created by Ricardo Silva on 7/1/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PostShareToTwitter : NSObject {

@private    
    NSString * pin;
    NSInteger promotionID;
    
}

- (id)initWithPin:(NSString *)tPin fromDeal:(NSInteger) tPromotionID;
-(void)share;

@property(nonatomic, retain) NSString * pin;
@property(nonatomic, assign) NSInteger promotionID;

@end
