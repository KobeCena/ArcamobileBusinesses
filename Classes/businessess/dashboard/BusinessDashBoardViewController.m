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

#import "BusinessDashBoardViewController.h"
#import "MapViewController.h"
#import "Listing.h"
#import "ARCACategories.h"
#import "EdirectoryAppDelegate.h"
#import "EdirectoryXMLParser.h"
#import "EDirectoryUserLocation.h"
#import "Setting.h"
#import "RpDashBoardButton.h"
#import "BusinessListViewController.h"
#import "CoreUtility.h"
#import "ARCAserver_businesses.h"
#import "EdirectoryParserToWSSoapAdapter.h"

@interface BusinessDashBoardViewController()
    @property (nonatomic, retain) NSString *xmlOperation;
@end

@implementation BusinessDashBoardViewController




#define KOPerationKeyword @"Keyword"
#define KOPerationDasboard @"DashBoard"


#pragma mark -
#pragma mark Properties Synthetizing

@synthesize mapViewController;
@synthesize lblLoadingDash;
@synthesize listingList;
@synthesize inTypeLabel;
@synthesize distanceLabel;
@synthesize setting;
@synthesize edirectoryUserLocation;

@synthesize dashboard;
@synthesize dashboardLock;
@synthesize dashBoardItems;

@synthesize xmlOperation;
@synthesize searchText;
@synthesize topMessageLabel;
@synthesize imgBgSearch;


#pragma mark -
#pragma mark Memory Management
- (void)dealloc {
	
	[setting                release];
	[inTypeLabel            release];
	[distanceLabel          release];
	[mapViewController      release];
	[edirectoryUserLocation release];
    [labelNear              release];
    [labelDistance          release];
    [dashboard              release];
    [xmlOperation           release];
    [dashboardLock          release];
    [dashBoardItems         release];
    [searchText             release];
    [topMessageLabel        release];
    [imgBgSearch release];
    [lblLoadingDash release];
    [super                  dealloc];
}


- (void) removeAllInvisibleButtons {
    for (id buttons in self.view.subviews) {
        if ([buttons isKindOfClass:[UIButton class]]) {
            UIButton *tmp = (UIButton *) buttons;
            if (tmp.tag == 999) {
                [tmp removeFromSuperview];
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark -
#pragma mark UIView Life cycle management

-(void)viewWillAppear:(BOOL)animated {

	/*for(UIView *view in self.tabBarController.tabBar.subviews) {  
		if([view isKindOfClass:[UIImageView class]]) {  
			[view removeFromSuperview];  
		}  
	}  
	
	[self.tabBarController.tabBar insertSubview:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tabBar02.png"]] autorelease] atIndex:0];  */
    
    
    
    [searchText setPlaceholder: NSLocalizedString(@"searchPlaceholderText", nil)];
    
    EdirectoryAppDelegate *thisDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([thisDelegate showText]) {
        [self showMessageTopLabel];
    }else{
        [self hideMessageTopLabel];
    }    
    
	NSString *nearType;
	NSString *distance;
	
	if ([self.setting.isNearMe boolValue]) {
		nearType = NSLocalizedString(@"Me", nil);
	} else if (self.setting.city != nil) {
		nearType = [NSString stringWithFormat:@"%@, %@", self.setting.city.name, self.setting.city.state.abbreviation];
	} else {
		nearType = self.setting.zipCode;
	}
	
	distance = [NSString stringWithFormat:@"%d %@", [[[self setting] distance] intValue] , NSLocalizedString(@"DistancePlural", @"")  ];
	
	[self.inTypeLabel setText: nearType];
	[self.distanceLabel setText: distance];

}

-(void)viewDidLoad{
    
    [super viewDidLoad];
	 
    [lblLoadingDash setText:NSLocalizedString(@"LoadingDashItems", @"")];
	
	//Initializes the EdirectoryUserLocation
	EdirectoryUserLocation * tmpUserLocation = [EdirectoryUserLocation alloc];
	self.edirectoryUserLocation = tmpUserLocation;
	self.edirectoryUserLocation.delegate = self;
	
	[tmpUserLocation release];
	
    
    [labelNear setText: NSLocalizedString(@"Near", @"")];
    [labelDistance setText:NSLocalizedString(@"Distance", @"")];
    
    
	//Gets the URL string from a plist file
	NSString *path = [[NSBundle mainBundle] pathForResource:@"ConnectionStrings" ofType:@"plist"];		
	NSDictionary *connPlist = [NSDictionary dictionaryWithContentsOfFile:path];
    
    
    BOOL b1 = [RpCacheController cacheisExpired];
    BOOL b2 = [RpCacheController fileExistInCache:[[connPlist objectForKey:@"DealDashboard"] lastPathComponent]] ;
    
	//ARCAserver_businesses* service = [ARCAserver_businesses service];
	//service.logging = YES;    
    
    EdirectoryParserToWSSoapAdapter * adapter = [EdirectoryParserToWSSoapAdapter sharedInstance];
    [adapter setDelegate:self];
    
    
    //call RpCacheController to see if we need request the dashboard items from server
    if ( b1 || !(b2) ) {
        //sets the operation DASHBOARD for parser
        self.xmlOperation = KOPerationDasboard;
        [adapter getAllCategories];
    }else{
        
        if (b2) {
            //There's a cached copy for the dashboard XML structure. So, load it.
            
            //sets the operation DASHBOARD for parser
            self.xmlOperation = KOPerationDasboard;
            [adapter getAllCategories];            
        }
        
    }
    

}

// Handle the response from getAllCategories.

- (void) getAllCategoriesHandler: (id) value {
    
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		return;
	}
    
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		return;
	}				
    
	// Do something with the ARCAArrayCategories* result
    ARCAArrayCategories* result = (ARCAArrayCategories*)value;
    
}


- (void)viewDidUnload {
    [labelNear release];
    labelNear = nil;
    [labelDistance release];
    labelDistance = nil;
    [self setDashboardLock:nil];
    [self setTopMessageLabel:nil];
    [self setImgBgSearch:nil];
    [self setLblLoadingDash:nil];
    [super viewDidUnload];
}


#pragma mark -
#pragma mark Listing Search Methods

- (void) searchByKeyWord:(NSString *)keyWord withLatitude:(double)newUserLatitude withLongitude:(double)newUserLongitude{
	
	NSString *nearType;
	
	//deactives the "List" button
	[[[self mapViewController] buttonList] setEnabled:NO];
	
	//double latitude = userLatitude;
	//double longitude = userLongitude;
	
	if ([[[self setting ]isNearMe] boolValue]) {
		nearType = @"nearme";
	} else {
		
//		if ([[self setting] zipCode] != NULL) {
		if (self.setting.zipCode != NULL && (![self.setting.zipCode isEqualToString:@""])  ) {
			nearType = @"zipcode";
		}else {
			nearType = @"location";
		}
		
	}

	
	//Gets the URL string from a plist file
	NSString *path = [[NSBundle mainBundle] pathForResource:@"ConnectionStrings" ofType:@"plist"];		
	NSDictionary *connPlist = [NSDictionary dictionaryWithContentsOfFile:path];
	
	NSString *urlString = [NSString stringWithFormat:
						   [connPlist objectForKey:@"Nearby"]
						   ,[keyWord stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], 
						   nearType, 
						   //setting.zipCode!=nil ? setting.zipCode : @"", 
						   (setting.zipCode != nil) ? [setting.zipCode stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] : @"", 
						   [setting.distance stringValue], 
						   newUserLatitude, 
						   newUserLongitude,
						   [setting.city.state.country.country_id intValue],
						   [setting.city.state.state_id intValue],
						   [setting.city.city_id intValue]];
	
	
	//Shows the "waiting" screen
	[self.mapViewController.searching setHidden:NO];	
	[self.mapViewController.view setUserInteractionEnabled:NO];
	
	//Only remove the annotations if they exists
	if ([self.mapViewController.mapView.annotations count] >0) {
		[self.mapViewController.mapView removeAnnotations:self.mapViewController.mapView.annotations ];
	}
	
	//Hides our custom BubbleInfoView
	if ( [self.mapViewController.draggViewController view].hidden == NO) {
		[self.mapViewController.draggViewController view].hidden = YES;
	} 
	
    [self.mapViewController setTitle:NSLocalizedString(@"NearbyResults", @"")];


	//Pushes the mapViewControler into the navigationController
	[[self navigationController] pushViewController:mapViewController animated:YES];
	
    
    self.xmlOperation = KOPerationKeyword;
	//TODO: Fazer chamada para Adpater

	
}


#pragma mark EdirectoryXMLParserDelegate methods
//Called by the parser when the latitude and logitude of the searchable region is received
- (void)parserDidReceiveSearchResultsPosition:(double)latitude withLongitude:(double)longitude{
	
    userLatitude = latitude;
    userLongitude = longitude;
    
    
    if ([self.xmlOperation isEqualToString:KOPerationKeyword]) {

        //this line of code grants that we always show the user location, fake or not.
        [self.mapViewController.mapView setShowsUserLocation:YES];
        [self.mapViewController gotoLocation:latitude newLongitude:longitude];
    }
    
    if ([self.xmlOperation isEqualToString:KOPerationDasboard]) {
        
    }
}

//Called by the parser everytime that listingResults is updated with a bunch of data
- (void)parserDidUpdateData:(NSArray *)objectResults{

    if ([self.xmlOperation isEqualToString:KOPerationKeyword]) {
        self.listingList = objectResults;
    }
    
    if ([self.xmlOperation isEqualToString:KOPerationDasboard]) {    
        self.dashBoardItems = objectResults;
    }
}


// Called by the parser when parsing is finished.
- (void)parserDidEndParsingData:(NSArray *)objectResults{

    if ([self.xmlOperation isEqualToString:KOPerationKeyword]) {	
        
        //Hides the "waiting" screen
        [self.mapViewController.searching setHidden:YES];
        [self.mapViewController.view setUserInteractionEnabled:YES];
        [self.mapViewController.mapView setShowsUserLocation:NO];
        if (![[[self setting ]isNearMe] boolValue]) {
            
            [self.mapViewController.mapView setShowsUserLocation:YES];
            
        }
        
        if ([objectResults count] >0) {
        
            [self.mapViewController setListings:self.listingList];
            [self.mapViewController.mapView performSelectorOnMainThread: @selector(addAnnotations:) withObject: self.listingList waitUntilDone: YES];
            
            
            if (userLatitude == 0 && userLongitude == 0) {
                [self.mapViewController zoomToFitMapAnnotations];
            }else {
                [self.mapViewController gotoLocation:userLatitude newLongitude:userLongitude];
            }
        }
        
        
    }	
	
    if ([self.xmlOperation isEqualToString:KOPerationDasboard]) {
        [self.dashboard reloadData];
        [self.dashboardLock setHidden:YES];
    }
	
}

// Called by the parser when no listingResults were found
- (void)noResultsWereFound{
	
    if ([self.xmlOperation isEqualToString:KOPerationKeyword]) {
    
        //Hides the "waiting" screen
        [self.mapViewController.searching setHidden:YES];
        [self.mapViewController.view setUserInteractionEnabled:YES];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"NoResults", @"")
                                                        message: NSLocalizedString(@"NoResultsFound",@"")
                                                       delegate:self 
                                              cancelButtonTitle: NSLocalizedString(@"OK" , @"")
                                              otherButtonTitles:nil
                              ];
        [alert show];
        [alert release];
    }
	
    if ([self.xmlOperation isEqualToString:KOPerationDasboard]) {
        
    }

}

- (void)parserDidReceivedRawData:(NSData *)data{
    
	//Gets the URL string from a plist file
	NSString *path = [[NSBundle mainBundle] pathForResource:@"ConnectionStrings" ofType:@"plist"];
	NSDictionary *connPlist = [NSDictionary dictionaryWithContentsOfFile:path];
	
	NSString *name = [[connPlist objectForKey:@"DealDashboard"] lastPathComponent];

        
    //writes the rawfile into cache
    RpCacheController* cacheController = [[RpCacheController alloc] initForCheck];
    [cacheController writeDataIntoCache:data withName:name];
    [cacheController release];
    
}



- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (Setting *)setting {
	
	EdirectoryAppDelegate *thisDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
	setting = [thisDelegate setting];
	return setting;
}


#pragma mark -
#pragma mark EdirectoryUserLocationDelegate Methods
//This is called by the eDirectoryUserLocation when a new GPS location was successfully received
-(void) didReceivedNewLocation:(CLLocationCoordinate2D)newUserLocation{
	
	userLatitude = newUserLocation.latitude;
	userLongitude = newUserLocation.longitude;	
	
	//proceed with the nearby flow
	[self searchByKeyWord:actualKeyword withLatitude:userLatitude withLongitude:userLongitude];

	[self.mapViewController gotoLocation:userLatitude newLongitude:userLongitude];
	[self.mapViewController.mapView setShowsUserLocation:YES];



}
//This is called by the eDirectoryUserLocation when an Error message was received
-(void) didReceiveAnErrorMessage:(NSError *)error{}
//This is called by the eDirectoryUserLocation to inform a delegate that the Locations service for iPhone is disabled
-(void) locationsServiceIsNotEnable{}

//This is called by the eDirectoryUserLocation when LocationManager is still waiting to Location results after 30 secs.
-(void) didHitTheMaximumTimeIntervalWithNoResults{
	UIAlertView *maximumTimeIntervalAlert = [[UIAlertView alloc] 
                                             initWithTitle: NSLocalizedString(@"NoGPSResults", @"")
                                             message: NSLocalizedString(@"NoGPSResultsMessage", @"") 
                                             delegate:nil 
                                             cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                             otherButtonTitles:nil];
	[maximumTimeIntervalAlert show];
	[maximumTimeIntervalAlert release];

}

-(IBAction)callSettingViewController:(id)sender {
	
	EdirectoryAppDelegate *thisDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
	[thisDelegate goToTheSetingsTab];
}


#pragma mark -
#pragma mark Methods for IBOutlet components
- (IBAction)textFieldFinishedEditing:(id)sender
{
	UITextField *whichTextField = (UITextField *)sender;
	[whichTextField resignFirstResponder];
}

#pragma mark - RpDashBoard Datasource Methods
- (NSUInteger)numberOfItemsInDashBoard:(RpDashBoard *)dashboard{
    return [self.dashBoardItems count];
}

- (NSUInteger)numberOfCollumnsInDashBoard:(RpDashBoard *)dashboard{
    return 3;
}

- (UIView *)dashboard:(RpDashBoard *)dashboard viewForItemAtIndex:(NSUInteger)index{
    
    RpDashBoardButton* button = [RpDashBoardButton buttonWithType:UIButtonTypeCustom];
    
    [button setBackgroundColor:[UIColor clearColor]];
    NSURL *url = [NSURL URLWithString:[(ARCACategories*)[self.dashBoardItems objectAtIndex:index] icon]];
    [button setButtonImageURL:url];
    
    
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    NSNumber *aNumber = [NSNumber numberWithInteger: index ];    
    [button setButtonIndex:aNumber];

    return button;
}

- (NSString *)dashboard:(RpDashBoard *)dashboard titleForItemAtIndex:(NSUInteger)index{
    return [(ARCACategories*)[self.dashBoardItems objectAtIndex:index] title];
}

- (NSUInteger)amountOfHorizontalSpace:(RpDashBoard *)dashboard{
    return 40;

}

- (NSUInteger)amountOfVerticalSpace:(RpDashBoard *)dashboard{
    return 24;
}

- (NSDate *)lastUpdateFromServer:(RpDashBoard *)dashboard{
    //return [self.edirectoryXMLParser lastUpdate];
    //TODO: FAczer chamada ao Adapter
    return [NSDate date];
}
        

#pragma mark - RpDashBoard Delegate Methods
- (void)dashboardDidPressButton:(RpDashBoard *)dashboard atIndex:(NSUInteger) index{
    
    //sets the operation for Parser
    self.xmlOperation = KOPerationDasboard;
    
    
    //gets the appropriate object from Array
    ARCACategories *categoryObj = (ARCACategories*)[self.dashBoardItems objectAtIndex:index] ;    
    
    BusinessListViewController *businessList = [[BusinessListViewController alloc] initWithNibName:@"BusinessListViewController" bundle:nil];

    
    [businessList setCategoryId:[[categoryObj _id] integerValue] ];
    [businessList setKeyword:nil];
    [businessList setPlaceHolderCategName:[categoryObj title]];
    [businessList setTitle: [(ARCACategories*)[self.dashBoardItems objectAtIndex:index] title]];
    [businessList setBusinessArray:[NSArray array]];
    [businessList.tableView reloadData];
    
	UIBarButtonItem *browseButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"dealBarBackItemTitle", @"") style:UIBarButtonItemStyleBordered target:nil action:nil];
	[[self navigationItem] setBackBarButtonItem:browseButton];
	[browseButton release];
    
    
    [[self navigationController] pushViewController:businessList animated:YES];
    
    
    [businessList release];
}

- (void)dashboardDidScrollToPage:(RpDashBoard *)dashboard atIndex:(NSUInteger) index{

}


-(IBAction)doReloadAgain:(id)sender{
    [self.dashboard reloadData];
}

#pragma mark - TextFieldDelegate Methods
// called when 'return' key pressed. 
- (BOOL)textFieldShouldReturn:(UITextField *)textField{

    
    if(! isEmpty(textField.text) ){

        //sets the operation for Parser
        self.xmlOperation = KOPerationKeyword;
        
        BusinessListViewController *dealsList = [[BusinessListViewController alloc] initWithNibName:@"BusinessListViewController" bundle:nil];
        
        [dealsList setKeyword: [NSString stringWithString:textField.text] ];
        [dealsList setCategoryId: [[NSNumber numberWithInt:0] intValue]  ];
        [dealsList setPlaceHolderCategName:@""];
        [dealsList setTitle: @"Search Results"];
        [dealsList setBusinessArray:[NSArray array]];
        [dealsList.tableView reloadData];
        
        UIBarButtonItem *browseButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"dealBarBackItemTitle", @"") style:UIBarButtonItemStyleBordered target:nil action:nil];
        [[self navigationItem] setBackBarButtonItem:browseButton];
        [browseButton release];
        
        
        [[self navigationController] pushViewController:dealsList animated:YES];
        
        [dealsList release];
        
    }
    
	//[textField resignFirstResponder];
    [self removeAllInvisibleButtons];
    return YES;
}


-(IBAction)handleButtonDismissKeyboard:(id)sender {
    [searchText resignFirstResponder];
    [self removeAllInvisibleButtons];
}

- (IBAction)textSearchEditBegin:(id)sender {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, searchText.frame.origin.y + searchText.frame.size.height + 20, 320, 480)];
    [button setTag:999];
    [button addTarget:self action:@selector(handleButtonDismissKeyboard:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [button setAlpha:0.5f];
    [button setBackgroundColor: [UIColor blackColor]];
    [self.view addSubview:button];
    [self.view bringSubviewToFront:button];
    [button release];
}


- (void) showMessageTopLabel { 
    
//    [self.topMessageLabel setHidden:NO];
//    [self.topMessageLabel setText:NSLocalizedString(@"noBusinessNearby", nil)];  
//    
//    CGRect dashRect = [dashboard frame];
//    dashRect.origin.y = 101; 
//    [dashboard setFrame:dashRect];
//    
//    CGRect bgRect = [imgBgSearch frame];
//    bgRect.size.height = 105;
//    [imgBgSearch setFrame:bgRect];
}

- (void) hideMessageTopLabel { 
    
//    [self.topMessageLabel setHidden:YES];
//    [self.topMessageLabel setText:NSLocalizedString(@"noBusinessNearby", nil)];
//    
//    CGRect dashRect = [dashboard frame];
//    dashRect.origin.y = 61; 
//    [dashboard setFrame:dashRect];
//    
//    CGRect bgRect = [imgBgSearch frame];
//    bgRect.size.height = 65;
//    [imgBgSearch setFrame:bgRect];
}

@end
