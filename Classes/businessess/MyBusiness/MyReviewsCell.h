//
//  MyReviewsCell.h
//  ArcaMobileBusinesses
//
//  Created by Ricardo Silva on 9/15/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RatingView.h"

@interface MyReviewsCell : UITableViewCell {
    UIView *bgView;
    UILabel *businessTitle;
    RatingView *reviewRate;
    UILabel *reviewDate;
}

@property (nonatomic, retain) IBOutlet UIView *bgView;
@property (nonatomic, retain) IBOutlet UILabel *businessTitle;
@property (nonatomic, retain) IBOutlet RatingView *reviewRate;
@property (nonatomic, retain) IBOutlet UILabel *reviewDate;


-(void)applyTheme;
@end
