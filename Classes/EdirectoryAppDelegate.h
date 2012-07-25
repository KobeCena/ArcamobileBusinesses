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
#import "AppLoaderViewController.h"
#import "SettingsViewController.h"
#import "SettingsManager.h"
#import <CoreData/CoreData.h>
#import "Setting.h"
#import "BusinessNearbyViewController.h"
#import "ThemeModel.h"
#import "BusinessTabBarController.h"
#import "PushCategoriesViewController.h"
#import "BusinessDashBoardViewController.h"


@interface EdirectoryAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, CLLocationManagerDelegate, UIAlertViewDelegate, PushCategoriesDelegate> {
    
    UIWindow *window;
    BusinessTabBarController *tabBarController;
	UINavigationController *nearbyNavigationController;
	
	AppLoaderViewController *appLoaderController;
	
	SettingsViewController *settingsViewController;
	
	NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
	
	Setting *setting;
    
    UIBackgroundTaskIdentifier bgTask;
    NSTimer                     *timer;

	CLLocationManager *locationManager;
    
    NSString *deviceToken;
    NSString *listingId;


    SettingsManager *setm;
    BusinessNearbyViewController * dealsViewController;
    
    //usefull to show the message in the DealsCategories screen
    BOOL showText;
    
    //reference to theme settings in memory
    ThemeModel * themeSettings;

}

@property (nonatomic, retain) ThemeModel * themeSettings;

@property (nonatomic, retain) SettingsManager *setm;
@property (nonatomic, retain) NSString *listingId;

@property (nonatomic, retain) NSString *deviceToken;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet BusinessTabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet UINavigationController *nearbyNavigationController;
@property (nonatomic, retain) AppLoaderViewController *appLoaderController;
@property (nonatomic, retain) IBOutlet SettingsViewController *settingsViewController;
@property (nonatomic,retain) IBOutlet BusinessNearbyViewController * dealsViewController;
@property (nonatomic,assign) BOOL showText;
@property (retain, nonatomic) IBOutlet BusinessDashBoardViewController *dashboardViewController;
@property (retain, nonatomic) IBOutlet UINavigationController *dashboardNavigationController;
@property (retain, nonatomic) IBOutlet UINavigationController *mybusinessesNavigationController;
@property (retain, nonatomic) IBOutlet UINavigationController *settingsNavigationController;

- (NSString *)applicationDocumentsDirectory;
@property (nonatomic, retain) Setting *setting;

/**
 This Method is called from Nearby and Search views like a shortcut to settings tab.
 **/
-(BOOL)verifyFirstRun;
-(void)goToTheSetingsTab;
- (void)goToThelistingsTab;
-(void)checkSettings;
- (void) clearLocationsBut:(id) objectBut entityName:(NSString *)entityName; 
- (BOOL)isConnectedToNetwork;
-(void)startUpdateLocation ;
-(void)stopUpdateLocation ;
- (NSManagedObjectContext *) managedObjectContext;
- (void) saveCoordinates;
@end
