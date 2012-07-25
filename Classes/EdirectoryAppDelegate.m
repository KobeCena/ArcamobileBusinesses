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

#import "EdirectoryAppDelegate.h"
#import "AppLoaderViewController.h"
#import <QuartzCore/CALayer.h>
#import <UIKit/UIKit.h>
#import "SettingsViewController.h"
#import "Listing.h"
#import "Utility.h"
#import "BusinessNearbyViewController.h"

#import <SystemConfiguration/SCNetworkReachability.h>
#include <netinet/in.h>
#import "CoreUtility.h"
#import "EdirectoryParserToWSSoapAdapter.h"
#import "ARCAserver_businesses.h"

@interface EdirectoryAppDelegate (PrivateCoreDataStack)
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

@implementation EdirectoryAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize nearbyNavigationController;
@synthesize appLoaderController;
@synthesize settingsViewController;
@synthesize setting;
@synthesize deviceToken;
@synthesize listingId;
@synthesize setm;
@synthesize dealsViewController;
@synthesize showText;
@synthesize dashboardViewController;
@synthesize dashboardNavigationController;
@synthesize mybusinessesNavigationController;
@synthesize settingsNavigationController;
@synthesize themeSettings;

- (void)dealloc {
    
    [deviceToken                    release];
    [listingId                      release];
    [setm                           release];
	[managedObjectContext           release];
    [managedObjectModel             release];
    [persistentStoreCoordinator     release];
    [tabBarController               release];
	[nearbyNavigationController     release];
	[settingsViewController         release];
    [dealsViewController            release];
    [appLoaderController            release];
    [window                         release];
    [dashboardViewController release];
    [dashboardNavigationController release];
    [mybusinessesNavigationController release];
    [settingsNavigationController release];
    [super dealloc];
}

-(BOOL)verifyFirstRun{
    return [Utility verifyFirstRun];
}

-(void)releasesAppLoader{
    [appLoaderController release];
}

-(void)handleTimer:(NSTimer *)timer{
	//Invalidates timer so it won`t run again
	[timer invalidate];
}


-(void)closeLoaderAndShowCarroussel{
	//animates the loader disapearing
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelegate:self];
	//[UIView setAnimationDidStopSelector:@selector(hidingLoaderFinished)];
	[UIView setAnimationDuration:1.0];
	[[appLoaderController view] setAlpha:0.0f];
	[UIView commitAnimations];
	
	[window bringSubviewToFront:tabBarController.view];
	[window sendSubviewToBack:appLoaderController.view];
	
	[[tabBarController view] setAlpha:0.0f];
	[[tabBarController view] setOpaque:FALSE];
	
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:1.0];	
	
	[[tabBarController view] setAlpha:1.0f];
	[[tabBarController view] setOpaque:TRUE];
	
	[UIView commitAnimations];	
    
//	[self releasesAppLoader];
    
}

-(void)closeLoaderAndShowCategories{
    [self closeLoaderAndShowCarroussel];
    
    [self performSelectorOnMainThread:@selector(goToThelistingsTab) withObject:nil waitUntilDone:NO];    
    
//    [self goToThelistingsTab];
    
}

#pragma mark - Activates or deactivates the push notifications system.
-(BOOL)pushNotificationsFEatureisActive{
    return NO;
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([actionSheet tag] == 0) {
        //sleep(1);
        [NSThread sleepForTimeInterval:2.0];
        exit(0);
    } else {
        // the user clicked one of the OK/Cancel buttons
        if (buttonIndex == 0)
        {
        }
        else
        {
            [self parserListing];
        }
    }
}

#pragma mark - Application lifecycle methods
- (void)applicationDidBecomeActive:(UIApplication *)application{
    //configures the color for the application statusBar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    

    
    
    //intis the TestFligh SDK
//    [TestFlight takeOff:@"859411b196bed94723e529d2830c2ad2_Mzg2MDYyMDExLTExLTAzIDExOjQwOjQ3LjgwNTU2Mw"];
    
    //Verifies is this applicatins has a valid internet connection
	if (![self isConnectedToNetwork]){

        AppLoaderViewController *loaderController = [[AppLoaderViewController alloc] initWithNibName:@"AppLoaderView" bundle:nil];
        loaderController.view.frame = CGRectMake(0.0f, 20.0f, 320.0f, 460.0f);
        //Adds the loader`s view as a subview of the window
        [self.window addSubview:loaderController.view];
        [loaderController release];
        
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NoConnection", @"")
														message:NSLocalizedString(@"NoConnectionMessage", @"")
													   delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"") 
                                              otherButtonTitles:nil];
        
        [alert setTag:0];
        
		[alert show];
		[alert release];
        
        return NO;
	}
 
    
    [self setShowText:NO];
    
    [self verifyFirstRun];
    
    
    setm = [[SettingsManager alloc] initWithNoWhait];
    
	//NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	//NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
	

	

    AppLoaderViewController * loader  = [[AppLoaderViewController alloc] initWithNibName:@"AppLoaderView" bundle:nil];    
    self.appLoaderController = loader;
    [loader release];
	self.appLoaderController.view.frame = CGRectMake(0.0f, 20.0f, 320.0f, 460.0f);    

	

    tabBarController.delegate = tabBarController;
    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];
    
	//Adds the loader`s view as a subview of the window
	[self.window addSubview:self.appLoaderController.view];
    
    
    //[window addSubview:navigationController.view];
    [window makeKeyAndVisible];	

	
	
	//brings loaderview to the front
	[window bringSubviewToFront:self.appLoaderController.view];    
	//creates a timer to hide the loaderview and then brings the buttonview to front
	[NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector: @selector(handleTimer:) userInfo:nil repeats: NO];

	
    //register this class to listen all notifications comming from the dealsViewController
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(listenDealsNotifications:)
                                                 name:nil object:self.dealsViewController];
    
    
    //register this class to listen all notifications comming from the appLoaderController
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(listenDealsNotifications:)
                                                 name:nil object:self.appLoaderController];
    
    
	
	[self checkSettings];
	
	
	[self.settingsViewController setSetting:self.setting];
	
	[self.settingsViewController setSavingManagedObjectContext:self.managedObjectContext];

	
    //Load all theme settings

    ThemeModel *themeModel = [[ThemeModel alloc] init];
    self.themeSettings = themeModel;
    [themeModel release];
    
    [[[[tabBarController viewControllers]   objectAtIndex:0] tabBarItem] setTitle:NSLocalizedString(@"tabBarItem1", @"")];
    [[[[[[tabBarController viewControllers] objectAtIndex:0] viewControllers] objectAtIndex:0] navigationItem] setTitle:NSLocalizedString(@"NearbyTitle", @"")];
    
    [[[[tabBarController viewControllers]   objectAtIndex:1] tabBarItem] setTitle:NSLocalizedString(@"tabBarItem2", @"")];
    [[[[[[tabBarController viewControllers] objectAtIndex:1] viewControllers] objectAtIndex:0] navigationItem] setTitle:NSLocalizedString(@"businessNavigationTitle", @"")];

    [[[[tabBarController viewControllers]   objectAtIndex:2] tabBarItem] setTitle:NSLocalizedString(@"tabBarItem3", @"")];
    [[[[[[tabBarController viewControllers] objectAtIndex:2] viewControllers] objectAtIndex:0] navigationItem] setTitle:NSLocalizedString(@"ListingsTitle", @"")];

    [[[[tabBarController viewControllers]   objectAtIndex:3] tabBarItem] setTitle:NSLocalizedString(@"tabBarItem4", @"")];
    [[[[[[tabBarController viewControllers] objectAtIndex:3] viewControllers] objectAtIndex:0] navigationItem] setTitle:NSLocalizedString(@"SettingsTitle", @"")];

//    [[[[tabBarController viewControllers]   objectAtIndex:4] tabBarItem] setTitle:NSLocalizedString(@"MoreTitle", @"")];
//    [[[[[[tabBarController viewControllers] objectAtIndex:4] viewControllers] objectAtIndex:0] navigationItem] setTitle:NSLocalizedString(@"MoreTitle", @"")];
    

    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    //[[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeAlert)];    
        
    [[self themeSettings] configureTabBar:self.tabBarController.tabBar];
    
    [[self themeSettings] configureNavigationBar:self.nearbyNavigationController.navigationBar];
    [[self themeSettings] configureNavigationBar:self.dashboardNavigationController.navigationBar];
    [[self themeSettings] configureNavigationBar:self.mybusinessesNavigationController.navigationBar];
    [[self themeSettings] configureNavigationBar:self.settingsNavigationController.navigationBar];
    
    //[self.appLoaderController.cancelButton setHidden:YES];
    
    [self saveCoordinates];
    
	return YES;
}

#pragma mark - To observe messages comming 
- (void)listenDealsNotifications:(NSNotification *) notification{
	

    
	if ([notification.name isEqualToString:DEALS_FINISHED]) {
        [self closeLoaderAndShowCarroussel];
    }
    
	if ([notification.name isEqualToString:DEALS_FINISHED_NO_RESULTS]) {
        [self setShowText:YES];
        [self closeLoaderAndShowCategories];        
    }

	if ([notification.name isEqualToString:DEALS_CANCELED]) {
        
        [self setShowText:YES];
        [NSThread cancelPreviousPerformRequestsWithTarget:[self.dealsViewController edirectoryXMLParser]];        
        //WS-SOAP access bridge    
        EdirectoryParserToWSSoapAdapter * adapter = [EdirectoryParserToWSSoapAdapter sharedInstance];    
        [adapter cancel];
        
        [self.dealsViewController cancelNearbyDeals];
        [self closeLoaderAndShowCategories];
    }
    
    
    
}

#pragma mark - CLLocationManager delegate methods
-(void)startUpdateLocation {
    [locationManager startUpdatingLocation];
    
}

-(void)stopUpdateLocation {
    [locationManager stopUpdatingLocation];
}



-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
    
    if (signbit(newLocation.horizontalAccuracy)) return;
    NSTimeInterval deltaCurrentDelay = [newLocation.timestamp timeIntervalSinceDate:[NSDate date]] * - 1;
    if (deltaCurrentDelay > 1) return;
    NSTimeInterval distanceTimeDelta = [newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp];
    if ((!isnan(distanceTimeDelta)) && (distanceTimeDelta < 30)) return;
    
    CLLocationCoordinate2D here =  newLocation.coordinate;

    NSString *path = [[NSBundle mainBundle] pathForResource:@"ConnectionStrings" ofType:@"plist"];
    NSDictionary *connPlist = [NSDictionary dictionaryWithContentsOfFile:path];
    NSString *connURL = [connPlist objectForKey:@"PushNotification"];
    
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:connURL, 
                                        [[self deviceToken] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                        here.latitude,
                                        here.longitude,
                                        [setting.distance intValue]
                  ]];
    
    NSString* userAgent = @"Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en)";
	NSMutableURLRequest *mutableURLRequest = [NSMutableURLRequest requestWithURL:url];
	[mutableURLRequest setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:mutableURLRequest delegate:nil];
    [conn release];
    
    
}

// Delegation methods
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    [self setDeviceToken: [[devToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]];
    
    
    if ([self verifyFirstRun]) {
        
        EdirectoryParserToWSSoapAdapter *adapter = [[EdirectoryParserToWSSoapAdapter alloc] init];
        
        ARCAserver_businesses * service = [ARCAserver_businesses service];   
        [service setLogging:NO];
        [service setHeaders:[adapter getDomainToken]];
        
        [service pushiPhoneEnableAll:nil id:@"" token:self.deviceToken module:@"businesses"];
        
        [service release];
        
    }
    
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in registration. Error: %@", err);
}



- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {

    
    
    
//    NSDictionary *dicServer = [userInfo objectForKey:@"server"];
//    NSInteger categoryId = [[dicServer objectForKey:@"categoryId"] integerValue];

    NSDictionary *dicApp = [userInfo objectForKey:@"aps"];
    NSString *message = [dicApp objectForKey:@"alert"];
    
    UIApplicationState state = [application applicationState];
    
    if (state == UIApplicationStateActive) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Push Notification"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
//        [alert setTag:1];

        [alert show];
        [alert release];
        
    } else {
        
//        [self parserListing];
        
    }
    
    
}


- (void)parserDidEndParsingData:(NSArray *)objectResults{
    
    Listing *list = (Listing *)[objectResults objectAtIndex:0];
    [self performSelectorOnMainThread:@selector(openDeal:) withObject:list waitUntilDone:NO];
    
}

-(void)checkSettings {
	if (![self.setting.isNearMe boolValue]) {
		if ((self.setting.zipCode==nil || [self.setting.zipCode length]<1) && ((setting.city == nil) ) )  {
			[self.setting setIsNearMe:[NSNumber numberWithBool:YES]];
		}
	}
}


//Try to release any resource to free up memory
/*
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
 
}
*/

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	
    NSError *error = nil;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {

			UIAlertView *errorAlert = [[UIAlertView alloc] 
                                       initWithTitle:NSLocalizedString(@"NoSaveData", @"")
                                       message:NSLocalizedString(@"NoSaveDataMessage", @"")
                                       delegate:nil 
                                       cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                       otherButtonTitles:nil];
			[errorAlert show];
			[errorAlert release];
			
			
        } 
    }
}


- (BOOL)isConnectedToNetwork{
	
	// Create zero addy
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
	
	//Recover reachability flags
	SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
	SCNetworkReachabilityFlags flags;
	
	BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
	CFRelease(defaultRouteReachability);
	
	if(!didRetrieveFlags){
		NSLog(@"Error. Could not recover network reachability flags.");
		return NO;
	}
	
	BOOL isReachable = flags & kSCNetworkFlagsReachable;
	BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
	
	return (isReachable && !needsConnection) ? YES : NO;

}

- (Setting *) setting {
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Setting" 
											  inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
	
    NSError *error;
    NSArray *items = [self.managedObjectContext
					  executeFetchRequest:fetchRequest error:&error];
	
	if ([items count] > 0) {
		setting = (Setting *)[items objectAtIndex:0];
	} else {
        
        //Settings Default
		setting = (Setting *)[NSEntityDescription insertNewObjectForEntityForName:@"Setting" inManagedObjectContext:self.managedObjectContext];
		[setting setIsNearMe:[NSNumber numberWithBool:YES]];
		[setting setDistance:[NSNumber numberWithInt:20]];
        [setting setZipCode:@""];
		[self.managedObjectContext save:nil];
	}
	
    [fetchRequest release]; 
	
	return setting;
	
}

- (void) clearLocationsBut:(id) objectBut entityName:(NSString *)entityName {
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
	
	[fetchRequest setEntity:entity];
	
	NSError *error;
	NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	NSEnumerator *enums = [items objectEnumerator];
	
	id object;
	while (object = [enums nextObject]) {
		
		if (![objectBut isEqual:object]) {
			[self.managedObjectContext deleteObject:object];			
		}
		
	}
	
	[fetchRequest release];
	
	
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    //managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    

	NSString * path = [[NSBundle mainBundle] pathForResource:@"eDirectory" ofType:@"momd"];    
    NSURL *momURL = [NSURL fileURLWithPath:path];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
	
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"AppSettings.sqlite"]];
	
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
							 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
							 
							 
							 
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {

		UIAlertView *errorAlert = [[UIAlertView alloc] 
                                   initWithTitle:NSLocalizedString(@"NoSaveData", @"")
                                   message:NSLocalizedString(@"NoSaveDataMessage", @"")
                                   delegate:nil 
                                   cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                   otherButtonTitles:nil];
		[errorAlert show];
		[errorAlert release];
		
		
    }    
	
    return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark -
#pragma mark eDirectory Logic
/**
 This Method is called from Nearby and Search views like a shortcut to settings tab.
 **/
- (void)goToTheSetingsTab{

	
	NSEnumerator *e = [[[self tabBarController] viewControllers] objectEnumerator];
	id object;
	while (object = [e nextObject]) {
		if ([object isKindOfClass:[UINavigationController class]]) {
			
			UINavigationController *navTemp = (UINavigationController *)object;
			
			NSEnumerator *el = [[navTemp viewControllers] objectEnumerator];
			id objectE;
			while (objectE = [el nextObject]) {
				if ([objectE isKindOfClass:[SettingsViewController class]]) {
					[[self tabBarController] setSelectedViewController:object];
				}
			}
		}
	}
}


/**
 This Method is like a shortcut to listings tab.
 **/
- (void)goToThelistingsTab{
	
	NSEnumerator *e = [[[self tabBarController] viewControllers] objectEnumerator];
	id object;
	while (object = [e nextObject]) {
		if ([object isKindOfClass:[UINavigationController class]]) {
			
			UINavigationController *navTemp = (UINavigationController *)object;
			
			NSEnumerator *el = [[navTemp viewControllers] objectEnumerator];
			id objectE;
			while (objectE = [el nextObject]) {
				if ([objectE isKindOfClass:[BusinessNearbyViewController class]]) {
					[[self tabBarController] setSelectedViewController:object];
				}
			}
		}
	}
}


#pragma mark - Save Coordinates for Nearby

- (void) getCoordinatesHandler: (id) value {
    
    ARCACoordinateReturn *ret = (ARCACoordinateReturn *) value;
    
    [self.setting setLatitude: [NSNumber numberWithFloat: [ret.latitude floatValue]]];
    [self.setting setLongitude: [NSNumber numberWithFloat: [ret.longitude floatValue]]];
    
    NSLog(@"Coordinates saved ...");
    
}
- (void) saveCoordinates {
    
    ARCAserver_businesses* service = [ARCAserver_businesses service];
    EdirectoryParserToWSSoapAdapter *adapter = [EdirectoryParserToWSSoapAdapter sharedInstance];
    [service setHeaders:[adapter getDomainToken]];
    service.logging = NO;
    
    
    NSString *nearType = @"";
    NSString *zipcode = @"";
    
    if([setting.isNearMe intValue] > 0) {
        
        nearType = @"nearme";
        
    } else if([setting.city.city_id intValue] > 0) {
        
        nearType = [NSString stringWithFormat:@"%i", [setting.city.city_id intValue]];
        
    } else {
        
        nearType = @"zipcode";
        zipcode = [setting zipCode];
        
    }
    
    NSLog(@"Saving coordinates ...");
    
    [service getNearbyCoordinates:self action:@selector(getCoordinatesHandler:) nearbyType:nearType zipcode:zipcode latitude:0 longitude:0];
    
}


@end
