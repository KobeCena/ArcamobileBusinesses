    //
//  ArcaMobileDealsViewController.m
//  ArcaMobileDeals
//
//  Created by Ricardo Silva on 5/12/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import "BusinessNearbyViewController.h"
#import "Deal.h"
#import "CoreUtility.h"
#import "EdirectoryAppDelegate.h"
#import "BusinessDetailsViewController.h"
#import "EdirectoryParserToWSSoapAdapter.h"
#import "ARCABusinesses.h"
#import "ListingAnnotationView.h"
#import "ARCAserver_businesses.h"
#import "RpDashBoardButton.h"
#define ITEM_SPACING 210

@implementation BusinessNearbyViewController

@synthesize carousel;
@synthesize mapViewController;
@synthesize edirectoryXMLParser;
@synthesize resultsLabel;
@synthesize resultsButton;
@synthesize objectsDatasource;
@synthesize edirectoryUserLocation;
@synthesize userLocation;
@synthesize setting;
@synthesize topMessageLabel;
@synthesize businessNameLabel;
@synthesize businessDistanceLabel;
@synthesize businessAddressLabel;
@synthesize dealMapMesageLabel;
@synthesize alertView;
@synthesize alertLabel;
@synthesize businessDescriptionTextView;
@synthesize lblNoNearbyTip;
@synthesize operation;
@synthesize cacheController;
@synthesize carousselDatasourceItems;

// image reflection
static const CGFloat kDefaultReflectionFraction = 0.15;
static const CGFloat kDefaultReflectionOpacity = 0.40;
static const NSInteger kSliderTag = 1337;

//just hide the elements while load
-(void)hideElementsWhileReload:(BOOL)hideOption{
    [self.topMessageLabel setHidden:hideOption];
    [self.dealMapMesageLabel setHidden:hideOption];
    [self.resultsButton setHidden:hideOption];
    [self.businessAddressLabel setHidden:hideOption];
    [self.businessDistanceLabel setHidden:hideOption];
    [self.businessNameLabel setHidden:hideOption];
    [self.lblNoNearbyTip setHidden:hideOption];

}


#pragma mark - Blocks the screen
-(void)addWaitingAlertOverCurrentView{
    //ALERT MESSAGE
    //hide the elements
    [self hideElementsWhileReload:YES];
    //blocks this view
    [self.view setUserInteractionEnabled:NO];
    
    [self.view addSubview:alertView];
    alertView.backgroundColor = [UIColor clearColor];
    alertView.center = self.view.center;
    self.alertView.alpha = 1.0;
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
    [self performSelector:@selector(updateText:) withObject:NSLocalizedString(@"dealWaitNearbyDeals", @"") afterDelay:0.0];
}

- (void)updateText:(NSString *)newText
{
    self.alertLabel.text = newText;
}
- (void)finalUpdate
{
    //Unblocks this view
    [self.view setUserInteractionEnabled:YES];
        
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
}




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
    [carousel                   release];
    [mapViewController          release];
    [edirectoryXMLParser        release];
    [resultsLabel               release];
    [resultsButton              release];
    [objectsDatasource          release];
    [edirectoryUserLocation     release];
    [setting                    release];
    [operation                  release];
    [cacheController            release];
    [carousselDatasourceItems   release];
    
    [topMessageLabel release];
    [businessNameLabel release];
    [businessDistanceLabel release];
    [businessAddressLabel release];
    [dealMapMesageLabel release];
    [alertView release];
    [alertLabel release];
    [businessDescriptionTextView release];
    [lblNoNearbyTip release];
    [super                      dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)startParser{
	
    isCancelled = FALSE;
    
	NSString *nearType;
		
	if ([[[self setting ]isNearMe] boolValue]) {
		nearType = @"nearme";
	} else {
		if (self.setting.zipCode != NULL && (![self.setting.zipCode isEqualToString:@""])  ) {
			nearType = @"zipcode";
		}else {
			//nearType = @"location";
            nearType = [NSString stringWithFormat:@"%i", [self.setting.city.city_id intValue]];
		}
	}    
    
    EdirectoryParserToWSSoapAdapter * adapter = [EdirectoryParserToWSSoapAdapter sharedInstance];
    [adapter setDelegate:self];
    
    [adapter getAllNearbyBusiness:@"" //keyword
                       nearbyType:nearType  
                          zipCode:(setting.zipCode != nil) ? [setting.zipCode stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] : @"" 
                      nearbyRange:[setting.distance intValue]
                         latitude:userLocation.latitude 
                        longitude:userLocation.longitude 
                             page:0];
    
}

-(void)cancelNearbyDeals{
    isCancelled = TRUE;
}


-(void)applyTheme {
    
    //gets a reference to application delegate
	EdirectoryAppDelegate *appDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate.themeSettings configureLabel:self.businessNameLabel withTheme:THEME_LABEL_LEVEL1];
    [appDelegate.themeSettings configureLabel:self.businessDistanceLabel withTheme:THEME_LABEL_LEVEL4];    
    [appDelegate.themeSettings configureLabel:self.businessAddressLabel withTheme:THEME_LABEL_LEVEL3];        
    
}

#pragma mark - View lifecycle
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSLog(@"will appear");
    
    [self applyTheme];
    
	/*for(UIView *view in self.tabBarController.tabBar.subviews) {  
		if([view isKindOfClass:[UIImageView class]]) {  
			[view removeFromSuperview];  
		}  
	}  
	
	[self.tabBarController.tabBar insertSubview:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tabBar01.png"]] autorelease] atIndex:0];  */
}


- (void)viewDidLoad
{
    [super viewDidLoad];
        
    
    //verify if this is the FIRSTRUN
    EdirectoryAppDelegate *thisDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
     
    if ([thisDelegate verifyFirstRun] && [[[thisDelegate setting] zipCode] isEqualToString:@"20001"]) {        
        [[self setting] setIsNearMe: [NSNumber numberWithBool:YES] ];
    }
    
    //init the cacheController
    self.cacheController = [[RpCacheController alloc] initWhithLastUpdateFromServer:[NSDate date]];
    //sets the delegate
    self.cacheController.delegate = self;
    
    
    //defines the operation for this screenyes
    [self setOperation:DEALS_NEARBY_OPERATION1];
    
    //defines the carousel type
    carousel.type = iCarouselTypeCoverFlow;
    
    
	//Initializes the EdirectoryXMLParser
	EdirectoryXMLParser * tmpParser = [[EdirectoryXMLParser alloc] initXMLParserDelegate];
	tmpParser.delegate = self;
	self.edirectoryXMLParser = tmpParser;
	[self.edirectoryXMLParser setMaximumNumberOfObjectsToParse:100];
    [self.edirectoryXMLParser setRootElementName:@"eDirectoryData"];
    [self.edirectoryXMLParser setLogEnabled:NO];
	[tmpParser release];
    
	//Initializes the EdirectoryUserLocation
	EdirectoryUserLocation * tmpUserLocation = [EdirectoryUserLocation alloc];
	self.edirectoryUserLocation = tmpUserLocation;
	self.edirectoryUserLocation.delegate = self;
	
	[tmpUserLocation release];
    
    //from now on the screen flow will be managed by the EdirectoryUserLocationDelegate methods !
    [self.edirectoryUserLocation setupEdirectoryUserLocation]; 
    
    [self.mapViewController setDisableHideWhenMapTouched:NO];
    
    //show the detail button
    self.mapViewController.draggViewController.detailButton.hidden = NO;

}

- (void)viewDidUnload
{
    [self setTopMessageLabel:nil];
    [self setDealMapMesageLabel:nil];
    [self setAlertView:nil];
    [self setAlertLabel:nil];
    [self setBusinessDescriptionTextView:nil];
    [self setLblNoNearbyTip:nil];
    [super viewDidUnload];
    self.carousel = nil;
}

#pragma mark - Show deals on Map
-(void)showDealsOnMap{
	//Shows the "waiting" screen
	[self.mapViewController blockMapView];
	
	//Only remove the annotations if they exists
	if ([self.mapViewController.mapView.annotations count] >0) {
		[self.mapViewController.mapView removeAnnotations:self.mapViewController.mapView.annotations ];
	}
	
	//Hides our custom BubbleInfoView
	if ( [self.mapViewController.draggViewController view].hidden == NO) {
		[self.mapViewController.draggViewController view].hidden = YES;
	} 
	
    [self.mapViewController setTitle:NSLocalizedString(@"NearbyDeals", @"")];
    
    
	UIBarButtonItem *browseButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Browse", @"") style:UIBarButtonItemStyleBordered target:nil action:nil];
	[[self navigationItem] setBackBarButtonItem:browseButton];
	[browseButton release];
	
	//Pushes the mapViewControler into the navigationController
	[[self navigationController] pushViewController:mapViewController animated:YES];
    
}


#pragma mark - Parser Methods
//Called by the parser when the latitude and logitude of the searchable region is received
- (void)parserDidReceiveSearchResultsPosition:(double)latitude withLongitude:(double)longitude{
    
    //proceeds only if users did not cancel the operation
    if (!isCancelled) {
        userLocation = CLLocationCoordinate2DMake(latitude, longitude);
    }
    
}

//Called by the parser when the results array was created
- (void)parserDidCreatedResultsArray:(NSArray *)objectResults{

    //proceeds only if users did not cancel the operation
    if (!isCancelled) {
        
    }
    
    
}

//Called by the parser when the numbers for paging navigation is received
- (void)parserDidReceivePagingNumbers:(int)totalNumberOfPages wichPage:(int)actualPage{

    //proceeds only if users did not cancel the operation
    if (!isCancelled) {
        
    }
    
    
}

//Called by the parser everytime that listingResults is updated with a batch of data
- (void)parserDidUpdateData:(NSArray *)objectResults{

    //proceeds only if users did not cancel the operation
    if (!isCancelled) {
        
    }
    
}

// Called by the parser when parsing is finished.
- (void)parserDidEndParsingData:(NSArray *)objectResults{
    
    //init the array of buttons for the carouseldatasource
    self.carousselDatasourceItems = [NSMutableDictionary dictionary];

    //enable the REFRESH button to prevent multiple server requests and avoi crashes inside the app
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
    
    
    //proceeds only if users did not cancel the operation
    if (!isCancelled) {
        
        if ([objectResults count] > 0) {
            

            //defines the carousel type
            carousel.type = iCarouselTypeCoverFlow;

            
            //unblocks this screen
            [self finalUpdate];
            
            //show the elements
            [self hideElementsWhileReload:NO];                
            
            //retain all deals found nearby into this class
            self.objectsDatasource = [NSArray arrayWithArray:objectResults];
            

            //only post the operation if the app is loading
            if ([self.operation isEqualToString:DEALS_NEARBY_OPERATION1]) {
                //post a notification
                [[NSNotificationCenter defaultCenter] postNotificationName:DEALS_FINISHED object:self];
            }
            
            //enable the REFRESH button to prevent multiple server requests and avoi crashes inside the app
            [[[self navigationItem] rightBarButtonItem] setEnabled:YES];

            
            //update screen
            NSString * basePoint = [NSString string];
            
            if ([self.setting.isNearMe boolValue]) {
                basePoint = NSLocalizedString(@"NearYou", @"");
            } else if (self.setting.city != nil) {
                basePoint = [NSString stringWithFormat:@"%@, %@", self.setting.city.name, self.setting.city.state.abbreviation];
            } else {
                basePoint = self.setting.zipCode;
            }            
            
            [self.topMessageLabel setText:[NSString stringWithFormat:NSLocalizedString(@"businessTopMesage", nil),
                                           [objectResults count],
                                           [[setting distance] intValue],
                                           basePoint]];
            
            
            
            
            
            //verify if this is the FIRSTRUN
            /*EdirectoryAppDelegate *thisDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
            
            if ([thisDelegate verifyFirstRun] && [[[thisDelegate setting] zipCode] isEqualToString:@"20001"]) {        

                //[self setTitle:[NSString stringWithFormat:@"%@ nearby", [[thisDelegate setting] zipCode] ]];                
                
                NSString *messageTitle = [NSString stringWithFormat:@" %@ %@", NSLocalizedString(@"FirstRunTitleMessage", nil), [[thisDelegate setting] zipCode] ];
                
                
                UIAlertView *alertErrorView = [[UIAlertView alloc] 
                                               initWithTitle:messageTitle 
                                               message:NSLocalizedString(@"FirstRunBodyMessage", nil)
                                               delegate:self
                                               cancelButtonTitle:@"CANCEL"
                                               otherButtonTitles:@"OK", nil
                                               ];

                [alertErrorView show];
                [alertErrorView release];
                
                
            }*/
            
            
            
            
            
        }
        
    }
    
    [carousel reloadData];
    [carousel.delegate carouselCurrentItemIndexUpdated:self.carousel];
    
    
    
    EdirectoryAppDelegate *thisDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
    if([objectResults count] > 0) {
        [thisDelegate setShowText:NO];
        [thisDelegate.dashboardViewController hideMessageTopLabel];
    } else {
        [thisDelegate setShowText:YES];
        [thisDelegate.dashboardViewController showMessageTopLabel];
    }
}

//Parser will call this method just to notify delegates that an error was occurred.
//This method will be usefull for further delegates that will need to know when an error occurred
//during the data parsing to be able to release any holded objects or release/dismiss any graphic Object.
- (void)parserEndWithError:(BOOL)hasErrors{
    
    //proceeds only if users did not cancel the operation
    if (!isCancelled) {
        
        //unblocks this screen
        [self finalUpdate];
        [self.topMessageLabel setHidden:NO];
        
        if ([self.objectsDatasource count] > 0) {
            //show the elements
            [self hideElementsWhileReload:NO];
        }
    }
    
}

// Called by the parser when no listingResults were found
- (void)noResultsWereFound{
    
    //proceeds only if users did not cancel the operation
    if (!isCancelled) {
        
        //updates text on the screen
        [self.topMessageLabel setText:NSLocalizedString(@"noBusinessNearby", nil)];
        [self.lblNoNearbyTip setText:NSLocalizedString(@"noBusinessNearbyTip", nil)];
        [self.lblNoNearbyTip setHidden: NO];
        [self.businessDistanceLabel setText:@""];
        [self.businessAddressLabel setText:@""];
        [self.dealMapMesageLabel setText:@""];
        [self.businessNameLabel setText:@""];
        [self.resultsButton setHidden:YES];
        [self.topMessageLabel setHidden:NO];
        [self.businessDescriptionTextView setText:@""];
        
        //only post the operation if the app is loading
        if ([self.operation isEqualToString:DEALS_NEARBY_OPERATION1]) {
            [[NSNotificationCenter defaultCenter] postNotificationName: DEALS_FINISHED_NO_RESULTS object:self];
        }
        
        //unblocks this screen
        [self finalUpdate];        
    }    
    
    //enable the REFRESH button to prevent multiple server requests and avoi crashes inside the app
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];    
    
    //go to the "Deals" tab
    EdirectoryAppDelegate *thisDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
    //[thisDelegate goToThelistingsTab];
    [thisDelegate performSelectorOnMainThread:@selector(goToThelistingsTab) withObject:nil waitUntilDone:NO];    
    
}


#pragma mark - EdirectoryUserLocationDelegate Methods
//This is called by the eDirectoryUserLocation when a new GPS location was successfully received
-(void) didReceivedNewLocation:(CLLocationCoordinate2D)newUserLocation{
    
    //holds the user location
    userLocation = newUserLocation;    

    //init parser sendind device location data
    [self startParser];
    
}
//This is called by the eDirectoryUserLocation when an Error message was received
-(void) didReceiveAnErrorMessage:(NSError *)error{}
//This is called by the eDirectoryUserLocation to inform a delegate that the Locations service for iPhone is disabled
-(void) locationsServiceIsNotEnable{ }

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


#pragma mark - Button Methods
-(IBAction) handleButtonClick:(id)sender{
    
    [self showDealsOnMap];
    
    NSMutableArray * mapObjects = [NSMutableArray array];
    
    for (ARCABusinesses * businessObject in self.objectsDatasource) {
        
        Listing * annotation = [[[Listing alloc] init] autorelease];
        
        [annotation setLatitude:        [businessObject latitude]      ];
        [annotation setLongitude:       [businessObject longitude]     ];
        [annotation setMapTunning:      [businessObject maptuning]     ];
        [annotation setListingTitle:    [businessObject title]         ];
        [annotation setListingIcon:     [businessObject imageObject]   ];
        [annotation setAddress:         [businessObject address]       ];
        [annotation setRawAddress:      [businessObject full_address]  ];
        [annotation setListingID:       [[businessObject _id] integerValue] ];
        
        [mapObjects addObject:annotation];    
    }
    
    [self.mapViewController.draggViewController setLatitude: self.userLocation.latitude];
    [self.mapViewController.draggViewController setLongitude: self.userLocation.longitude];
    
    //proceed with the mapview flow for deals
    [self.mapViewController.mapView performSelectorOnMainThread: @selector(addAnnotations:) withObject: mapObjects waitUntilDone: YES];
    
    //[self.mapViewController gotoLocation:userLocation.latitude newLongitude:userLocation.longitude];
    [self.mapViewController zoomToFitMapAnnotations];
    
	//Unlock the mapView screen
	[self.mapViewController unBlockMapView];
    
}

#pragma mark - Image Reflection

CGImageRef CreateGradientImage(int pixelsWide, int pixelsHigh)
{
    CGImageRef theCGImage = NULL;
    
    // gradient is always black-white and the mask must be in the gray colorspace
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // create the bitmap context
    CGContextRef gradientBitmapContext = CGBitmapContextCreate(NULL, pixelsWide, pixelsHigh,
                                                               8, 0, colorSpace, kCGImageAlphaNone);
    
    // define the start and end grayscale values (with the alpha, even though
    // our bitmap context doesn't support alpha the gradient requires it)
    CGFloat colors[] = {0.0, 1.0, 1.0, 1.0};
    
    // create the CGGradient and then release the gray color space
    CGGradientRef grayScaleGradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
    CGColorSpaceRelease(colorSpace);
    
    // create the start and end points for the gradient vector (straight down)
    CGPoint gradientStartPoint = CGPointZero;
    CGPoint gradientEndPoint = CGPointMake(0, pixelsHigh);
    
    // draw the gradient into the gray bitmap context
    CGContextDrawLinearGradient(gradientBitmapContext, grayScaleGradient, gradientStartPoint,
                                gradientEndPoint, kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(grayScaleGradient);
    
    // convert the context into a CGImageRef and release the context
    theCGImage = CGBitmapContextCreateImage(gradientBitmapContext);
    CGContextRelease(gradientBitmapContext);
    
    // return the imageref containing the gradient
    return theCGImage;
}

CGContextRef MyCreateBitmapContext(int pixelsWide, int pixelsHigh)
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create the bitmap context
    CGContextRef bitmapContext = CGBitmapContextCreate (NULL, pixelsWide, pixelsHigh, 8,
                                                        0, colorSpace,
                                                        // this will give us an optimal BGRA format for the device:
                                                        (kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst));
    CGColorSpaceRelease(colorSpace);
    
    return bitmapContext;
}

- (UIImage *)reflectedImage:(UIImageView *)fromImage withHeight:(NSUInteger)height
{
    if(height == 0)
        return nil;
    
    // create a bitmap graphics context the size of the image
    CGContextRef mainViewContentContext = MyCreateBitmapContext(fromImage.bounds.size.width, height);
    
    // create a 2 bit CGImage containing a gradient that will be used for masking the 
    // main view content to create the 'fade' of the reflection.  The CGImageCreateWithMask
    // function will stretch the bitmap image as required, so we can create a 1 pixel wide gradient
    CGImageRef gradientMaskImage = CreateGradientImage(1, height);
    
    // create an image by masking the bitmap of the mainView content with the gradient view
    // then release the  pre-masked content bitmap and the gradient bitmap
    CGContextClipToMask(mainViewContentContext, CGRectMake(0.0, 0.0, fromImage.bounds.size.width, height), gradientMaskImage);
    CGImageRelease(gradientMaskImage);
    
    // In order to grab the part of the image that we want to render, we move the context origin to the
    // height of the image that we want to capture, then we flip the context so that the image draws upside down.
    CGContextTranslateCTM(mainViewContentContext, 0.0, height);
    CGContextScaleCTM(mainViewContentContext, 1.0, -1.0);
    
    // draw the image into the bitmap context
    CGContextDrawImage(mainViewContentContext, fromImage.bounds, fromImage.image.CGImage);
    
    // create CGImageRef of the main view bitmap content, and then release that bitmap context
    CGImageRef reflectionImage = CGBitmapContextCreateImage(mainViewContentContext);
    CGContextRelease(mainViewContentContext);
    
    // convert the finished reflection image to a UIImage 
    UIImage *theImage = [UIImage imageWithCGImage:reflectionImage];
    
    // image is retained by the property setting above, so we can release the original
    CGImageRelease(reflectionImage);
    
    return theImage;
}

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [objectsDatasource count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index
{
    
    
    ARCABusinesses * businessObject = (ARCABusinesses *)[objectsDatasource objectAtIndex:index ]; 
    
    RpDashBoardButton* button = [RpDashBoardButton buttonWithType:UIButtonTypeCustom] ;
    [button setFrame:CGRectMake(0, 0, 150, 148)];
    [button setBackgroundColor:[UIColor clearColor]];
    NSNumber *aNumber = [NSNumber numberWithInteger: index ];    
    [button setButtonIndex:aNumber];
    [button setButtonImageURL:[NSURL URLWithString:[businessObject imageURLString]]];
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    NSLog(@"Download da imagem %@ de índice %i", [businessObject imageURLString], index);    
    [[self carousselDatasourceItems] setObject:button forKey:aNumber];
    
//    BOOL b1 = [RpCacheController cacheisExpired];
//    BOOL b2 = [RpCacheController fileExistInCache:[[businessObject imageURLString] lastPathComponent]] ;
    
    //call RpCacheController to see if we need request the dashboard items from server
    //if ( b1 || !(b2) ) {
        //need to download
        [self.cacheController prepareCachedImage:[button buttonImageURL] forThisIndex:[[button buttonIndex] intValue]];
    /*}else{
        if (b2) {
            //There's a cached copy for the file. So, load it.
            NSLog(@"Loading image from cache");
            
            UIImage * buttonImage = [UIImage imageWithData:[RpCacheController getFileFromCache:[[businessObject imageURLString] lastPathComponent]]];
            [button setImage:buttonImage forState:UIControlStateNormal];
            [businessObject setImageObject:buttonImage];

        }
    }*/
    return button;

    
}

- (float)carouselItemWidth:(iCarousel *)carousel
{
    //slightly wider than item view
    return ITEM_SPACING;
}

- (CATransform3D)carousel:(iCarousel *)carousel transformForItemView:(UIView *)view withOffset:(float)offset
{
    //implement 'flip3D' style carousel
    
    //set opacity based on distance from camera
    view.alpha = 1.0 - fminf(fmaxf(offset, 0.0), 1.0);
    
    //do 3d transform
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = self.carousel.perspective;
    transform = CATransform3DRotate(transform, M_PI / 8.0, 0, 1.0, 0);
    return CATransform3DTranslate(transform, 0.0, 0.0, offset * self.carousel.itemWidth);
}

- (void)carouselCurrentItemIndexUpdated:(iCarousel *)carousel{
    
    if ([objectsDatasource count]>0 && ([carousel currentItemIndex]<=[objectsDatasource count])  ) {
        ARCABusinesses * businessObject = (ARCABusinesses *)[objectsDatasource objectAtIndex:[carousel currentItemIndex]];
        
        [self.businessAddressLabel setText:[businessObject address]];
        
        
        NSLog(@" --> DISTANCE: %0.2f", [[businessObject distance] floatValue]);
        
        [self.businessDistanceLabel setText:[NSString stringWithFormat:NSLocalizedString(@"XDistance", @""), [[businessObject distance] floatValue] , NSLocalizedString(@"DistanceUnit", @"")]];
        [self.businessNameLabel setText:[businessObject title] ];
        [self.dealMapMesageLabel setText:NSLocalizedString(@"nearbyMapMessage", nil)];
        [self.businessDescriptionTextView setText:[businessObject description]];
    }
    

}

- (BOOL)carouselShouldWrap:(iCarousel *)carousel{
    return NO;
}


#pragma maek - Get the application Settings
- (Setting *)setting {
	
	EdirectoryAppDelegate *thisDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
	setting = [thisDelegate setting];
	return setting;
}



#pragma mark - "Refresh" Navigation Button method
-(IBAction)reloadNearbyDealsFromServer{
    
    //disable the REFRESH button to prevent multiple server requests and avoi crashes inside the app
    [[[self navigationItem] rightBarButtonItem] setEnabled:NO];
    [businessDescriptionTextView setText:@""];
    
    
    [self setOperation:DEALS_NEARBY_OPERATION2];
    //block this view
    [self addWaitingAlertOverCurrentView];
    
    //clear the previous deals results
    self.objectsDatasource = [NSArray array];
    //reload carousel data 
    [self.carousel reloadData];
    
    //from now on the screen flow will be managed by the EdirectoryUserLocationDelegate methods !
    [self.edirectoryUserLocation setupEdirectoryUserLocation];
    
}

#pragma mark - UIAlaertView delegate method
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{

    EdirectoryAppDelegate *appDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    switch (buttonIndex) {
        case 0:
            break;
        case 1:
            //[appDelegate goToTheSetingsTab];
            [[self setting] setIsNearMe: [NSNumber numberWithBool:YES] ];
            [self reloadNearbyDealsFromServer];

            break;
            
        default:
            break;
    }
    
}

-(void)gotToDetail{
 
    //NSInteger index = [carousel.itemViews indexOfObject:sender];
    NSInteger index = [self.carousel currentItemIndex];    
    
    ARCABusinesses * businessObject = (ARCABusinesses *)[self.objectsDatasource objectAtIndex:index];
    
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
    
    [dealDetailViewController setUserLocation: self.userLocation];
    
    UIBarButtonItem *browseButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"dealBarBackItemTitle", @"") style:UIBarButtonItemStyleBordered target:nil action:nil];
    [[self navigationItem] setBackBarButtonItem:browseButton];
    [browseButton release];
    
    //Pushes the ListinDetailViewController into the navigationController	
    [self.navigationController  pushViewController:dealDetailViewController animated:YES];
    
    
    [dealDetailViewController release];
    
    [Utility proceedWithStatistics:@"detail_by_nearby" businessID:[businessObject _id] foursquare_id: [businessObject foursquare_id]];
    
}

    
-(IBAction)handleBodyButton:(id)sender{
    [self gotToDetail];
}

- (void)buttonTapped:(UIButton *)sender{
    [self gotToDetail];
}
    

#pragma mark - RPCacheControllerDelegate Methods
- (void) appImageDidLoad:(NSData *)imageData forIndex:(int)index{
    
    NSLog(@"Downloaded image for the index: %i ", index );  
    
    RpDashBoardButton * button = (RpDashBoardButton* )[[self carousselDatasourceItems] objectForKey:[NSNumber numberWithInt:index]];
   
    //UIImage * buttonImage = [UIImage imageWithData:imageData];
    [button setImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
    
    ARCABusinesses * businessObject = (ARCABusinesses *)[objectsDatasource objectAtIndex:index ];     
    [businessObject setImageObject: [UIImage imageWithData:imageData] ];

    
}
- (void) appImageLoadFailed: (int)index{
    NSLog(@"Failed downloaded image for the index: %i", index);    
}

    
@end
