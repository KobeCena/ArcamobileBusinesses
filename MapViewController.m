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
#import "MapViewController.h"
#import "ListingAnnotationView.h"
#import "Listing.h"
#import "Deal.h"
#import "DraggableViewController.h"
#import "EdirectoryAppDelegate.h"
#import "Utility.h"

#import "ARCAserver_businesses.h"
#import "EdirectoryParserToWSSoapAdapter.h"
#import "BusinessDetailsViewController.h"

#pragma mark -
@implementation MapViewController

@synthesize mapView;
@synthesize mapAnnotations;
@synthesize draggViewController;
@synthesize buttonList;
@synthesize searching;
@synthesize previousPinSelected;
@synthesize listings;
@synthesize setting;
@synthesize zipcodeLatitude, zipcodeLongitude;
@synthesize parser;
@synthesize disableHideWhenMapTouched;

@synthesize refreshWhenRegionChanges;
@synthesize showRighNavigationButton;

- (void)dealloc {
	[listings               release];
	[buttonList             release];
	[mapView                release];
	[mapAnnotations         release];
	[draggViewController    release];
	[searching              release];
	[setting                release];
	[previousPinSelected    release];	
    [searchingLabel         release];
    [parser                 release];
    [super                  dealloc];
}

- (UIBarButtonItem *) buttonList {
	
	if (buttonList != nil) {
		return buttonList;
	}
	
	buttonList = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"List", @"") style:UIBarButtonItemStylePlain target:self action:@selector(showListingsInTable:)];
	buttonList.enabled = NO;

	return buttonList;
	
}


#pragma mark - Methods for block/Unblock the mapView
-(void)blockMapView{
    
	[self.searching setHidden:NO];
	[self.view setUserInteractionEnabled:NO];    
    
}

-(void)unBlockMapView{
	[self.searching setHidden:YES];
	[self.view setUserInteractionEnabled:YES];    
}


#pragma mark - Methods for show/hide the infoBubble
-(void) hideInfoBubble{
    
    if (self.disableHideWhenMapTouched) {
        return;
    }
    
	//animates the infoBubble disappearing
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.4];
	self.draggViewController.view.alpha = 0.0f;	
	[UIView commitAnimations];
	
	self.draggViewController.view.hidden = YES;
}

-(void)draggViewSetup:(Listing *)data {
    //[self.draggViewController.detailButton setHidden:![(Listing *)data hasDetail]];
    self.draggViewController.dragTitle.text = [(Listing *)data title];
    [self.draggViewController setListingBean:data];
    [[self.draggViewController ratingView] setRating:[(Listing *)data rateAvg]];
    
    //[self.draggViewController setLatitude];
    
    //UIImage * bubbleImage = [UIImage imageWithData:[NSURL URLWithString: [(Deal *)data imageURLString] ]];        
    //[[self.draggViewController image] setImage:bubbleImage];
    [[self.draggViewController image] setImage: [(Listing *)data listingIcon] ];
}

-(void) showInfoBubble:(CGPoint)point fromView:(UIView *) aView withData:(Listing *)data{
	
	 //Converts the point
	 CGPoint newPoint =[self.view convertPoint:point fromView:aView];

    
	 //if our infobubbe is hidden then show it.
	 if ( self.draggViewController.view.hidden == YES) {
		 self.draggViewController.view.hidden = NO;
	 } 
	 
	//sets the new position to our infoBubble
	self.draggViewController.view.frame = CGRectMake(newPoint.x - (self.draggViewController.view.frame.size.width/2),
													 (newPoint.y - (self.draggViewController.view.frame.size.height + 20)),
													 212,
													 72);

    
    

    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.duration = 0.35555555;
	animation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.6],[NSNumber numberWithFloat:1.1],[NSNumber numberWithFloat:.9],[NSNumber numberWithFloat:1],nil];
    animation.keyTimes = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:0.6],[NSNumber numberWithFloat:0.8],[NSNumber numberWithFloat:1.0],nil];    
    [self.draggViewController.view.layer addAnimation:animation forKey:@"transform.scale"];     
    
	//brings our infoBubble to front
	[self.view bringSubviewToFront:self.draggViewController.view];
	
	//Setting data onto our infoBubble
	if ([data isKindOfClass:[Listing class]]){
        [self draggViewSetup: data];
	}	
	
	//animates the infoBubble Appearing (now at the new position)
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelegate:self];
	
	[UIView setAnimationDuration:0.4];
	
	self.draggViewController.view.alpha = 1.0f;
	
	[UIView commitAnimations];
	
	self.draggViewController.currentNavigationController = [self navigationController];
	 
}



+ (CGFloat)annotationPadding;
{
    return 10.0f;
}
+ (CGFloat)calloutHeight;
{
    return 40.0f;
}


-(BOOL)getNumberOfVisiblePins{

    BOOL result = FALSE;
    
    if([self.mapView.annotations count] == 0)
        result = FALSE;
	if (!(self.zipcodeLatitude == 0 && self.zipcodeLongitude == 0))	
        result = FALSE;
	
    NSSet * pins = [self.mapView annotationsInMapRect:self.mapView.visibleMapRect];
    
    if ([pins count]>3) {
        result = TRUE;
        NSLog(@"Há pinos na área visível do mapa");
    }else{
        result = FALSE;
        NSLog(@"NÃO Há pinos na área visível do mapa");        
    }
    
    return result;
    
}


-(void)zoomToFitMapAnnotations
{
    if([self.mapView.annotations count] == 0)
        return;
	if (!(self.zipcodeLatitude == 0 && self.zipcodeLongitude == 0))	
		return;
	
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
	
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
	
    for(Listing* annotation in self.mapView.annotations)
    {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
		
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
	
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1; // Add a little extra space on the sides
	
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];
}

- (void)gotoLocation:(double)newLatitude newLongitude:(double)newLongitude
{
	
	NSLog(@"Indo para a posição: %f, %f", newLatitude, newLongitude);
	if (!(newLatitude == 0 && newLongitude == 0)) {
		//This is usefull to our "fake" user location
		self.zipcodeLatitude = newLatitude;
		self.zipcodeLongitude = newLongitude;
		
		//This is usefull to use when this app calls the CoreGoogleMaps to show directions
		//It's used when user sets the zipcode as a basis for searchs in the settings view.
		[self.draggViewController setLatitude: self.mapView.userLocation.coordinate.latitude ];
		[self.draggViewController setLongitude: self.mapView.userLocation.coordinate.longitude ];
		
			MKCoordinateRegion newRegion;
			newRegion.center.latitude = newLatitude;
			newRegion.center.longitude = newLongitude;

			float valor = [[[self getSetting] distance] floatValue] ;        
			
			newRegion.span.latitudeDelta = (valor/111.0f);
			newRegion.span.longitudeDelta = (valor/111.0f);
			
        
            originalLocation = newRegion;
			[self.mapView setRegion:newRegion animated:NO];
	}
	
	NSLog(@"End of Indo para a posição");

}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

    if (showRighNavigationButton) {
        self.navigationItem.rightBarButtonItem = [self buttonList];
    }

	UIBarButtonItem *browseButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"MapView", @"") style:UIBarButtonItemStyleBordered target:nil action:nil];
	[[self navigationItem] setBackBarButtonItem:browseButton];
	[browseButton release];

    
	//Initializes the EdirectoryXMLParser
	EdirectoryXMLParser * tmpParser = [[EdirectoryXMLParser alloc] initXMLParserDelegate];
	tmpParser.delegate = self;
	self.parser = tmpParser;
	[self.parser setMaximumNumberOfObjectsToParse:100];
	[tmpParser release];
    
    
	//To get better performance, add`s the infoBubble only once at Map`s View load.
	self.draggViewController.view.frame = CGRectMake(0.0f,
													 0.0f,
													 212,
													 72);
	
	//hides the infoBubble
	self.draggViewController.view.hidden = NO;
	
    [self.draggViewController setMapReference:self];
    
	//Adds the infoBubble as a subview from Map
	[self.view addSubview:self.draggViewController.view];
	
	//Brings the infoBubble to front
	[self.view bringSubviewToFront:self.draggViewController.view];

    //set this viewController to be the delegate of MapView
	[self.mapView setDelegate:self];
    
    [searchingLabel setText:NSLocalizedString(@"Searching", nil)];
	
}
-(void)showDetail:(Listing *) listingObj{

	//hides the infoBubble
	self.draggViewController.view.hidden = NO;
    
    //locks the screen
    [self blockMapView];

    ARCAserver_businesses* service = [ARCAserver_businesses service];
    EdirectoryParserToWSSoapAdapter *adapter = [EdirectoryParserToWSSoapAdapter sharedInstance];
    [service setHeaders:[adapter getDomainToken]];
    service.logging = NO;
    
    NSLog(@"Latitude: %0.2f - Longitude: %0.2f", 
          listingObj.latitude, 
          listingObj.longitude);
    
    //call server to obtain a specific business object
    [service getAllBusinessForID:self action:@selector(getAllBusinessForIDHandler:) 
                     business_id:(NSDecimalNumber *)[NSDecimalNumber numberWithInt: [listingObj listingID] ] 
                        latitude:listingObj.latitude 
                       longitude:listingObj.longitude 
                   foursquare_id:nil];

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
    [self unBlockMapView];
    
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




- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [searchingLabel release];
    searchingLabel = nil;
    [super viewDidUnload];
	self.draggViewController = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - MKMapViewDelegate Methods
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    NSLog(@"A região vai mudar!!");
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    NSLog(@"A região mudou!!");
	NSLog(@"A região mudou!! : %f, %f", [mapView region].center.latitude, [mapView region].center.longitude);    
    
    //proceeds only if the property 'refreshWhenRegionChanges' is TRUE
    if (refreshWhenRegionChanges) {    
        if (searching.hidden == NO) {
            NSLog(@"A região mudou!! - não deve ser feito nada");
        }else{
            NSLog(@"A região mudou!! - efetuar refresh dos dados");
            
            if (![self getNumberOfVisiblePins]){
                
                 // 1 - removes all pins
                 if ([self.mapView.annotations count] > 0) {
                 [self.mapView removeAnnotations: self.mapView.annotations ];
                 }
                 
                 // 2 - blocks the mapview screen
                 [self blockMapView];
                 
                 // 3 - redo search in server
                 //Gets the URL string from a plist file

                NSString *nearType;
                
                if ([[[self setting ]isNearMe] boolValue]) {
                    nearType = @"nearme";
                } else {
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
                                       [connPlist objectForKey:@"ArcaMobileDeals"],
                                       nil,
                                       nearType, 
                                       (setting.zipCode != nil) ? [setting.zipCode stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]: @"",
                                       [setting.distance stringValue], 
                                       [mapView region].center.latitude, 
                                       [mapView region].center.longitude,
                                       [setting.city.state.country.country_id intValue],
                                       [setting.city.state.state_id intValue],
                                       [setting.city.city_id intValue]];
                
                
                NSLog(@"Requisitando URL: %@", urlString);
        
                // 3.1 - starts the parser                
                [self.parser loadObjectsData:urlString];
            }
        }
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation{

	NSLog(@"======viewForAnnotation Begin");

	
	self.buttonList.enabled = YES;
	
    // if it's the user location annotation, verifies to see if it`s needed to show the ziplocation position
    if ([annotation isKindOfClass:[MKUserLocation class]]){
		
		NSLog(@"MKUserLocation BEGIN");
        
		if (![[[self getSetting] isNearMe] boolValue]) {
			
			//creates our custom annotation
			Listing *listing = [[Listing alloc] init];
			[listing setLatitude:zipcodeLatitude];
			[listing setLongitude:zipcodeLongitude];
			[listing setListingTitle:NSLocalizedString(@"CurrentLocation", @"")];
			
			CLLocationCoordinate2D zipcodeCoordinate;
			zipcodeCoordinate.latitude = zipcodeLatitude;
			zipcodeCoordinate.longitude = zipcodeLongitude;			
			
			[annotation setCoordinate:(CLLocationCoordinate2D)zipcodeCoordinate];
			
			ListingAnnotationView *zipcodeLocation = [[[ListingAnnotationView alloc] initWithAnnotation:listing reuseIdentifier:@"zipcodeLocation"] autorelease];
			
			//zipcodeLocation.mapViewController =self;
            //zipcodeLocation.pinColor = MKPinAnnotationColorPurple;
            //zipcodeLocation.animatesDrop = YES;
			zipcodeLocation.isZipPosition = YES;	
			zipcodeLocation.canShowCallout = YES;
			[zipcodeLocation setEnabled:YES];
			UIImage *customImage = [UIImage imageNamed:@"marker-me.png"];
			[zipcodeLocation setImage:customImage];
			//zipcodeLocation.opaque = YES;
			[zipcodeLocation setAnnotation:listing];
			[listing release];
            
			return zipcodeLocation;
		}	
		
		NSLog(@"MKUserLocation END");

		
	}
	
    
    // handle our two custom annotations
    //
    if ([annotation isKindOfClass:[Listing class]])
    {
		NSLog(@"Listing BEGIN");
		
        // try to dequeue an existing pin view first
        static NSString* ListingAnnotationIdentifier = @"listingAnnotationIdentifier";
        ListingAnnotationView* pinView = (ListingAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:ListingAnnotationIdentifier];
        if (!pinView)
        {
            // if an existing pin view was not available, create one
            ListingAnnotationView* customPinView = [[[ListingAnnotationView alloc]
												   initWithAnnotation:annotation reuseIdentifier:ListingAnnotationIdentifier] autorelease];
            //customPinView.pinColor = MKPinAnnotationColorPurple;
            //customPinView.animatesDrop = YES;
			customPinView.canShowCallout = NO;
			[customPinView setEnabled:YES];
			UIImage *customImage = [UIImage imageNamed:@"pinmark_unselected.png"];
			customPinView.image = customImage;
			customPinView.opaque = YES;

            
			//register this class to listen all notifications comming from ListingAnnotationView
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(listenPinViewNotifications:)
														 name:nil object:customPinView];
            
            
            
            
            return customPinView;
        }
        else
        {
            pinView.annotation = annotation;
        }
		
		NSLog(@"Listing END");

        return pinView;
    }

	NSLog(@"======viewForAnnotation End");

	
	return nil;

}



- (Setting *)  getSetting {
	
    if (self.setting != nil) {
        return self.setting;
    }
    
    EdirectoryAppDelegate *thisAppDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.setting = [thisAppDelegate setting];
    return self.setting;
}


#pragma mark - Handles all incomming notifications
- (void)listenPinViewNotifications:(NSNotification *) notification{
    
    if (self.disableHideWhenMapTouched) {
        return;
    }
    
	if ([notification.name isEqualToString:PIN_SELECTED]) {
		NSLog(@"Received notificaion: PIN_SELECTED");

        ListingAnnotationView * tappedPin = (ListingAnnotationView *)[notification object];
        
        [tappedPin setLeftCalloutAccessoryView:[self.draggViewController view]];
        
        [self hideInfoBubble];
        
		if ([tappedPin.annotation isKindOfClass:[Listing class]]){
			//if ([[(Listing *)tappedPin.annotation rawAddress] isEqualToString:@""] || [(Listing *)tappedPin.annotation rawAddress] == nil) {
			//	NSLog(@"ADDRESS EMPTY");
			//	[[[self draggViewController] directionsButton] setHidden:YES];
			//}else{
				[[[self draggViewController] directionsButton] setHidden:NO];
			//}
		}
        
        
        
        if ([self previousPinSelected] == nil) {
            [self setPreviousPinSelected:tappedPin];
        }else {
            //Turns all states back for previous pin
            [[self previousPinSelected] setHighlighted:NO];
            [[self previousPinSelected] setSelected:NO];
            UIImage *customImage = [UIImage imageNamed:@"pinmark_unselected.png"];
            [[self previousPinSelected] setImage:customImage];
            
        }
        
        
        [self setPreviousPinSelected:tappedPin];
        
        
        //centers the map
        [[self  mapView] setCenterCoordinate: [[tappedPin annotation] coordinate] animated:TRUE];
        
        //show infoBubble
        [self showInfoBubble:[tappedPin touchedPoint] fromView:tappedPin withData:tappedPin.annotation];	
        
		
    }
}


#pragma mark - eDirectoryParser delegate methods
//Called by the parser when the latitude and logitude of the searchable region is received
- (void)parserDidReceiveSearchResultsPosition:(double)latitude withLongitude:(double)longitude{
    
    [self gotoLocation:latitude newLongitude:longitude];
}
//Called by the parser when the results array was created
- (void)parserDidCreatedResultsArray:(NSArray *)objectResults{}
//Called by the parser when the numbers for paging navigation is received
- (void)parserDidReceivePagingNumbers:(int)totalNumberOfPages wichPage:(int)actualPage{}
//Called by the parser everytime that listingResults is updated with a batch of data
- (void)parserDidUpdateData:(NSArray *)objectResults{}
// Called by the parser when parsing is finished.
- (void)parserDidEndParsingData:(NSArray *)objectResults{

    //proceed with the mapview flow for deals
    [self.mapView performSelectorOnMainThread: @selector(addAnnotations:) withObject: objectResults waitUntilDone: YES];
    
    [self unBlockMapView];
    
}
//Parser will call this method just to notify delegates that an error was occurred.
//This method will be usefull for further delegates that will need to know when an error occurred
//during the data parsing to be able to release any holded objects or release/dismiss any graphic Object.
- (void)parserEndWithError:(BOOL)hasErrors{}

// Called by the parser when no listingResults were found
- (void)noResultsWereFound{
    
}


@end
