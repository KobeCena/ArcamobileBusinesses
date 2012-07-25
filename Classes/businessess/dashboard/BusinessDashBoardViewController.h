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

#import "EdirectoryXMLParser.h"
#import "EdirectoryUserLocation.h"
#import "Setting.h"
#import "RpDashBoard.h"
#import "RpCacheController.h"

@class MapViewController;
@class Listing;


@interface BusinessDashBoardViewController : UIViewController <EdirectoryXMLParserDelegate, EdirectoryUserLocationDelegate, RpDashBoardDelegate, RpDashBoardDataSource, UITextFieldDelegate> {

	Setting *setting;	
	MapViewController *mapViewController;	
    UILabel *lblLoadingDash;
	EdirectoryUserLocation *edirectoryUserLocation;
	
	NSArray *listingList;	
	UILabel *inTypeLabel;
	UILabel *distanceLabel;
	
	
	NSString *actualKeyword;
	
	
	//THis variables will hold the data obtained from CoreLocation
	double userLatitude, userLongitude;
    
    
    //Internationalization
    
    IBOutlet UILabel *labelNear;
    IBOutlet UILabel *labelDistance;
    
	//DashBoard Component
    UIView *dashboardLock;
    NSArray *dashBoardItems;

    //For Search using a keyword
    UITextField *searchText;
    UILabel *topMessageLabel;
    UIImageView *imgBgSearch;
    
    
    
}
@property (nonatomic, retain) IBOutlet RpDashBoard *dashboard;

@property (nonatomic, retain) IBOutlet UILabel *inTypeLabel;
@property (nonatomic, retain) IBOutlet UILabel *distanceLabel;
@property (nonatomic, retain) IBOutlet MapViewController *mapViewController;
@property (nonatomic, retain) IBOutlet UILabel *lblLoadingDash;

@property (nonatomic, retain) Setting *setting;
@property (nonatomic, retain) EdirectoryUserLocation *edirectoryUserLocation;
@property (nonatomic, retain) NSArray *listingList;
@property (nonatomic, retain) NSArray *dashBoardItems;

@property (nonatomic, retain) IBOutlet UIView *dashboardLock;

@property (nonatomic, retain) IBOutlet UITextField *searchText;
@property (nonatomic, retain) IBOutlet UILabel *topMessageLabel;
@property (nonatomic, retain) IBOutlet UIImageView *imgBgSearch;




- (IBAction) callSettingViewController:(id)sender;
- (IBAction) doReloadAgain:(id)sender;
- (void) removeAllInvisibleButtons;
- (IBAction) textSearchEditBegin:(id)sender;

- (void) showMessageTopLabel;
- (void) hideMessageTopLabel;


@end
