//
//  PostShareToFacebook.h
//  ArcaMobileDeals
//
//  Created by Ricardo Silva on 7/1/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PostShareToFacebook : NSObject {
 
@private    
    NSString * authToken;
    NSInteger promotionID;
	NSString *profileID;    
    
}

- (id)initWithToken:(NSString *)token fromDeal:(NSInteger) promoID whithProfileID:(NSString *)authID;
- (void)share;

@property(nonatomic, retain) NSString * authToken;
@property(nonatomic, assign) NSInteger promotionID;
@property(nonatomic, retain) NSString *profileID;


@end
