//
//  SettingsMagnager.h
//  eDirectory
//
//  Created by Rafael Gustavo Gali on 07/10/10.
//  Copyright 2010 Arca Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SettingsManager : NSObject {
	BOOL             socialNetworkEnabled;
	BOOL             reviewListingEnabled;
	BOOL             needLoginToListingReview;
	BOOL             openIdEnabled;
	BOOL             facebookEnabled;
	NSString        *facebookApiKey;
	NSString        *twitterApiKey;
	NSString        *twitterApiSecret;
	NSString        *currentItem;
    NSString        *defaultTagline;
	NSURLConnection *eDirectoryConnection;
    NSMutableData   *eDirectoryData;
	BOOL             parserDidFinish;
	
	BOOL             promotionForceRedeemFacebook;
    BOOL             twilioEnabled;
}

@property (nonatomic ,assign) BOOL             parserDidFinish;

@property (nonatomic, retain) NSURLConnection *eDirectoryConnection;
@property (nonatomic, retain) NSMutableData   *eDirectoryData;
@property (nonatomic, retain) NSString        *currentItem;

@property (nonatomic, assign) BOOL             socialNetworkEnabled;
@property (nonatomic, assign) BOOL             reviewListingEnabled;
@property (nonatomic, assign) BOOL             needLoginToListingReview;
@property (nonatomic, assign) BOOL             openIdEnabled;
@property (nonatomic, assign) BOOL             facebookEnabled;
@property (nonatomic, copy  ) NSString        *facebookApiKey;
@property (nonatomic, copy  ) NSString        *twitterApiKey;
@property (nonatomic, copy  ) NSString        *twitterApiSecret;
@property (nonatomic, copy  ) NSString        *defaultTagline;

@property (nonatomic, assign) BOOL             promotionForceRedeemFacebook;
@property (nonatomic, assign) BOOL             twilioEnabled;


-(id)init;
-(id)initWithNoWhait;

@end
