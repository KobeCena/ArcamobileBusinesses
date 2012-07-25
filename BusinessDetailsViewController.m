//
//  BusinessDetailsViewController.m
//  ArcaMobileDeals
//
//  Created by Ricardo Silva on 6/8/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import "BusinessDetailsViewController.h"
#import "LoginData.h"
#import "ChooseProfileViewController.h"
#import "Utility.h"
#import "CoreUtility.h"

#import "SVWebViewController.h"
#import "EdirectoryAppDelegate.h"
#import "ImagePageViewController.h"
#import "ListingAnnotationView.h"
#import "RpDashBoardButton.h"
#import "ARCABusinessesGallery.h"
#import "ARCABusinessesImage.h"
#import "ARCAserver_businesses.h"
#import "ReviewCell.h"
#import "ReviewDetailViewController.h"
#import "BusinessAllReviewsViewController.h"
#import "EdirectoryParserToWSSoapAdapter.h"

#import "CXMLDocument.h"
#import "CoreUtility.h"

#define ITEM_SPACING 210
#define degreesToRadian(x) (M_PI * (x) / 180.0)


#pragma mark - BusinessDetailsViewController redefinition for private components and methods
@interface BusinessDetailsViewController() 

//private properties used for gallery
@property(nonatomic, retain) NSMutableArray *galleryDatasource;
@property(nonatomic, retain)RpCacheController * cacheController;
//used to identify the actionSheetOperation
@property(nonatomic, retain)NSString * actionSheetOperation;
//used to hold all reviews for this business
@property(nonatomic, retain)NSMutableArray * businessReviewsDataSource;

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username;
- (void) setupGalleryScrollView:(int)numberOfPages loadPages:(BOOL) loadPages;
- (IBAction)changePage:(id)sender;
- (void) loadScrollViewWithPage:(int)page;
- (void) presentRatingReviewScreen;
- (void) disableFavoriteButton;
- (void) handleDialingToPhoneNumber;
//- (void) handleGetDirections;

#pragma mark - WS-SOAP brisgde callback methods
- (void) PostToTwitterHandler:  (BOOL) value;
- (void) PostToFacebookHandler: (BOOL) value;

@end

#pragma mark - BusinessDetailsViewController implementation section
@implementation BusinessDetailsViewController
@synthesize scrollableView;

@synthesize tab1Button;
@synthesize tab2Button;
@synthesize tab3Button;
@synthesize tab4Button;
@synthesize businessMapView;
@synthesize businessDescriptionTextView;
@synthesize emailLabel;
@synthesize emailTextLabel;
@synthesize siteLabel;
@synthesize sitetextLabel;
@synthesize phoneLabel;
@synthesize phoneTextLabel;
@synthesize faxLabel;
@synthesize faxLabelText;
@synthesize segMenuReview;
@synthesize reviewsTable;
@synthesize tmpCell;
@synthesize businessTitleLabel;
@synthesize businessDistanceLabel;


@synthesize cameraMediaView;
@synthesize businessObject;
@synthesize setm;
@synthesize alertView, alertLabel;
@synthesize eDirectoryData, currentItem;
@synthesize eDirectoryConnection;
@synthesize chooseProfileViewController;
@synthesize mapViewController;
@synthesize tabBarDetail;
@synthesize detailContentScrollView;

@synthesize scrollView;
@synthesize pageControl;
@synthesize dataSource;
@synthesize viewControllers;
@synthesize placeholderView;
@synthesize businessDescriptionView;
@synthesize businessContactView;
@synthesize businessDirectionsView;
@synthesize businessReviewsList;
@synthesize ratingView;
@synthesize businessReviewsAmountLabel;
@synthesize businessReviewButton;
@synthesize businessFavoriteButton;
@synthesize reviewGallery;
@synthesize cacheController;
@synthesize galleryDatasource;
@synthesize actionSheetOperation;
@synthesize businessReviewsDataSource;

@synthesize promptView;
@synthesize btnCallRequest;
@synthesize lblCallRequest;
@synthesize imgCallRequest;
@synthesize addressLabel;
@synthesize cityLabel;
@synthesize stateLabel;
@synthesize zipcodeLabel;
@synthesize labelAddressText;

@synthesize proxyView;

@synthesize userLocation;

@synthesize phoneToCallRequest;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)dealloc
{
    [businessObject             release];
    [setm                       release];
    [alertLabel                 release];
    [eDirectoryData             release];
    [currentItem                release];
    [chooseProfileViewController release];
    [operation                   release];
    [mapViewController          release];
    [cameraMediaView            release];    
    [alertView                  release]; 
    [scrollView                 release];
    [pageControl                release];
    [dataSource                 release];
    [viewControllers            release];
    [placeholderView            release];
    
    [ratingView                 release];
    
    [tabBarDetail               release];
    [detailContentScrollView    release];
    [businessTitleLabel release];
    [businessDistanceLabel release];
    [businessReviewsAmountLabel release];
    [businessReviewButton release];
    [businessFavoriteButton release];
    [businessDescriptionView release];
    [businessContactView release];
    [businessDirectionsView release];
    [businessReviewsList release];
    [businessMapView release];
    [businessDescriptionTextView release];
    [emailLabel release];
    [emailTextLabel release];
    [siteLabel release];
    [sitetextLabel release];
    [phoneLabel release];
    [phoneTextLabel release];
    [faxLabel release];
    [faxLabelText release];
    [tab1Button release];
    [tab2Button release];
    [tab3Button release];
    [tab4Button release];
    [reviewsTable release];
    
    [cacheController setDelegate:nil];
    [cacheController release];
    
    [businessReviewsDataSource release];
    [tmpCell release];
    [proxyView release];

    [scrollableView release];
    
    [phoneToCallRequest release];
    
    [promptView release];
    
    [btnCallRequest release];
    [lblCallRequest release];
    [imgCallRequest release];
    [segMenuReview release];
    [addressLabel release];
    [cityLabel release];
    [stateLabel release];
    [zipcodeLabel release];
    [labelAddressText release];
    [super                      dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
    
}

#pragma mark - Post message to twitter
-(void)postMessageToTwitter:(SA_OAuthTwitterEngine *)_engine{
    
    PostShareToTwitter * twitterShare = [[[PostShareToTwitter alloc] 
                                          initWithPin:[self cachedTwitterOAuthDataForUsername:@""] 
                                          fromDeal: [[self.businessObject _id] intValue]] autorelease];
    [twitterShare share];

}


#pragma mark - Blocks the screen
-(void)addWaitingAlertOverCurrentView{

    
    [self.view setUserInteractionEnabled:NO];
    
    [self.view addSubview:alertView];
    alertView.backgroundColor = [UIColor clearColor];
    alertView.center = self.view.center;
    CALayer *viewLayer = self.alertView.layer;
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.duration = 0.35555555;
    animation.values = [NSArray arrayWithObjects:
                        [NSNumber numberWithFloat:0.6],
                        [NSNumber numberWithFloat:1.1],
                        [NSNumber numberWithFloat:.9],
                        [NSNumber numberWithFloat:1],
                        nil];
    animation.keyTimes = [NSArray arrayWithObjects:
                          [NSNumber numberWithFloat:0.0],
                          [NSNumber numberWithFloat:0.6],
                          [NSNumber numberWithFloat:0.8],
                          [NSNumber numberWithFloat:1.0], 
                          nil];    
    [viewLayer addAnimation:animation forKey:@"transform.scale"];
    [self performSelector:@selector(updateText:) withObject:NSLocalizedString(@"Wait", @"") afterDelay:0.0];
}

- (void)updateText:(NSString *)newText
{
    self.alertLabel.text = newText;
}
- (void)finalUpdate
{
    [UIView beginAnimations:@"" context:nil];
    self.alertView.alpha = 0.0;
    [UIView commitAnimations];
    [UIView setAnimationDuration:0.35];
    [self performSelector:@selector(removeAlert) withObject:nil afterDelay:0.5];    
}
- (void)removeAlert
{
    [self.alertView removeFromSuperview];
    self.alertView.alpha = 1.0;
    
    [self.view setUserInteractionEnabled:YES];    
}

- (void)handleError:(NSError *)error {
    NSString *errorMessage = [error localizedDescription];
	
    UIAlertView *alertErrorView = [[UIAlertView alloc] 
								   initWithTitle:NSLocalizedString(@"Downloading Error", @"") 
								   message:errorMessage 
								   delegate:nil
								   cancelButtonTitle:@"OK" 
								   otherButtonTitles:nil
								   ];
	
    [alertErrorView show];
    [alertErrorView release];
}

#pragma mark - View lifecycle
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}


-(void)applyTheme {
    
//gets a reference to application delegate
//	EdirectoryAppDelegate *appDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
    
//    [appDelegate.themeSettings configureLabel:self.dealValueLabel withTheme:THEME_LABEL_LEVEL1];
//    [appDelegate.themeSettings configureLabel:self.dealsGrabbedLabel withTheme:THEME_LABEL_LEVEL5];
//    [appDelegate.themeSettings configureLabel:self.dealPercentDiscountLabel withTheme:THEME_LABEL_LEVEL3];
//    [appDelegate.themeSettings configureLabel:self.dealOriginalValueLabel withTheme:THEME_LABEL_LEVEL5];    
//    [appDelegate.themeSettings configureLabel:self.dealTimeLeftLabel withTheme:THEME_LABEL_LEVEL5];
//    
//    [appDelegate.themeSettings configureLabel:self.labelDaysUntilFinish withTheme:THEME_LABEL_LEVEL4];
//    [appDelegate.themeSettings configureLabel:self.labelHoursUntilFinish withTheme:THEME_LABEL_LEVEL4];
//    [appDelegate.themeSettings configureLabel:self.labelMinutesUntilFinish withTheme:THEME_LABEL_LEVEL4];
//    [appDelegate.themeSettings configureLabel:self.labelSecondsUntilFinish withTheme:THEME_LABEL_LEVEL4];    
//    
//    [appDelegate.themeSettings configureLabel:self.dealNameLabel withTheme:THEME_LABEL_LEVEL2];    
    
}


-(void)setBusinessDirectionsMap{
    
    [self.businessDirectionsView addSubview: self.mapViewController.view ];
    
    CGRect viewSize = CGRectMake(0.0f, 0.0f, self.businessDirectionsView.frame.size.width, self.businessDirectionsView.frame.size.height);
    
    [self.mapViewController.view    setFrame:viewSize];
    [self.mapViewController.mapView setFrame:viewSize];
    
	//Hides the "waiting" screen
	[self.mapViewController unBlockMapView];
	
	//Only remove the annotations if they exists
	if ([self.mapViewController.mapView.annotations count] >0) {
		[self.mapViewController.mapView removeAnnotations:self.mapViewController.mapView.annotations ];
	}
	
	//Hides our custom BubbleInfoView
	if ( [self.mapViewController.draggViewController view].hidden == NO) {
		[self.mapViewController.draggViewController view].hidden = YES;
	}    
    
    //Hide the detail Button
    [self.mapViewController.draggViewController.detailButton setHidden:YES];
    
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = self.businessObject.coordinate.latitude;
    newRegion.center.longitude = self.businessObject.coordinate.longitude;
    
    newRegion.span.latitudeDelta = (2.0f/111.0f);
    newRegion.span.longitudeDelta = (2.0f/111.0f);
    
    [self.mapViewController.mapView setRegion:newRegion animated:NO];
    
    Listing * annotation = [[Listing alloc] init];
    
    [annotation setLatitude:        [self.businessObject latitude]      ];
    [annotation setLongitude:       [self.businessObject longitude]     ];
    [annotation setListingTitle:    [self.businessObject title]         ];
    [annotation setListingIcon:     [self.businessObject imageObject]   ];
    [annotation setAddress:         [self.businessObject address]       ];
    [annotation setRawAddress:      [self.businessObject full_address]  ];
    [annotation setMapTunning:      [self.businessObject maptuning]     ];
    
    ListingAnnotationView *businessLocation = [[[ListingAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"businessLocation"] autorelease];
    
    [self.mapViewController.mapView addAnnotation:[businessLocation annotation]];
//    
//    [self.mapViewController.mapView setScrollEnabled:NO];
//    [self.mapViewController.mapView setZoomEnabled:NO];
    
    [self.mapViewController.draggViewController setLatitude: self.userLocation.latitude];
    [self.mapViewController.draggViewController setLongitude: self.userLocation.longitude];
    
    //setup current user location coordinate into dragViewController, so we can do the directions stuff
   /* [self.mapViewController.draggViewController setLatitude: self.mapViewController.mapView.userLocation.coordinate.latitude   ];
    [self.mapViewController.draggViewController setLongitude: self.mapViewController.mapView.userLocation.coordinate.longitude ];*/
    
    [self.mapViewController draggViewSetup:annotation];
    
    
    [self.mapViewController showInfoBubble:CGPointMake(160, 30) fromView: businessLocation withData:annotation];
    
    CGRect viewR = [self.mapViewController.draggViewController view].frame;
    [self.mapViewController.draggViewController.view setHidden:NO];
    viewR.origin = CGPointMake(50, 50);
    [self.mapViewController.draggViewController.view setFrame:viewR];
    
    [self.mapViewController setDisableHideWhenMapTouched: YES];
    [self.mapViewController.mapView setScrollEnabled:NO];
    [self.mapViewController.mapView setZoomEnabled:NO];
    [annotation release];
    
}


-(void)configAllTabItemLabels:(int) index{
    

	EdirectoryAppDelegate *appDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];    
    
    UIColor * themeColor = [appDelegate.themeSettings createColorForTheme:THEME_DEFAULTS];
    
    //reset all colors
    [self.tab1Button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.tab2Button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.tab3Button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.tab4Button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    switch (index) {
        case 1:
            [self.tab1Button setTitleColor:themeColor forState:UIControlStateNormal];
            break;
        case 2:
            [self.tab2Button setTitleColor:themeColor forState:UIControlStateNormal];
            break;
        case 3:
            [self.tab3Button setTitleColor:themeColor forState:UIControlStateNormal];
            break;
        case 4:
            [self.tab4Button setTitleColor:themeColor forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
    
    //sets the labels for all Tabitems
    [self.tab1Button setTitle: NSLocalizedString(@"detailButtonTab1", nil) forState:UIControlStateNormal];
    [self.tab2Button setTitle: NSLocalizedString(@"detailButtonTab2", nil) forState:UIControlStateNormal];
    [self.tab3Button setTitle: NSLocalizedString(@"detailButtonTab3", nil) forState:UIControlStateNormal];    
    [self.tab4Button setTitle: NSLocalizedString(@"detailButtonTab4", nil) forState:UIControlStateNormal];
    
}

-(void)bindingBusinessObjectDataToElements{
    
	EdirectoryAppDelegate *appDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];        
    UIColor * themeColor = [appDelegate.themeSettings createColorForTheme:THEME_DEFAULTS];
    
    //sets the rating for this Business
    self.ratingView.rating = [[self.businessObject avg_review] floatValue];
    
    //sets the description for this Business
    self.businessDescriptionTextView.text = self.businessObject.long_description;
    
    
    [self.businessTitleLabel setText: [self.businessObject title] ];
    [self.businessTitleLabel setTextColor:themeColor];
    
    //set text for the review Tab
    if([[self.businessObject reviews_amount] intValue] > 1) {
        [self.businessReviewsAmountLabel setText: [NSString stringWithFormat: NSLocalizedString(@"reviewsLabel", nil), [[self.businessObject reviews_amount] intValue] ] ];
    } else {
        [self.businessReviewsAmountLabel setText: [NSString stringWithFormat: NSLocalizedString(@"reviewLabel", nil), [[self.businessObject reviews_amount] intValue] ] ];
    }
    
    if([businessObject distance] != [NSDecimalNumber notANumber]) {
        [self.businessDistanceLabel setText: [NSString stringWithFormat:NSLocalizedString(@"XDistance", @""), [[businessObject distance] floatValue], NSLocalizedString(@"DistancePlural", @"")]];
    }
    
    
    //sets all contact information
    [self.emailLabel    setText: NSLocalizedString(@"detailContactEmail", nil) ];
    [self.siteLabel     setText: NSLocalizedString(@"detailContactSite", nil)  ];
    [self.phoneLabel    setText: NSLocalizedString(@"detailContactPhone", nil) ];
    [self.faxLabel      setText: NSLocalizedString(@"detailContactFax", nil)   ];
    
    [self.emailTextLabel    setText:[self.businessObject email] ];
    [self.sitetextLabel     setText:[self.businessObject url]   ];
    [self.phoneTextLabel    setText:[self.businessObject phone] ];
    [self.faxLabelText      setText:[self.businessObject fax]   ];
    
    [self.labelAddressText setText:[self.businessObject address]];

}

-(void)viewDidAppear:(BOOL)animated{
    
    //init the cacheController
    RpCacheController * tempCache = [[RpCacheController alloc] initWhithLastUpdateFromServer: [NSDate date] ];
    [self setCacheController:tempCache];
    [tempCache release];
    //sets the delegate
    [self.cacheController setDelegate:self];
 
    //defines the carousel type
    reviewGallery.type = iCarouselTypeRotary;

    [reviewGallery setDelegate:self];
    [reviewGallery setDataSource:self];
    [reviewGallery reloadData];
}

// Handle the response from getReviews.

- (void) getReviewsHandler: (id) value {
    
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		return;
	}
    
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		return;
	}				
    
    //create the datasource array for review carrousel 
    galleryDatasource = [[NSMutableArray alloc] init];
    
	// Do something with the ARCAArrayReview* result
    ARCAArrayReview* result = (ARCAArrayReview*)value;
    
    //create the array that will populate the reviewstable
    businessReviewsDataSource = [[NSMutableArray alloc] init];
    NSDecimalNumber *mediaTotal = 0;
    float valorTotal = 0;
    
    for (ARCAReview * review in result) {
        
        if (!isEmpty([review galleryImage])) {
            RpDashBoardButton *reviewImageButton = [RpDashBoardButton buttonWithType:UIButtonTypeCustom];
            [reviewImageButton setButtonImageURL: [NSURL URLWithString:[review galleryImage] ] ];
            [reviewImageButton setBackgroundColor: [UIColor clearColor]];
            [reviewImageButton setButtonIndex: [review _id] ];
            
            [galleryDatasource addObject: reviewImageButton];
        }
        
        valorTotal += [review.rating floatValue];
        [businessReviewsDataSource addObject:review];
    }
    
    
    mediaTotal = (NSDecimalNumber *) [NSNumber numberWithFloat: ceilf(valorTotal / result.count)];

    @try {
        self.ratingView.rating = [mediaTotal floatValue];
    }
    @catch (NSException *exception) {
        self.ratingView.rating = [self.businessObject.avg_review floatValue];
    }
    @finally {}
        
    //set text for the review Tab
    if([businessReviewsDataSource count] > 1 ) {
        [self.businessReviewsAmountLabel setText: [NSString stringWithFormat: NSLocalizedString(@"reviewsLabel", nil), [businessReviewsDataSource count] ] ];
    } else {
        [self.businessReviewsAmountLabel setText: [NSString stringWithFormat: NSLocalizedString(@"reviewLabel", nil), [businessReviewsDataSource count] ] ];
    }
    
    [self.businessReviewButton setTitle:NSLocalizedString(@"reviewButton", nil) forState:UIControlStateNormal];
    
    if ([businessReviewsDataSource count] < 1) {
        [tab4Button setEnabled: NO];
        [tab4Button setAlpha:0.2f];
    } else {
        [tab4Button setEnabled: YES];
        [tab4Button setAlpha:1.0f];
    }
    
    if ([galleryDatasource count] > 5) {
        reviewGallery.type = iCarouselTypeRotary;
    } else {
        reviewGallery.type = iCarouselTypeLinear;
    }
    
    [reviewGallery reloadData];    
}


-(void)getAllReviewsForThisBusiness{
    ARCAserver_businesses * service = [ARCAserver_businesses service];   
    [service setLogging:NO];
    EdirectoryParserToWSSoapAdapter *adapter = [EdirectoryParserToWSSoapAdapter sharedInstance];
    [service setHeaders:[adapter getDomainToken]];
    
    [service getReviews:self action:@selector(getReviewsHandler:) userName:@"" businessID:[self.businessObject _id] foursquare_id:self.businessObject.foursquare_id module:@"business" page:nil];
}


- (void)viewDidLoad
{
 
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.    
    
    //verify if we need hide the Favorite Button
    [self disableFavoriteButton];    
    
    [segMenuReview setTitle:NSLocalizedString(@"Reviews", @"") forSegmentAtIndex:0];
    [segMenuReview setTitle:NSLocalizedString(@"Gallery", @"") forSegmentAtIndex:1];
    [lblCallRequest setText:NSLocalizedString(@"CallMe", @"")];
    
    //Configure a Share button in the NavigationBar
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SegShare", @"") style:UIBarButtonItemStylePlain target:self action:@selector(handleShareButtonPress)];
    [self.navigationItem setRightBarButtonItem:doneButton ];
    [doneButton release];
    
    
    phoneToCallRequest = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 50.0, 260.0, 25.0)];
    [phoneToCallRequest setBackgroundColor:[UIColor clearColor]];
    [phoneToCallRequest setBorderStyle:UITextBorderStyleRoundedRect];
    [phoneToCallRequest setClearButtonMode:UITextFieldViewModeAlways];
    [phoneToCallRequest setKeyboardType:UIKeyboardTypePhonePad];
    [phoneToCallRequest setReturnKeyType:UIReturnKeyDefault];
    [phoneToCallRequest setAlpha: 1.0f];
    [phoneToCallRequest setPlaceholder: NSLocalizedString(@"PhoneTip", @"")];
    [phoneToCallRequest setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    
    if ([setm twilioEnabled]) {
    } else {
        [btnCallRequest setEnabled: NO];
        [btnCallRequest setHidden: YES];
        [lblCallRequest setHidden: YES];
        //[imgCallRequest setHidden: YES];
    }
    
    
    [self applyTheme ];
    
    float adjustHeight = 200.0f;
    float thisViewHeight = detailContentScrollView.bounds.size.height;
    float placeholderHeight = self.placeholderView.frame.size.height;
    
    [detailContentScrollView setContentSize: CGSizeMake(320, thisViewHeight + 
                                                        (thisViewHeight - placeholderHeight) + adjustHeight )   ];
    detailContentScrollView.clipsToBounds = YES;		// default is NO, we want to restrict drawing within our scrollview
	detailContentScrollView.scrollEnabled = YES;
    
    //configure all labels for tab items
    [self configAllTabItemLabels:1];

    //populates this screen
    [self bindingBusinessObjectDataToElements];
    
    //configure the businessMapView
    [self setBusinessDirectionsMap];
    
    //verifies how many images this business has in Gallery
    ARCABusinessesGallery * BusinessesGallery = self.businessObject.BusinessesGallery;
    
    
    dataSource = [[NSMutableArray alloc] init];    
    for (ARCABusinessesImage * image in self.businessObject.BusinessesGallery) {
        [dataSource addObject: [image image]];
    }
    
    [self setupGalleryScrollView:[dataSource count] loadPages:YES];
    
    
    [self getAllReviewsForThisBusiness];
    
    //add the business description to the placeholderView
    [placeholderView addSubview:businessDescriptionView];

    /****************/
    //insert the social media view
    cameraMediaView.frame = CGRectMake(0, self.view.frame.size.height,
                                       cameraMediaView.frame.size.width,
                                       cameraMediaView.frame.size.height);
    [self.view addSubview:self.cameraMediaView];
    /****************/
    
    //show the reviewtable
    [self.reviewGallery setHidden:YES];
    [self.reviewsTable setHidden:NO];
    

    //register this class to listen all notifications comming from the zooming view
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(listemZoomingViewNotifications:)
                                                 name:nil object:self.scrollableView];
    
    
}


-(void)listemZoomingViewNotifications:(NSNotification *) notification{
	//verifies to see if the notification is coming from the FarmacoPreviewViewController class
	if ([notification.name isEqualToString:@"ENTERSFULLSCREEN"]) {
        [self setupGalleryScrollView:[dataSource count] loadPages:NO];
	}
}


- (void)viewDidUnload
{
    [self setAddressLabel:nil];
    [self setCityLabel:nil];
    [self setStateLabel:nil];
    [self setZipcodeLabel:nil];
    [self setLabelAddressText:nil];;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - eAthDelegate Methods
-(void)didLogin{

    LoginData *login = [[LoginData alloc] init];    
        
    //verifies if is obrigatory facebook login to grabDeal
    if ([[self setm] promotionForceRedeemFacebook] && (![login facebookProfileExist]) ) {
        [Utility showAnAlertMessage:@"forceFacebookLogInToReview" withTitle:@"forceFacebookLogInToReviewTitle"];
    }else{
        //remove the login view from screen
        [self.navigationController popViewControllerAnimated:NO];
        [self presentRatingReviewScreen];
    }

    [login release];
    
}
-(void)didNotLogin{

}


-(void)pushesChooseProfile{

    [chooseProfileViewController setTitle: NSLocalizedString(@"ProfileNecessary", @"")];
    [chooseProfileViewController setSetm:setm];
    [chooseProfileViewController setHideFacebook:NO];	
    [chooseProfileViewController setHideProfileView:[[self setm] promotionForceRedeemFacebook]];
    [chooseProfileViewController setDelegate:self];
    
    [[self navigationController] pushViewController:chooseProfileViewController animated: YES];        

}


-(IBAction)handleEmailButtonPressed:(id) sender{
    
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil)
	{
		// We must always check whether the current device is configured for sending emails
		if ([mailClass canSendMail])
		{
            NSString *bodyText = [NSString stringWithFormat:NSLocalizedString(@"sharedEmailBodyText", nil), self.businessObject.long_description];
            
            [Utility presentEmailComposer:self whithSubject: [businessObject title] withBody:bodyText];
		}
		else
		{
			[Utility launchMailAppOnDevice: [businessObject title]];
		}
	}
	else
	{
		[Utility launchMailAppOnDevice: [businessObject title]];
	}
    
    [self hideCameraMediaView];
    
}
-(IBAction)handleTwitterButtonPressed:(id) sender{
    
    [self hideCameraMediaView];
    
    [self addWaitingAlertOverCurrentView];
    
    
    
	SA_OAuthTwitterEngine * _engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
	_engine.consumerKey    = [setm twitterApiKey];
	_engine.consumerSecret = [setm twitterApiSecret];
	
	if (![_engine isAuthorized]) {
		
		UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:_engine delegate:self];
		
		[self presentModalViewController: controller animated: YES];
	} else {
        

        [self postMessageToTwitter:_engine];
		//[_engine clearAccessToken];        
	}
	
	[_engine release];
    
    [self finalUpdate];
}

//this method is called in response for the press at the site label
-(void)openInsideWebBrowser{
    
    SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress: [businessObject url] ];    
    [self presentModalViewController:webViewController animated:YES];    
    [webViewController release];    
    
}

//shows the MapView
-(void)showMapViewController{
    
    NSLog(@"show map view controller!");
    
	//Shows the "waiting" screen
	[self.mapViewController.searching setHidden:NO];	
	[self.mapViewController.view setUserInteractionEnabled:NO];
    
    //prevents the mapView from refresh after a region change
    [self.mapViewController setRefreshWhenRegionChanges:NO];
    
    //do not show the righBarButton at the navigation controller
    [self.mapViewController setShowRighNavigationButton:NO];
    
    //do not show the detail buton in the custom infoBubble
    [self.mapViewController.draggViewController.detailButton setHidden:YES];
	
	//Only remove the annotations if they exists
	if ([self.mapViewController.mapView.annotations count] >0) {
		[self.mapViewController.mapView removeAnnotations:self.mapViewController.mapView.annotations ];
	}
	
    //this line of code grants that we always show the user location, fake or not.
    [self.mapViewController.mapView setShowsUserLocation:YES];
    
    NSArray * mapPoints = [NSArray arrayWithObject:self.businessObject];
    
    [self.mapViewController setListings: mapPoints];
    [self.mapViewController.mapView performSelectorOnMainThread: @selector(addAnnotations:) withObject: mapPoints waitUntilDone: YES];
    
    [self.mapViewController.draggViewController setLatitude: self.userLocation.latitude];
    [self.mapViewController.draggViewController setLongitude: self.userLocation.longitude];
    
	//Hides our custom BubbleInfoView
	if ([self.mapViewController.draggViewController view].hidden == NO) {
		[self.mapViewController.draggViewController view].hidden = YES;
	}
    
    //hides the detail button
    self.mapViewController.draggViewController.detailButton.hidden = YES;
    
    [self.mapViewController setTitle: [businessObject promotionName]];
    
	//Pushes the mapViewControler into the navigationController
	[[self navigationController] pushViewController:mapViewController animated:YES];
    [self.mapViewController gotoLocation:[businessObject latitude] newLongitude:[businessObject longitude]];	    
    
	//unlocks the mapScreen
	[self.mapViewController.searching setHidden:YES];	
	[self.mapViewController.view setUserInteractionEnabled:YES];
    
    
}




#pragma mark - MFMailComposeViewController Delegate method
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	

	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			//message.text = @"Result: canceled";
			break;
		case MFMailComposeResultSaved:
			//message.text = @"Result: saved";
			break;
		case MFMailComposeResultSent:
			//message.text = @"Result: sent";
			break;
		case MFMailComposeResultFailed:
			//message.text = @"Result: failed";
			break;
		default:
			//message.text = @"Result: not sent";
			break;
	}
    
	[self dismissModalViewControllerAnimated:YES];
}



#pragma mark - Twitter Engine Delegate
- (void) OAuthTwitterController: (SA_OAuthTwitterController *) controller authenticatedWithUsername: (NSString *) username{
    [self postMessageToTwitter:controller.engine];
}



#pragma mark SA_OAuthTwitterEngineDelegate
- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username {
	NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setObject: data forKey: @"authData"];
	[defaults synchronize];
}

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username {
	return [[NSUserDefaults standardUserDefaults] objectForKey: @"authData"];
}



#pragma mark - scrollView Stuff
- (void)loadScrollViewWithPage:(int)page {
    
    if (page < 0) return;
    if (page >= [dataSource count]) return;
	
    // replace the placeholder if necessary
    ImagePageViewController *controller = [viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null]) {
        controller = [[ImagePageViewController alloc] initWithPageNumber:page withSource:[dataSource copy]];
        [viewControllers replaceObjectAtIndex:page withObject:controller];
        [controller release];
    }
	
    // add the controller's view to the scroll view
    if (nil == controller.view.superview) {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [scrollView addSubview:controller.view];
        [scrollView sendSubviewToBack:controller.view];
    }
    
}


- (void)scrollViewDidScroll:(UIScrollView *)sender {
    
    
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (pageControlUsed) {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
	
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    
    if (page != pageControl.currentPage) {
        pageControl.currentPage = page;
        
        // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
        [self loadScrollViewWithPage:page - 1];
        [self loadScrollViewWithPage:page];
        [self loadScrollViewWithPage:page + 1];
    }
    
    // A possible optimization would be to unload the views+controllers which are no longer visible
}


// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlUsed = NO;
}

- (IBAction)changePage:(id)sender {
    
    
    int page = pageControl.currentPage;
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page -1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page +1];
    
	// update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:NO];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
}

#pragma mark - configures the scrollView
-(void) setupGalleryScrollView:(int)numberOfPages loadPages:(BOOL) loadPages{
    
    if (!viewControllers) {
        
        NSMutableArray *controllers = [[NSMutableArray alloc] init];
        
        for (unsigned i = 0; i < [dataSource count]; i++) {
            [controllers addObject:[NSNull null]];
        }
        self.viewControllers = controllers;
        [controllers release];
    }else{
        for (ImagePageViewController * controller in self.viewControllers) {
            if (![controller isKindOfClass:[NSNull class]]) {
                [controller.view removeFromSuperview];
            }
        }
    }    
    
    scrollView.pagingEnabled = YES;
	scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * numberOfPages, scrollView.frame.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;    
    [scrollView bringSubviewToFront:self.pageControl];
    
    //defining the number of pages for pageControl component
    pageControl.numberOfPages = [dataSource count];
    
    if (loadPages) {
        pageControl.currentPage = 0;        
        [self loadScrollViewWithPage:0];    
        [self loadScrollViewWithPage:1];
    }
    
    [self changePage:nil];
    
    self.pageControl.center = CGPointMake(self.scrollableView.bounds.size.width/2, self.scrollableView.bounds.size.height - 20);
    [self.scrollableView bringSubviewToFront:self.pageControl];
}


-(void)removeAllDetailSubviews{
    [businessDescriptionView    removeFromSuperview];
    [businessContactView        removeFromSuperview];
    [businessDirectionsView     removeFromSuperview];
    [businessReviewsList        removeFromSuperview];
}


#pragma mark - Handle TabBar Buttons
-(IBAction)handleTabBarButtons:(id)sender{
    
    UIButton *button = (UIButton *)sender;
    
    tabBarDetail.image = [UIImage imageNamed:[NSString stringWithFormat:@"detailTab00%i.png", button.tag]];
    
    
    [self configAllTabItemLabels: button.tag];
    
    [self removeAllDetailSubviews];
    switch ([button tag]) {
        case 1: //change the view for details
            [placeholderView addSubview:businessDescriptionView];
            break;
        case 2: //cahnage the view for contact
            [placeholderView addSubview:businessContactView];
            break;
        case 3://change the view for map;
            [placeholderView addSubview:businessDirectionsView];
            //block the mapView
            [businessDirectionsView setUserInteractionEnabled:YES];
            break;
        case 4: //change the view for reviews
            [placeholderView addSubview:businessReviewsList] ;
            break;
            
        default:
            break;
    }
}

#pragma mark - Handle changes in segmented control value
-(IBAction)handleSegmentControlValueChange:(id)sender{
    
    UISegmentedControl * segControl = (UISegmentedControl *) sender;
    
    switch (segControl.selectedSegmentIndex) {
        case 0:
            [self.reviewGallery setHidden:YES];
            [self.reviewsTable setHidden:NO];
            break;
        case 1:
            [self.reviewGallery setHidden:NO];
            [self.reviewsTable setHidden:YES];
            
        default:
            break;
    }
    
}


#pragma mark -
#pragma mark iCarousel methods
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [galleryDatasource count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index
{
    
    RpDashBoardButton * button = (RpDashBoardButton *)[galleryDatasource objectAtIndex:index ]; 
    [self.cacheController prepareCachedImage:[button buttonImageURL] forThisIndex:index];
    
    
    button.frame = CGRectMake(0, 0, 200, 200);
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundColor:[UIColor clearColor]];
    
    return button;

}

- (float)carouselItemWidth:(iCarousel *)carousel
{
    //slightly wider than item view
    return ITEM_SPACING;
}


- (BOOL)carouselShouldWrap:(iCarousel *)carousel{
    return YES;
}


- (void)buttonTapped:(UIButton *)sender{
    //NSLog(@"Pressionou botão no índice %i", self.reviewGallery.currentItemIndex);
    for (ARCAReview *review in businessReviewsDataSource) {
        if ([review _id] == [(RpDashBoardButton *) sender buttonIndex]) {
            [self selectedReview: review];
            break;
        }
    }
}


#pragma mark - RPCacheController delegate Methods
- (void) appImageDidLoad:(NSData *)imageData forIndex:(int)index{
//    NSLog(@"imagem carregou [%i]", index);

    RpDashBoardButton * button = (RpDashBoardButton *)[galleryDatasource objectAtIndex:index ]; 
    [button setBackgroundImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
    
}

- (void)appImageLoadFailed:(int)index {
    RpDashBoardButton * button = (RpDashBoardButton *)[galleryDatasource objectAtIndex:index ];
    [button removeFromSuperview];
}

#pragma mark - handle review button press
-(IBAction)handleReviewButtonPress:(id)sender{    

    LoginData *loginData = [[LoginData alloc] init];
    
    if ([loginData profileExist] == NO && [loginData facebookProfileExist] == NO ) {
        
        [self pushesChooseProfile];
        
    }else{
        
        //verifies if is obrigatory facebook login to review
        if ([[self setm] promotionForceRedeemFacebook] && (![loginData facebookProfileExist]) ) {
            [Utility showAnAlertMessage:@"forceFacebookLogInToReview" withTitle:@"forceFacebookLogInToReviewTitle"];
            
            [self pushesChooseProfile];
            
        }else{
            //proceed with review screen
            
            [self presentRatingReviewScreen];
            
        }
        
    }
    [loginData release];
    
}

-(void)presentRatingReviewScreen{
    RatingReviewViewController * reviewController = [[RatingReviewViewController alloc] initWithNibName:@"RatingReviewViewController" bundle:nil];
    [reviewController setDelegate:self];
    [reviewController setBusinessTittle:[businessObject title]];
    [reviewController setBusinessID: [[businessObject _id] intValue] ];
    [reviewController setFoursquare_id: [businessObject foursquare_id]];
    [reviewController setModuleName:@"business"];
    [reviewController setSetm:self.setm];
    [self.navigationController pushViewController:reviewController animated:true];
    [reviewController release];
    
}

// Handle the response from addedToFavorites.
- (void) addedToFavoritesHandler: (BOOL) value {
	// Do something with the BOOL result
}

#pragma mark - handle favorite button press
-(IBAction)handleFavoriteButtonPress:(id)sender{
    [self setActionSheetOperation:@"FAVORITE"];
    
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"AddFavorites", @""), nil];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
    [actionSheet release];
    
    [self disableFavoriteButton];
    
    
}

#pragma mark - Handle Share Button press
-(void) handleShareButtonPress{
    [self setActionSheetOperation:@"SHARE"];
    
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:nil otherButtonTitles:@"E-mail", @"Twitter", @"Facebook", nil];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
    [actionSheet release];
}

#pragma mark - UIActionSheetDelegate Methods
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{

    
    if ([[self actionSheetOperation] isEqualToString:@"SHARE"]) {

            LoginData *login = [[LoginData alloc] init];    
            
            ARCAserver_businesses * service = [ARCAserver_businesses service];
            service.logging = NO;

        NSString *bodyText = [NSString stringWithFormat:NSLocalizedString(@"sharedEmailBodyText", nil), (businessObject.long_description.length>0?businessObject.long_description:(businessObject.description.length>0?businessObject.description:businessObject.title))];
        
            switch (buttonIndex) {
                case 0: //E-Mail
                    [Utility presentEmailComposer:self whithSubject:[businessObject title] withBody:bodyText];
                    break;
                case 1: //Twitter
                    
                    [self addWaitingAlertOverCurrentView];
                    
                    SA_OAuthTwitterEngine * _engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
                    _engine.consumerKey    = [setm twitterApiKey];
                    _engine.consumerSecret = [setm twitterApiSecret];
                    
                    if (![_engine isAuthorized]) {
                        
                        UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:_engine delegate:self];
                        
                        [self presentModalViewController: controller animated: YES];
                    } else {
                        
                        
                        NSString * twitterData = [self cachedTwitterOAuthDataForUsername:@""];
                        
                        NSArray * arrayS = [twitterData componentsSeparatedByString:@"&"];
                        
                        NSString * twitterKeyStr = [NSString string];
                        NSString * twitterSecretKeyStr = [NSString string];                        
                        
                        for (NSString * strObj in arrayS) {
                            NSArray * arrayM = [strObj componentsSeparatedByString:@"="];
                            
                            if ( [(NSString*)[arrayM objectAtIndex:0] isEqualToString:@"oauth_token"] ) {
                                twitterKeyStr = [arrayM objectAtIndex:1];
                            }
                            
                            if ( [(NSString*)[arrayM objectAtIndex:0] isEqualToString:@"oauth_token_secret"] ) {
                                twitterSecretKeyStr = [arrayM objectAtIndex:1];
                            }
                            
                        }
                        
                        [service PostToTwitter:self action:@selector(PostToTwitterHandler:) objID:[businessObject _id] type:@"business" oauth_token:twitterKeyStr oauth_token_secret:twitterSecretKeyStr];
                    }
                    
                    [_engine release];
                    
                    [self finalUpdate];            
                    
                    break;
                case 2: //Facebook
                    if (login.facebookProfileExist) {
                        
                        [self addWaitingAlertOverCurrentView];
                        
                        ARCAserver_businesses* service = [ARCAserver_businesses service];
                        EdirectoryParserToWSSoapAdapter *adapter = [EdirectoryParserToWSSoapAdapter sharedInstance];
                        [service setHeaders:[adapter getDomainToken]];
                        service.logging = NO;
                        
                        
                        [service loginWithFacebook:self action:@selector(loginWithFacebookHandler:) 
                                               uid: [[login facebookProfile] facebookID] 
                                         firstName: [[[login facebookProfile] firstName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] 
                                          lastName: [[[login facebookProfile] lastName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] 
                                        acessToken: [[[login facebookProfile] accessToken] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ];
                        
                    }else{
                        [self pushesChooseProfile];
                    }
                    break;
                case 3: //Cancel
                    break;
                default:
                    break;
            }
            
            [login release];
    }
    
    if ([[self actionSheetOperation] isEqualToString:@"FAVORITE"]) {
        
        switch (buttonIndex) {
            case 0://add to favorites
                [Utility saveFavoriteBusiness: [self businessObject] ];
                
                //notifies server that user has favorited this business for statistics pourposes
                
                [Utility proceedWithStatistics:@"added_to_favorites" businessID:[self.businessObject _id] foursquare_id:[self.businessObject foursquare_id]];
                
                
                
                //verify if we need hide the Favorite Button
                [self disableFavoriteButton];    

                break;
            case 1://Cancel
                break;
                
            default:
                break;
        }
    }
    
}

- (void) loginWithFacebookHandler: (id) value {
    
    LoginData *login = [[LoginData alloc] init];
    
    ARCAserver_businesses* service = [ARCAserver_businesses service];
    EdirectoryParserToWSSoapAdapter *adapter = [EdirectoryParserToWSSoapAdapter sharedInstance];
    [service setHeaders:[adapter getDomainToken]];
    service.logging = NO;
    
    
    [service PostToFacebook:self 
                     action:@selector(PostToFacebookHandler:) 
                        uid:[[login facebookProfile] facebookID] 
                 acessToken:[[login facebookProfile] accessToken] 
                 businessID:[businessObject _id] type:@"businesses"];
    
    
    [login release];
}

#pragma mark - WS-SOAP brigde callback methods
- (void) PostToTwitterHandler: (BOOL) value {
	// Do something with the BOOL result    
    [Utility proceedWithStatistics:@"shared_twitter" businessID:[self.businessObject _id] foursquare_id:[self.businessObject foursquare_id]];
    [Utility showAnAlertMessage:NSLocalizedString(@"SharedSuccessfully", @"") withTitle:@"Twitter"];
    
    [self removeAlert];
}

- (void) PostToFacebookHandler: (BOOL) value {
	// Do something with the BOOL result
    [Utility proceedWithStatistics:@"shared_facebook" businessID:[self.businessObject _id] foursquare_id:[self.businessObject foursquare_id]];
    [Utility showAnAlertMessage:NSLocalizedString(@"SharedSuccessfully", @"") withTitle:@"Facebook"];
    
    [self removeAlert];
}


#pragma mark - disable Favorite Button
-(void) disableFavoriteButton{
    FavoriteBusiness * favoriteBusiness = [Utility getFavoriteBusinessById:[NSNumber numberWithInt: [[[self businessObject] _id] intValue] ] ];
    
    if (! isEmpty(favoriteBusiness)) {
        [self.businessFavoriteButton setEnabled:NO];
        [self.businessFavoriteButton setAlpha:0.5f];
    }
}

-(void)handleDialingToPhoneNumber{
	
	
	NSString *dialingUrl = [[NSString alloc] initWithFormat:@"tel:%@", [self.businessObject phone]];	
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:dialingUrl]];
	[dialingUrl release];
	
}

/*
-(void)handleGetDirections{
	
	NSString* directionsUrl = [NSString stringWithFormat: @"http://maps.google.com/maps?saddr=%f,%f&daddr=%@",
							   self.latitude, self.longitude,
							   [[self.businessObject address] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:directionsUrl]];
	
}
*/
#pragma mark - Handle contact info press
-(IBAction)handleContactInfoPress:(id)sender{
    
    UIButton * button = (UIButton *) sender;
    NSString *bodyText = [NSString stringWithFormat:NSLocalizedString(@"sharedEmailBodyText", nil), self.businessObject.long_description];
    
    
    switch (button.tag) {
        case 1://E-mail
            if (! isEmpty([businessObject email])) {
                [Utility presentEmailComposer:self whithSubject:[businessObject title] withBody:bodyText];
            }
            
            break;
        case 2://WebSite
            if (! isEmpty([businessObject url])) {
                [self openInsideWebBrowser];
            }
            break;
        case 3://Fone
            if (! isEmpty([businessObject phone])) {
                [self handleDialingToPhoneNumber];
            }
            break;
        case 4://Fax
            //do nothing since it's a fax number
            break;
            
        default:
            break;
    }
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if ([self.businessReviewsDataSource count] > 2) {
        return 2;
    } else {
        return 1;
    }
	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.businessReviewsDataSource count] > 2 ? 2 : [self.businessReviewsDataSource count];
    } else {
        return 1;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 92.0f;
    } else {
        return 30.0f;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"ReviewCell";
	
    
    UITableViewCell* returnCell = nil;
    
	if (indexPath.section == 0) {
        
		ARCAReview *reviewObject = [businessReviewsDataSource objectAtIndex:indexPath.row];
		
        
		ReviewCell *cell = (ReviewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
		if (cell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"ReviewCell" owner:self options:nil];
            //[cellNib instantiateWithOwner:self options:nil];
            
            
			cell = tmpCell;
			self.tmpCell = nil;		
		} 
		
		/* ------------------------------------------------------------- 
		 populate the cell
		 */
		
        //cell.layer.shouldRasterize = YES;
        //cell.layer.rasterizationScale = [UIScreen mainScreen].scale;

        
        //Creates the formatter for the date        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: NSLocalizedString(@"dateFormat", nil) ];
        
        
        cell.rating = [[reviewObject rating] floatValue];
        cell.reviewerName.text = [reviewObject reviewer_name];
        cell.reviewDate.text = [dateFormatter stringFromDate: [reviewObject added] ] ;
        cell.reviewText.text = [reviewObject review];
        cell.reviewImageURL = [reviewObject galleryImage];
        
        [dateFormatter release];
		returnCell = cell;
        
	} else if(indexPath.section == 1) {
        returnCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AllReviewsCell"] autorelease];
        
        [returnCell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
        
        UILabel *labelAllReviews = [[UILabel alloc] init];
        
        [labelAllReviews setText: NSLocalizedString(@"ShowAllReviews", @"")];
        [labelAllReviews setFrame:CGRectMake(10, 8, 250, 12)];
        [labelAllReviews setBackgroundColor:[UIColor clearColor]];
        [labelAllReviews setFont:[UIFont fontWithName:@"Helvetica" size:12]];
        
        EdirectoryAppDelegate *appDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];    
        UIColor *themeColor = [appDelegate.themeSettings createColorForTheme:THEME_DEFAULTS];
        
        [labelAllReviews setTextColor: themeColor];
        [returnCell addSubview: labelAllReviews];
        [labelAllReviews release];
        
    }
    
    
    
    [returnCell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    
    UIView * selectedView = [[UIView alloc] initWithFrame:returnCell.frame];
    selectedView.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230/255.0 blue:230/255.0 alpha:0.3];        
    [returnCell setSelectedBackgroundView:selectedView];
    [selectedView release];
    
    return returnCell;
	
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        ReviewCell * reviewCell = (ReviewCell *)cell ;
        
        UIColor * normalColor = [UIColor colorWithRed:110.0/255.0 green:113.0/255.0 blue:116.0/255.0 alpha:1.0];
        UIColor * oddColor = [UIColor colorWithRed:64.0/255.0 green:67.0/255.0 blue:72.0/255.0 alpha:1.0];
        
        [[reviewCell bgView] setBackgroundColor:((indexPath.row % 2 == 0) ? normalColor : oddColor) ];
        
    } else {
        [cell setBackgroundColor: [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1]];
    }

}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section == 0) {
        ARCAReview *review = [businessReviewsDataSource objectAtIndex: indexPath.row];
        [self selectedReview: review];
    } else if(indexPath.section == 1) {
        [self showAllBusinessReviews];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



- (void)willAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        [self.scrollableView toggleZoom:NO];
        self.view.alpha = 0.0;
    }
    
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
		[[UIApplication sharedApplication]
         setStatusBarHidden:NO
         withAnimation:UIStatusBarAnimationFade];
        self.view.alpha = 1.0;
    }
    
}

- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration{
    if (! ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeRight || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeLeft) ) {
        [self.scrollableView dismissFullscreenView];
        
    }
    
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    if ( [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait ) {
        [self.view layoutSubviews];
    }
    
}

#pragma mark - Review Detail
- (void) selectedReview: (ARCAReview *) review {
    ReviewDetailViewController *reviewDetail = [[ReviewDetailViewController alloc] initWithNibName:@"ReviewDetailViewController" bundle:nil];
    [reviewDetail setReviewObject: review];
    [self.navigationController pushViewController:reviewDetail animated:YES];
    [reviewDetail release];
}
- (void) showAllBusinessReviews {
    BusinessAllReviewsViewController *myView = [[BusinessAllReviewsViewController alloc] initWithNibName:@"BusinessAllReviewsViewController" bundle:nil];
    //[myView setArrReviews: self.businessReviewsDataSource];
    //[myView refreshTableData];
    
    [myView setFoursquare_id:[self.businessObject foursquare_id]];
    [myView setItemID: [self.businessObject _id]];
    [myView setItemType:@"business"];
    
    [self.navigationController pushViewController:myView animated:YES];
    [myView release];
}

- (IBAction)handleCallRequest:(id)sender {
    promptView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"YourPhoneNumber",@"") message:@"  " delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") otherButtonTitles:NSLocalizedString(@"CallMe", @""), nil];
    
    [promptView addSubview:phoneToCallRequest];
    [promptView setTag: 2011];
    [promptView show];
    
    // set place
    [promptView setTransform:CGAffineTransformMakeTranslation(0, 110.0)];
    [phoneToCallRequest becomeFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) { //cancel
        // nothing
    } else if([[phoneToCallRequest text] length] > 0) { // ok
        
        [self addWaitingAlertOverCurrentView];
        
        ARCAserver_businesses * service = [ARCAserver_businesses service];   
        [service setLogging:YES];
        [service Twilio_makeCall:self action:@selector(handleSentCallRequest:) myDeviceNumber:phoneToCallRequest.text business_id:self.businessObject._id];
        
    }
    
    [phoneToCallRequest setText:@""];
}

- (void) handleSentCallRequest: (id) value {
    
    [self removeAlert];
    NSString *errorMsg = @"";
    
    // Handle errors
    if([value isKindOfClass:[NSError class]]) {
        errorMsg = NSLocalizedString(@"soapProccessError", nil);
        return;
    }
    
    // Handle faults
    if([value isKindOfClass:[SoapFault class]]) {
        errorMsg = NSLocalizedString(@"soapFaultError", nil);
        return;
    } 
    
    ARCAStandardReturn* result = (ARCAStandardReturn*) value;
    
    if (result.Status) {
        errorMsg = @"";
        
    } else {
        errorMsg = result.Message;	
    }
    
    if (errorMsg.length > 0) {
        
        UIAlertView *tmpAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CallRequest", @"") message: errorMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [tmpAlert show];
        [tmpAlert release];
        
    } else {
        
        UIAlertView *tmpAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CallRequest", @"") message:NSLocalizedString(@"CallRequestSuccessMessage", @"") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [tmpAlert show];
        [tmpAlert release];
        
    }
}

#pragma  mark - Sharing Delegate

- (void)didFinishPostReview {
    [self getAllReviewsForThisBusiness];
}

@end
