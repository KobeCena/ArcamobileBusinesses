//
//  MyBusinessViewController.h
//  ArcaMobileBusinesses
//
//  Created by Ricardo Silva on 9/15/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyReviewsTableViewController.h"
#import "FavoritesTableViewController.h"
#import "ChooseProfileViewController.h"
#import "ARCAReview.h"
#import "ARCABusinesses.h"
#import "FavoriteBusiness.h"
#import "EdirectoryUserLocation.h"

@interface MyBusinessViewController : UIViewController<eAuthDelegate, EdirectoryUserLocationDelegate> {
    UIImageView *tabBarImageView;
    UIButton *tab1Button;
    UIButton *tab2Button;
    UIView *placeholderView;
    UIView *myReviewsContentView;
    UIView *favoriteContentViews;
    UITableView *myReviewstable;
    UITableView *favoriteTable;
    MyReviewsTableViewController *myReviewsTableViewController;
    FavoritesTableViewController *favoritesTableViewController;
    ChooseProfileViewController *chooseProfileViewController;
    UIView *alertView;
    UILabel *alertLabel;
}

@property (nonatomic, retain) IBOutlet UIImageView *tabBarImageView;
@property (nonatomic, retain) IBOutlet UIButton *tab1Button;
@property (nonatomic, retain) IBOutlet UIButton *tab2Button;
@property (nonatomic, retain) IBOutlet UIView *placeholderView;
@property (nonatomic, retain) IBOutlet UIView *myReviewsContentView;
@property (nonatomic, retain) IBOutlet UIView *favoriteContentViews;
@property (nonatomic, retain) IBOutlet UITableView *myReviewstable;
@property (nonatomic, retain) IBOutlet UITableView *favoriteTable;
@property (nonatomic, retain) IBOutlet MyReviewsTableViewController *myReviewsTableViewController;
@property (nonatomic, retain) IBOutlet FavoritesTableViewController *favoritesTableViewController;
@property (nonatomic, retain) IBOutlet ChooseProfileViewController *chooseProfileViewController;
@property (nonatomic, retain) IBOutlet UIView *alertView;
@property (nonatomic, retain) IBOutlet UILabel *alertLabel;

@property (nonatomic, retain) EdirectoryUserLocation *edirectoryUserLocation;
@property (nonatomic, readonly) CLLocationCoordinate2D userLocation;



-(void)proceedWithBusinessDetails:(FavoriteBusiness *)businessObject;
-(void)proceedWithDetails:(ARCAReview *)reviewObject;
-(IBAction)handleEditPress:(id)sender;
-(void)checkProfile;
-(void)cancel:(id)sender;
@end
