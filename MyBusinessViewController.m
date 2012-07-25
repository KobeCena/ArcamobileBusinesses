//
//  MyBusinessViewController.m
//  ArcaMobileBusinesses
//
//  Created by Ricardo Silva on 9/15/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import "MyBusinessViewController.h"
#import "EdirectoryAppDelegate.h"
#import "CoreUtility.h"
#import "ARCAserver_businesses.h"
#import "EdirectoryParserToWSSoapAdapter.h"
#import "ReviewDetailViewController.h"
#import "BusinessDetailsViewController.h"

@interface MyBusinessViewController()

-(void)configAllTabItemLabels:(int) index;
-(void)checkProfile;
-(void)proceedWithParserPhase:(LoginData*)loginData;
-(void)removeAllDetailSubviews;
-(void)populateFavorites;
@end;



@implementation MyBusinessViewController

@synthesize tabBarImageView;
@synthesize tab1Button;
@synthesize tab2Button;
@synthesize placeholderView;
@synthesize myReviewsContentView;
@synthesize favoriteContentViews;
@synthesize myReviewstable;
@synthesize favoriteTable;
@synthesize myReviewsTableViewController;
@synthesize favoritesTableViewController;
@synthesize chooseProfileViewController;
@synthesize alertView;
@synthesize alertLabel;

@synthesize edirectoryUserLocation;
@synthesize userLocation;

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


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
	/*for(UIView *view in self.tabBarController.tabBar.subviews) {  
		if([view isKindOfClass:[UIImageView class]]) {  
			[view removeFromSuperview];  
		}  
	}  
	
	[self.tabBarController.tabBar insertSubview:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tabBar03.png"]] autorelease] atIndex:0];  
    */
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
	//EdirectoryAppDelegate *appDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(settingDidLogout:)
                                                 name:@"SETTING::LOGOUT" object:nil];
    
	//Initializes the EdirectoryUserLocation
	EdirectoryUserLocation * tmpUserLocation = [EdirectoryUserLocation alloc];
	self.edirectoryUserLocation = tmpUserLocation;
	self.edirectoryUserLocation.delegate = self;
	
    
    //from now on the screen flow will be managed by the EdirectoryUserLocationDelegate methods !
    [self.edirectoryUserLocation setupEdirectoryUserLocation]; 
    
    //configure all labels for tab items
    [self configAllTabItemLabels:1];    
    
    //profile phase
    [self checkProfile];    
    
    //config the myReviews view
    [self configAllTabItemLabels: 1];
	[self removeAllDetailSubviews];
    [placeholderView addSubview:myReviewsContentView];
    

    //sets the reference to this viewController
    self.myReviewsTableViewController.reviewParentViewController = self;
    self.favoritesTableViewController.reviewParentViewController = self;
      
    
    
    
    
    //populate favorites
    [self populateFavorites];  
}

-(void)checkProfile{
    LoginData *loginData = [[LoginData alloc] init];
    
	//EdirectoryAppDelegate *appDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
	if ([loginData profileExist]==NO && [loginData facebookProfileExist]==NO ) {
		
        UIAlertView *alView = [[UIAlertView alloc] initWithTitle:@"Reviews" message:@"You must be logged in to view your reviews." delegate:self cancelButtonTitle:@"Login" otherButtonTitles:@"Cancel", nil];
        
        [alView show];
        
        
        [alView release];
        
        /*
         [chooseProfileViewController setTitle: NSLocalizedString(@"ProfileNecessary", @"")];
         [chooseProfileViewController setSetm: [appDelegate setm] ];
         [chooseProfileViewController setHideFacebook:NO];
         [chooseProfileViewController setDelegate:self];
         [chooseProfileViewController hidesTheBackButton];
         
         [[self navigationController] pushViewController:chooseProfileViewController animated: YES];
         */
	}else{
        [self proceedWithParserPhase:loginData];
    }
    [loginData release];
    
}

#pragma mark - Profile check phase methods
-(void)proceedWithParserPhase:(LoginData*)loginData{
    
    //blocks the screen
    [self addWaitingAlertOverCurrentView];    
    
    NSString *username = @"";
    
    if ([loginData facebookProfileExist ]) {
        username = [[loginData facebookProfile] userName];//user_name
    } else {
        username = [[loginData profile] userName];//user_name 	
    }
    
    
    //disable the REFRESH button to prevent multiple server requests and avoid crashes inside the app
    [[[self navigationItem] rightBarButtonItem] setEnabled:NO];
    
    ARCAserver_businesses* service = [ARCAserver_businesses service];
    EdirectoryParserToWSSoapAdapter *adapter = [EdirectoryParserToWSSoapAdapter sharedInstance];
    [service setHeaders:[adapter getDomainToken]];
    service.logging = NO;

    
    NSLog(@"Requisitando dados ao servidor: %@", username);
    
    [service getReviews:self action:@selector(getReviewsHandler:)  userName:username businessID:nil foursquare_id:nil module:@"business" page:nil];

    
}

-(void)populateFavorites{

    NSMutableArray * favoritesArray =  [NSMutableArray arrayWithArray:[Utility getAllFavoriteBusiness]];
    
    //sets the results array to the datasource array used by MyReviewsTableViewController
    [self.favoritesTableViewController setDatasourceArray:favoritesArray];
    [self.favoritesTableViewController.tableView reloadData];
    
    NSLog(@"TEM %i favoritos ", [favoritesArray count]);
    
}

// Handle the response from getReviews.

- (void) getReviewsHandler: (id) value {
    
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
		return;
	}
    
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
		return;
	}				
    
    
	// Do something with the ARCAArrayReview* result
    ARCAArrayReview* result = (ARCAArrayReview*)value;
	NSLog(@"getReviews returned the value: %@", result);
    
    
    //creates a NSMtableArray to fill in before send the results to tableController
    NSMutableArray * objArray = [NSMutableArray array];
    
    for (ARCAReview *reviewObj in result) {
        [objArray addObject:reviewObj];
    }
    
    //sets the results array to the datasource array used by MyReviewsTableViewController
    [self.myReviewsTableViewController setDatasourceArray:objArray];
    [self.myReviewsTableViewController.tableView reloadData];
    
    
    [self finalUpdate];
    
    //enable the REFRESH button 
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];    
    
}


- (void)viewDidUnload
{
    [self setTabBarImageView:nil];
    [self setTab1Button:nil];
    [self setTab2Button:nil];
    [self setPlaceholderView:nil];
    [self setMyReviewsContentView:nil];
    [self setFavoriteContentViews:nil];
    [self setMyReviewstable:nil];
    [self setFavoriteTable:nil];
    [self setMyReviewsTableViewController:nil];
    [self setFavoritesTableViewController:nil];
    [self setChooseProfileViewController:nil];
    [self setAlertView:nil];
    [self setAlertLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [tabBarImageView release];
    [tab1Button release];
    [tab2Button release];
    [placeholderView release];
    [myReviewsContentView release];
    [favoriteContentViews release];
    [myReviewstable release];
    [favoriteTable release];
    [myReviewsTableViewController release];
    [favoritesTableViewController release];
    [chooseProfileViewController release];
    [alertView release];
    [alertLabel release];
    
    [edirectoryUserLocation release];
    
    [super dealloc];
}

-(void)configAllTabItemLabels:(int) index{
    
    
	EdirectoryAppDelegate *appDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];    
    
    UIColor * themeColor = [appDelegate.themeSettings createColorForTheme:THEME_DEFAULTS];
    
    //reset all colors
    [self.tab1Button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.tab2Button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    switch (index) {
        case 1:
            [self.tab1Button setTitleColor:themeColor forState:UIControlStateNormal];
            break;
        case 2:
            [self.tab2Button setTitleColor:themeColor forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    
    //sets the labels for all Tabitems
    [self.tab1Button setTitle: NSLocalizedString(@"myBusinessButtonTab1", nil) forState:UIControlStateNormal];
    [self.tab2Button setTitle: NSLocalizedString(@"myBusinessButtonTab2", nil) forState:UIControlStateNormal];
    
}

-(void)removeAllDetailSubviews{
    [myReviewsContentView    removeFromSuperview];
    [favoriteContentViews    removeFromSuperview];
}

#pragma mark - Handle TabBar Buttons
-(IBAction)handleTabBarButtons:(id)sender{
    
    UIButton *button = (UIButton *)sender;
    
    tabBarImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"myBusinessTab00%i.png", button.tag]];
    
    [self configAllTabItemLabels: button.tag];
    
    [self removeAllDetailSubviews];
    switch ([button tag]) {
        case 1: //change the view for details
            [placeholderView addSubview:myReviewsContentView];
            break;
        case 2: //cahnage the view for contact
            [placeholderView addSubview:favoriteContentViews];
            break;
            
        default:
            break;
    }
}


// Called by the parser when no listingResults were found
- (void)noResultsWereFound{
    NSLog(@"noResultsWereFound");       
    
    [self finalUpdate];    
}


#pragma mark - ChooseProfileViewController delegate Methods
-(void)didLogin{
    
	//return to the previous view
    [self.navigationController popViewControllerAnimated:YES];
    
    LoginData *loginData = [[LoginData alloc] init];
    [self proceedWithParserPhase:loginData];
    [loginData release];
}

-(void)didNotLogin{
    //enable the REFRESH button to prevent multiple server requests and avoi crashes inside the app
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
    
}

-(IBAction)handeRefreshButtonPress:(id)sender{
    
    //determines wich tableview is visible at this moment
    if ([[[placeholderView subviews] objectAtIndex:0] isEqual: self.myReviewsContentView ]) {
        [self checkProfile];
    }else if([[[placeholderView subviews] objectAtIndex:0] isEqual: self.favoriteContentViews ]){
        [self populateFavorites];
    }
    
}

// Handle the response from getAllBusinessForID.
- (void) getAllBusinessForIDHandler: (id) value {
    
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
		return;
	}
    
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
		return;
	}				
    
    
	// Do something with the ARCAArrayBusinesses* result
    ARCAArrayBusinesses* result = (ARCAArrayBusinesses*)value;
	ARCABusinesses *businessObject = [result objectAtIndex:0];

    
    //unlocks this screen
    [self finalUpdate];
    
    //gets a reference to the Application Delegate
    EdirectoryAppDelegate *appDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
    //Declares and instantiates this application loader view
    BusinessDetailsViewController *dealDetailViewController = [[BusinessDetailsViewController alloc]
                                                               initWithNibName:@"BusinessDetailsViewController" bundle:nil];
    
    //Sets the title for the listingDetailViewController
    [dealDetailViewController setTitle:NSLocalizedString(@"Details", @"")];
    //sets the SettingsManager object
    [dealDetailViewController setSetm: [appDelegate setm]];
    //Sets the deal object
    [dealDetailViewController setBusinessObject: businessObject ];
    
    UIBarButtonItem *browseButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"dealBarBackItemTitle", @"") style:UIBarButtonItemStyleBordered target:nil action:nil];
    [[self navigationItem] setBackBarButtonItem:browseButton];
    [browseButton release];
    
    //Pushes the ListinDetailViewController into the navigationController	
    [self.navigationController  pushViewController:dealDetailViewController animated:YES];
    
    [dealDetailViewController release];
    
}

-(void)proceedWithBusinessDetails:(FavoriteBusiness *)businessObject{
    //call server to get a business object    
    
    [self addWaitingAlertOverCurrentView];
    
	EdirectoryAppDelegate *appDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    ARCAserver_businesses* service = [ARCAserver_businesses service];
    EdirectoryParserToWSSoapAdapter *adapter = [EdirectoryParserToWSSoapAdapter sharedInstance];
    [service setHeaders:[adapter getDomainToken]];
    service.logging = NO;
    
    float latitude =[appDelegate.setting.latitude floatValue];
    float longitude =[appDelegate.setting.longitude floatValue];
    
    if(latitude == 0.0f && longitude == 0.0f) {
        latitude = self.userLocation.latitude;
        longitude = self.userLocation.longitude;
    }
    
    
    //call server to obtain a specific business object
    NSLog(@"ID: %i; LL: %f,%f", [[businessObject BusinessId] intValue],latitude, longitude);
    [service getAllBusinessForID:self action:@selector(getAllBusinessForIDHandler:) 
                     business_id:(NSDecimalNumber *)[NSDecimalNumber numberWithInt: [[businessObject BusinessId] intValue] ] 
                        latitude:latitude longitude:longitude foursquare_id:nil];
    
    
}

-(void)proceedWithDetails:(ARCAReview *)reviewObject{
    
    //go to the review Detail
    ReviewDetailViewController *reviewDetail = [[ReviewDetailViewController alloc] initWithNibName:@"ReviewDetailViewController"bundle:nil];
    
    [reviewDetail setReviewObject: reviewObject];

    // Pass the selected object to the new view controller.
    [[self navigationController] pushViewController:reviewDetail animated:YES];
    
    [reviewDetail release];
    
}
- (void)cancel:(id)sender{
    UIBarButtonItem *editButton = [[[UIBarButtonItem alloc]
                                      initWithTitle:@"Edit"
                                      style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(handleEditPress:)]
                                     autorelease];
    
    [self.navigationItem setLeftBarButtonItem:editButton animated:NO];    
    

    //determines wich tableview is visible at this moment
    if ([[[placeholderView subviews] objectAtIndex:0] isEqual: self.myReviewsContentView ]) {
        [self.myReviewsTableViewController.tableView setEditing:NO animated:YES];
    }else if([[[placeholderView subviews] objectAtIndex:0] isEqual: self.favoriteContentViews ]){
        [self.favoritesTableViewController.tableView setEditing:NO animated:YES];
    }
    
}

-(IBAction)handleEditPress:(id)sender{

    
    UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc]
                                      initWithTitle:@"Done"
                                      style:UIBarButtonItemStyleDone
                                      target:self
                                      action:@selector(cancel:)]
                                     autorelease];

    [self.navigationItem setLeftBarButtonItem:cancelButton animated:NO];    

    
    //determines wich tableview is visible at this moment
    if ([[[placeholderView subviews] objectAtIndex:0] isEqual: self.myReviewsContentView ]) {
        [self.myReviewsTableViewController.tableView setEditing:YES animated:YES];
    }else if([[[placeholderView subviews] objectAtIndex:0] isEqual: self.favoriteContentViews ]){
        [self.favoritesTableViewController.tableView setEditing:YES animated:YES];        
    }

    
}



#pragma mark - EdirectoryUserLocationDelegate Methods
//This is called by the eDirectoryUserLocation when a new GPS location was successfully received
-(void) didReceivedNewLocation:(CLLocationCoordinate2D)newUserLocation{
    
    //holds the user location
    userLocation = newUserLocation;    
    NSLog(@"New LL: %f, %f", userLocation.latitude, userLocation.longitude);
    
}
//This is called by the eDirectoryUserLocation when an Error message was received
-(void) didReceiveAnErrorMessage:(NSError *)error{}
//This is called by the eDirectoryUserLocation to inform a delegate that the Locations service for iPhone is disabled
-(void) locationsServiceIsNotEnable{ }

//This is called by the eDirectoryUserLocation when LocationManager is still waiting to Location results after 30 secs.
-(void) didHitTheMaximumTimeIntervalWithNoResults{
    
}





#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        
        EdirectoryAppDelegate *appDelegate = (EdirectoryAppDelegate *) [[UIApplication sharedApplication] delegate];
        
        [chooseProfileViewController setTitle: NSLocalizedString(@"ProfileNecessary", @"")];
        [chooseProfileViewController setSetm: [appDelegate setm] ];
        [chooseProfileViewController setHideFacebook:NO];
        [chooseProfileViewController setDelegate:self];
        [chooseProfileViewController hidesTheBackButton];
        
        [[self navigationController] pushViewController:chooseProfileViewController animated: YES];
        
    }
    
}

- (void) settingDidLogout: (NSNotification *) notification {
    
    [myReviewsTableViewController setDatasourceArray: nil];
    [myReviewsTableViewController.tableView reloadData];
    
}






@end
