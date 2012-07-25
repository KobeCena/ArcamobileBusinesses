//
//  ReviewDetailViewController.h
//  ArcaMobileBusinesses
//
//  Created by Ricardo Silva on 9/12/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARCAReview.h"
#import "RatingView.h"
#import "RpCacheController.h"
#import "RpAsyncImageDownloader.h"

@interface ReviewDetailViewController : UIViewController <RpCacheControllerDelegate, RpAsyncImageDownloaderDelegate> {
    
    ARCAReview * reviewObject;
    UIImageView *reviwerImage;
    UILabel *reviewerName;
    UILabel *reviewDate;
    RatingView *reviewRatingView;
    UITextView *reviewText;
    UIImageView *reviewImage;
    
    RpCacheController *cacheControl;
    RpAsyncImageDownloader *imageDownloader;
    
    UILabel *lblListingTitle;
    UILabel *lblUserReviews;
    UIActivityIndicatorView *gifLoading;
    UILabel *lblRate;
}
@property (nonatomic, retain) IBOutlet UILabel *lblRate;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *gifLoading;
@property(nonatomic, retain)ARCAReview * reviewObject;
@property (nonatomic, retain) IBOutlet UIImageView *reviwerImage;
@property (nonatomic, retain) IBOutlet UILabel *reviewerName;
@property (nonatomic, retain) IBOutlet UILabel *reviewDate;
@property (nonatomic, retain) IBOutlet RatingView *reviewRatingView;
@property (nonatomic, retain) IBOutlet UITextView *reviewText;
@property (nonatomic, retain) IBOutlet UIImageView *reviewImage;
@property (nonatomic, retain) RpCacheController *cacheControl;
@property (nonatomic, retain) RpAsyncImageDownloader *imageDownloader;
@property (nonatomic, retain) IBOutlet UILabel *lblListingTitle;
@property (nonatomic, retain) IBOutlet UILabel *lblUserReviews;

@end
