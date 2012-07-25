//
//  BusinessCell.h
//  ArcaMobileDeals
//
//  Created by Ricardo Silva on 6/2/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RatingView.h"

@interface BusinessCell : UITableViewCell {
    
    UILabel     *businessTitle;
    UILabel     *businessSummaryText;
    UILabel     *businessDistance;
    UILabel     *businessAddress;
    UIImage     *businessImage;
    UIView      *bgView;
    
    float rating;
}

@property (nonatomic, assign) float rating;

@property(nonatomic,retain) IBOutlet UILabel     *businessTitle;
@property(nonatomic,retain) IBOutlet UILabel     *businessSummaryText;
@property(nonatomic,retain) IBOutlet UILabel     *businessDistance;
@property(nonatomic,retain) IBOutlet UILabel     *businessAddress;
@property(nonatomic,retain) UIImage *businessImage;
@property(nonatomic,retain) IBOutlet UIView      *bgView;


-(void)applyTheme;

@end
