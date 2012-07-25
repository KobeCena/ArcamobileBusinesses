//
//  Utility.h
//  JuridGen
//
//  Created by Ricardo Silva on 12/13/10.
//  Copyright 2010 Arca Solutions Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FavoriteBusiness.h"
#import "ReviewsPosted.h"

#import "Deal.h"
#import "RecordInstall.h"
#import "ARCABusinesses.h"

//Constants defined to send notifications about deals
extern NSString *const DEALS_FINISHED;
extern NSString *const DEALS_FINISHED_NO_RESULTS;
extern NSString *const DEALS_CANCELED;
extern NSString *const PIN_SELECTED;

extern NSString *const DEALS_HISTORY_OPERATION1;
extern NSString *const DEALS_HISTORY_OPERATION2;
extern NSString *const DEALS_HISTORY_OPERATION3;

extern NSString *const DEALS_NEARBY_OPERATION1;
extern NSString *const DEALS_NEARBY_OPERATION2;

@interface Utility : NSObject {
	
    
}


//DELETE operation for a FavoriteBusiness
+ (void) deleteFavoriteBusiness:(int) favoriteBusinessID;
//READ operation for a GrabeedDeals	
+ (FavoriteBusiness *) getFavoriteBusinessById:(NSNumber *) promotionID;
//INSERT operation for a GrabeedDeals
+ (FavoriteBusiness *) saveFavoriteBusiness:(ARCABusinesses *) favoriteBusiness;

// DELETE operation for a FavoriteBusiness
+ (void) deleteReviewsPosted:(int) ReviewsPostedID;
// READ operation for all FavoriteBusiness
+ (NSArray *) getAllFavoriteBusiness;
// READ operation for a specific FavoriteBusiness
+ (ReviewsPosted *) getReviewsPostedById:(NSNumber *) ReviewPostID;
// INSERT operation for a FavoriteBusiness
+ (ReviewsPosted *) saveReviewsPosted:(int) reviewNote forBusinessID:(int) businessID;


+(void)presentEmailComposer:(UIViewController *)viewController whithSubject:(NSString *) subjectStr withBody:(NSString *) bodyStr;
+(void)launchMailAppOnDevice:(NSString *) subjectStr;
+(NSArray *)getAllUnusedDeals;
+(void)registerInstallationRecord;
+(BOOL)verifyFirstRun;
+(void)showAnAlertMessage:(NSString *)i18NMessageKey withTitle:(NSString *) i18NTitleKey;
+(void)proceedWithStatistics:(NSString *)item businessID:(NSDecimalNumber *) businessID foursquare_id:(NSString *)foursquare_id;
+(id)getLocationSearchOptionsObject:(int)page keyword:(NSString *)keyword order:(int)order categoryId:(int)categoryId zipCode:(NSString *)zipcode latitude:(float)latitude longitude:(float)longitude;

@end
