//
//  ReviewCell.h
//  ArcaMobileBusinesses
//
//  Created by Ricardo Silva on 9/12/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RpCacheController.h"

@interface ReviewCell : UITableViewCell <RpCacheControllerDelegate>{
    float rating;
    UIView *bgView;
    UILabel *reviewerName;
    UILabel *reviewDate;
    UILabel *reviewText;
    UIImage *reviewerImage;
    UIImageView *reviewerImageView;
    NSString *reviewImageURL;
    
    RpCacheController *cacheControl;
    
}

@property (nonatomic, assign) float rating;
@property (nonatomic, retain) IBOutlet UIView *bgView;
@property (nonatomic, retain) IBOutlet UILabel *reviewerName;
@property (nonatomic, retain) IBOutlet UILabel *reviewDate;
@property (nonatomic, retain) IBOutlet UILabel *reviewText;
@property (nonatomic, retain) UIImage *reviewerImage;
@property (nonatomic, retain) IBOutlet UIImageView *reviewerImageView;
@property (nonatomic, retain) NSString *reviewImageURL;
@property (nonatomic, retain) RpCacheController *cacheControl;

@end
