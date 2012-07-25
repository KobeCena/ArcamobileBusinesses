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

#import "LocationViewController.h"
#import <UIKit/UIKit.h>
#import "Setting.h"
#import "Country.h"
#import "City.h"
#import "State.h"
#import "LoginData.h"
#import "ChooseProfileViewController.h"
#import "SettingsManager.h"
#import "FacebookLogin.h"
#import "DirectoryProfileViewController.h"
#import "FacebookProfileViewController.h"
#import "SA_OAuthTwitterController.h"
#import "PushCategoriesViewController.h"

@class SA_OAuthTwitterEngine;


@interface SettingsViewController : UITableViewController <UITableViewDelegate, eAuthDelegate, SA_OAuthTwitterControllerDelegate, PushCategoriesDelegate, SoapDelegate> {
	UIActivityIndicatorView        *twitterActivity;
	SA_OAuthTwitterEngine   	   *_engine;	
	UINavigationController         *infoNavController;
	UIActivityIndicatorView        *facebookActivity;
	UITableViewCell                *cell0;
    UITableViewCell                *cell1;
    UITableViewCell                *cell2;
	DirectoryProfileViewController *directoryProfileViewController;
	FacebookProfileViewController  *facebookProfileViewController;
	UITableViewCell                *loginTableViewCell;
	UIButton                       *buttonLogin;
	UILabel                        *labelLogin;
	UITableViewCell                *facebookLoginTableViewCell;
	UITableViewCell                *onlyDealsTableViewCell;
	UIButton                       *buttonFacebookLogin;
	UILabel                        *labelFacebookLogin;
	UITableViewCell                *twitterTableViewCell;
	UIButton                       *buttonTwitterLogin;
	BOOL                            showTwitterCell;
	SettingsManager                *setm;
	UILabel                        *cell1Label;
	UILabel                        *cell2Label;
	UITextField                    *txtZipCode;
	UISwitch                       *nearbySwitch;
	UISwitch                       *onlyDealsSwitch;
	UITableView                    *tableView; 
	UIScrollView                   *myscroll;
	UISlider                       *mySlider; 
	Setting                        *setting;
	NSManagedObjectContext         *savingManagedObjectContext;
	UIImageView                    *radiusValueSelected;
    UILabel *distanceAmountLabel;
    UIImageView *bgView;
    UIButton *nearbyRadioButton;
    UIButton *zipcodeRadioButton;
    UIButton *locationRadioButton;
	LocationViewController         *locationViewController;
	UITableViewCell                *cellLocation;
	UILabel                        *txtCity;
	UILabel                        *lblCity;
	UILabel                        *infoCity;
	UIButton                       *buttonCleanCity;
	BOOL                            selectingCity;
	UIImageView                    *NearMeSelected;
	UIImageView                    *CitySelected;
	UIImageView                    *ZipCodeSelected;
	ChooseProfileViewController    *chooseProfileViewController;
    

    IBOutlet UILabel *pushDealsNotificationsLabel;
    
}


@property (nonatomic, retain) SettingsManager                  *setm;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *twitterActivity;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *facebookActivity;
@property (nonatomic, retain) ChooseProfileViewController      *chooseProfileViewController;
@property (nonatomic, retain) DirectoryProfileViewController   *directoryProfileViewController;
@property (nonatomic, retain) FacebookProfileViewController    *facebookProfileViewController;
@property (nonatomic, retain) IBOutlet UITableViewCell         *cell0;
@property (nonatomic, retain) IBOutlet UITableViewCell         *cell1;
@property (nonatomic, retain) IBOutlet UITableViewCell         *cell2;
@property (nonatomic, retain) IBOutlet UITableViewCell         *loginTableViewCell;
@property (nonatomic, retain) IBOutlet UIButton                *buttonLogin;
@property (nonatomic, retain) IBOutlet UILabel                 *labelLogin;
@property (nonatomic, retain) IBOutlet UITableViewCell         *facebookLoginTableViewCell;
@property (nonatomic, retain) IBOutlet UITableViewCell         *onlyDealsTableViewCell;
@property (nonatomic, retain) IBOutlet UIButton                *buttonFacebookLogin;
@property (nonatomic, retain) IBOutlet UILabel                 *labelFacebookLogin;
@property (nonatomic, retain) IBOutlet UITableViewCell         *twitterTableViewCell;
@property (nonatomic, retain) IBOutlet UIButton                *buttonTwitterLogin;
@property (nonatomic, retain) IBOutlet UISwitch                *nearbySwitch;
@property (nonatomic, retain) IBOutlet UISwitch                *onlyDealsSwitch;
@property (nonatomic, retain) IBOutlet UITableView             *tableView;
@property (nonatomic, retain) IBOutlet UIButton                *buttonCleanCity;
@property (nonatomic, retain) IBOutlet UILabel                 *cell1Label;
@property (nonatomic, retain) IBOutlet UILabel                 *cell2Label;
@property (nonatomic, retain) IBOutlet UITextField             *txtZipCode;
@property (nonatomic, retain) IBOutlet UILabel                 *txtCity;
@property (nonatomic, retain) IBOutlet UILabel                 *lblCity;
@property (nonatomic, retain) IBOutlet UILabel                 *infoCity;
@property (nonatomic, retain) IBOutlet UIScrollView            *myscroll;
@property (nonatomic, retain) IBOutlet UISlider                *mySlider;
@property (nonatomic, retain) IBOutlet LocationViewController  *locationViewController;
@property (nonatomic, retain) IBOutlet UITableViewCell         *cellLocation;
@property (nonatomic, retain) IBOutlet UIImageView             *NearMeSelected;
@property (nonatomic, retain) IBOutlet UIImageView             *CitySelected;
@property (nonatomic, retain) IBOutlet UIImageView             *ZipCodeSelected;
@property (nonatomic, retain) Setting                          *setting;
@property (nonatomic, retain) NSManagedObjectContext           *savingManagedObjectContext;
@property (nonatomic, retain) IBOutlet UIImageView             *radiusValueSelected;
@property (nonatomic, retain) IBOutlet UILabel *distanceAmountLabel;
@property (nonatomic, retain) IBOutlet UIImageView *bgView;
@property (nonatomic, retain) IBOutlet UIButton *nearbyRadioButton;
@property (nonatomic, retain) IBOutlet UIButton *zipcodeRadioButton;
@property (nonatomic, retain) IBOutlet UIButton *locationRadioButton;

@property (retain, nonatomic) IBOutlet UITableViewCell *testFlightCell;

- (IBAction)checkboxButton:(UIButton *)button;
- (IBAction)textFieldFinishedEditing:(id)sender;
- (IBAction)textFieldDidBeginEditing:(id)sender;
- (IBAction)sliderValueChanged;
- (IBAction)switcherValueChanged:(id)sender;
- (IBAction)switcherDealValueChanged:(id)sender;

- (IBAction)removeCity:(id)sender;

- (void)updateScrolltoPage:(int)page; 
- (void)setNewValueForText:(NSString *) newValue;
- (void)save:(id)sender;

- (void)refreshLogin;
- (void)refreshTwitter;

-(IBAction)logout:(id)sender;
-(IBAction)facebookLogout:(id)sender;
-(IBAction)twitterLogout:(id)sender;

- (void) saveCoordinates;

@end
