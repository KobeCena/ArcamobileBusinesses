/*
 ######################################################################
 #                                                                    #
 # Copyright 2005 Arca Solutions, Inc. All Rights Reserved.           #
 #                                                                    #
 # This file may not be redistributed in whole or part.               #
 # eDirectory is licensed on a per-domain basis.                      #
 #                                                                    #
 # ---------------- eDirectory IS NOT FREE SOFTWARE ----------------- #
 #                                                                    #
 # http://www.edirectory.com | http://www.edirectory.com/license.html #
 ######################################################################
 
 ClassDescription:
 Author:
 Since:
 */

#import <UIKit/UIKit.h>

#import "DraggableView.h"
#import "RatingView.h"
#import "Listing.h"
#import "SettingsManager.h"
#import "NumberViews.h"

@interface DraggableViewController : UIViewController {
	
	DraggableView *draggView;
	UILabel * dragTitle;
	UIButton *detailButton;
	UIButton *directionsButton;
	RatingView *ratingView;
	
	double latitude, longitude;
	
	Listing *listingBean;
    UIImageView *image;
	UINavigationController *currentNavigationController;
	
	SettingsManager *setm;
	
    IBOutlet UILabel *directionsLabel;
    
}

@property (nonatomic, retain) IBOutlet DraggableView *draggView;
@property (nonatomic, retain) IBOutlet UILabel *dragTitle;
@property (nonatomic, retain) IBOutlet RatingView *ratingView;

@property (nonatomic, retain) IBOutlet UIButton *detailButton;
@property (nonatomic, retain) IBOutlet UIButton *directionsButton;

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@property (nonatomic, retain) UINavigationController *currentNavigationController;
@property (nonatomic, retain) Listing *listingBean;
@property (nonatomic, retain) IBOutlet UIImageView *image;


-(IBAction)handleGetDirections:(id)sender;
-(IBAction)handleGetDetail:(id)sender;
-(void)setMapReference:(UIViewController*)mapReference;
@end
