//
//  AddProfileDelegateSupport.h
//  ArcaMobileDeals
//
//  Created by Ricardo Silva on 6/13/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProfileContact.h"

@protocol addProfileDelegateSupport;

@interface AddProfileDelegateSupport : NSObject<NSXMLParserDelegate> {
    
	id<addProfileDelegateSupport>    delegate;
	NSString                        *currentItem;    
    NSMutableDictionary             *dic;
    NSString                        *authMessage;
    BOOL                            validate;
    ProfileContact                  *profile;
    NSMutableData                   *eDirectoryData;
    NSDictionary                    *userInfoDict;
    
}

@property(nonatomic,retain) NSString                        *currentItem;
@property(nonatomic,retain) NSMutableDictionary             *dic;
@property(nonatomic,retain) NSString                        *authMessage;
@property(nonatomic,retain) ProfileContact                  *profile;
@property(nonatomic,retain) NSMutableData                   *eDirectoryData;
@property(nonatomic,assign) id<addProfileDelegateSupport>    delegate;
@property(nonatomic, retain) NSDictionary                    *userInfoDict;

-(void)createUserProfileWithData:(NSDictionary *)dict;

@end

@protocol addProfileDelegateSupport<NSObject>
-(void)addProfileDidLogin;
-(void)addProfileDidNotLogin;
@end