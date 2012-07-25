//
//  BusinessDetailsViewController.h
//  ArcaMobileBusiness
//
//  Created by Ricardo Silva on 6/8/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "Deal.h"
#import "ChooseProfileViewController.h"
#import "SettingsManager.h"
#import "SA_OAuthTwitterEngine.h"
#import "SA_OAuthTwitterController.h"
#import "MapViewController.h"
#import "PostShareToTwitter.h"
#import "PostShareToFacebook.h"
#import "ARCABusinesses.h"
#import "ARCAReview.h"
#import "RatingView.h"
#import "iCarousel.h"
#import "RpCacheController.h"
#import "ReviewCell.h"
#import "ZoomingView.h"
#import "RatingReviewViewController.h"


@interface BusinessDetailsViewController : UIViewController<UIScrollViewDelegate, eAuthDelegate, MFMailComposeViewControllerDelegate, SA_OAuthTwitterControllerDelegate, iCarouselDelegate, iCarouselDataSource, RpCacheControllerDelegate, UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, EdirectoryXMLParserDelegate, RatingReviewControllerDelegate> {
    
	NSTimer                     *timer;    
    ARCABusinesses              *businessObject;
    SettingsManager             *setm;
    
    //AlertView
    IBOutlet UIView *alertView;
    IBOutlet UILabel *alertLabel;

    
    //for Server request and XML parsing
    NSMutableData               *eDirectoryData;
    NSString                    *currentItem;
    NSURLConnection             *eDirectoryConnection;
    

    //view for social sharing
    UIView *cameraMediaView;
    
    //for share on facebook only
    ChooseProfileViewController* chooseProfileViewController;
    
    //to handle operation inseide this screen
    NSString    *operation;
    
    //to get MapView inside this screen
    IBOutlet MapViewController * mapViewController;
    UIImageView *tabBarDetail;
    UIScrollView *detailContentScrollView;
    
    //scrollViewForImages
    UIScrollView    *scrollView;
    UIPageControl   *pageControl;
    
    //datasource
    NSMutableArray             *dataSource;    
    
    //ViewController array for imagesPages
    NSMutableArray *viewControllers;
    
    BOOL pageControlUsed;    
    
    //Placeholder view for Tab results
    UIView * placeholderView;
    UIView *businessDescriptionView;
    UIView *businessContactView;
    UIView *businessDirectionsView;
    UIView *businessReviewsList;
    
    RatingView * ratingView;
    UILabel *businessReviewsAmountLabel;
    UIButton *businessReviewButton;
    UIButton *businessFavoriteButton;
    UILabel *businessTitleLabel;
    UILabel *businessDistanceLabel;
    MKMapView *businessMapView;
    UITextView *businessDescriptionTextView;
    UILabel *emailLabel;
    UILabel *emailTextLabel;
    UILabel *siteLabel;
    UILabel *sitetextLabel;
    UILabel *phoneLabel;
    UILabel *phoneTextLabel;
    UILabel *faxLabel;
    UILabel *faxLabelText;
    UISegmentedControl *segMenuReview;
    UITableView *reviewsTable;
    ReviewCell *tmpCell;
    UIButton *tab1Button;
    UIButton *tab2Button;
    UIButton *tab3Button;
    UIButton *tab4Button;
    
    RpCacheController  *cacheController;    

    ZoomingView *scrollableView;
    
    UIView *proxyView;
    
    CLLocationCoordinate2D userLocation;
    
    UITextField *phoneToCallRequest;
    UIButton *btnCallRequest;
    UILabel *lblCallRequest;
    UIImageView *imgCallRequest;
}

@property (nonatomic, retain) IBOutlet iCarousel * reviewGallery;

//ViewController array for imagesPages
@property (nonatomic, retain) NSMutableArray *viewControllers;

//datasource for scrollViews
@property (nonatomic, retain) NSMutableArray             *dataSource;

//scrollView for Images
@property(nonatomic, retain) IBOutlet UIScrollView    *scrollView;
@property(nonatomic, retain) IBOutlet UIPageControl   *pageControl;

@property(nonatomic,retain) ARCABusinesses              *businessObject;
@property(nonatomic,retain) SettingsManager             *setm;

//for Server request and XML parsing
@property (nonatomic, retain) NSMutableData			      *eDirectoryData;
@property (nonatomic, retain) NSString                    *currentItem;
@property (nonatomic, retain) NSURLConnection             *eDirectoryConnection;

//AlertView
@property(nonatomic,retain) IBOutlet UIView *alertView;
@property(nonatomic,retain) IBOutlet UILabel *alertLabel;

//Social Media view
@property (nonatomic, retain) IBOutlet UIView *cameraMediaView;


//for share on facebook only
@property (nonatomic, retain) IBOutlet ChooseProfileViewController* chooseProfileViewController;

//to get MapView inside this screen
@property (nonatomic, retain) IBOutlet MapViewController * mapViewController;
@property (nonatomic, retain) IBOutlet UIImageView *tabBarDetail;
@property (nonatomic, retain) IBOutlet UIScrollView *detailContentScrollView;


//Buttons for Tab
@property (nonatomic, retain) IBOutlet UIButton *tab1Button;
@property (nonatomic, retain) IBOutlet UIButton *tab2Button;
@property (nonatomic, retain) IBOutlet UIButton *tab3Button;
@property (nonatomic, retain) IBOutlet UIButton *tab4Button;


//components for Business detail
@property (nonatomic, retain) IBOutlet UILabel *businessTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *businessDistanceLabel;
@property(nonatomic, retain) IBOutlet  RatingView *ratingView;
@property (nonatomic, retain) IBOutlet UILabel  *businessReviewsAmountLabel;
@property (nonatomic, retain) IBOutlet UIButton *businessReviewButton;
@property (nonatomic, retain) IBOutlet UIButton *businessFavoriteButton;

//Placeholder view for Tab results
@property (nonatomic, retain) IBOutlet UIView *placeholderView;
//Views for each tab button
@property (nonatomic, retain) IBOutlet UIView *businessDescriptionView;
@property (nonatomic, retain) IBOutlet UIView *businessContactView;
@property (nonatomic, retain) IBOutlet UIView *businessDirectionsView;
@property (nonatomic, retain) IBOutlet UIView *businessReviewsList;

//elements within each tab view
@property (nonatomic, retain) IBOutlet MKMapView *businessMapView;
@property (nonatomic, retain) IBOutlet UITextView *businessDescriptionTextView;
@property (nonatomic, retain) IBOutlet UILabel *emailLabel;
@property (nonatomic, retain) IBOutlet UILabel *emailTextLabel;
@property (nonatomic, retain) IBOutlet UILabel *siteLabel;
@property (nonatomic, retain) IBOutlet UILabel *sitetextLabel;
@property (nonatomic, retain) IBOutlet UILabel *phoneLabel;
@property (nonatomic, retain) IBOutlet UILabel *phoneTextLabel;
@property (nonatomic, retain) IBOutlet UILabel *faxLabel;
@property (nonatomic, retain) IBOutlet UILabel *faxLabelText;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segMenuReview;

@property (nonatomic, retain) IBOutlet UITableView *reviewsTable;
@property (nonatomic, retain) IBOutlet ReviewCell *tmpCell;

//view that holds the scrollable images from business
@property (nonatomic, retain) IBOutlet ZoomingView *scrollableView;


//proxy view
@property (nonatomic, retain, readonly) UIView *proxyView;

@property (nonatomic) CLLocationCoordinate2D userLocation;
@property (nonatomic, retain) UITextField *phoneToCallRequest;
@property (nonatomic, retain) UIAlertView *promptView;
@property (nonatomic, retain) IBOutlet UIButton *btnCallRequest;
@property (nonatomic, retain) IBOutlet UILabel *lblCallRequest;
@property (nonatomic, retain) IBOutlet UIImageView *imgCallRequest;

@property (retain, nonatomic) IBOutlet UILabel *addressLabel;
@property (retain, nonatomic) IBOutlet UILabel *cityLabel;
@property (retain, nonatomic) IBOutlet UILabel *stateLabel;
@property (retain, nonatomic) IBOutlet UILabel *zipcodeLabel;

@property (retain, nonatomic) IBOutlet UITextView *labelAddressText;


- (void) selectedReview: (ARCAReview *)review;
- (void) showAllBusinessReviews;
- (IBAction)handleCallRequest:(id)sender;

@end
