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

#import "SettingsViewController.h"
#import "EdirectoryAppDelegate.h"
#import "SA_OAuthTwitterEngine.h"
#import "EdirectoryAppDelegate.h"
#import "CoreUtility.h"
#import "ARCAserver_businesses.h"
#import "EdirectoryParserToWSSoapAdapter.h"
#import "ARCACoordinateReturn.h"


@implementation SettingsViewController

@synthesize cell0, cell1, cell2, loginTableViewCell, cell1Label, cell2Label, lblCity, cellLocation, nearbySwitch, tableView, myscroll, mySlider, txtZipCode, txtCity;
@synthesize buttonLogin, labelLogin, facebookLoginTableViewCell;
@synthesize buttonFacebookLogin, labelFacebookLogin;
@synthesize setting, savingManagedObjectContext, locationViewController, buttonCleanCity;
@synthesize infoCity;
@synthesize radiusValueSelected;
@synthesize distanceAmountLabel;
@synthesize bgView;
@synthesize nearbyRadioButton;
@synthesize zipcodeRadioButton;
@synthesize locationRadioButton;
@synthesize testFlightCell;
@synthesize NearMeSelected, CitySelected, ZipCodeSelected;
@synthesize chooseProfileViewController;
@synthesize directoryProfileViewController;
@synthesize facebookProfileViewController;
@synthesize facebookActivity;
@synthesize twitterTableViewCell, buttonTwitterLogin, twitterActivity;
@synthesize setm;
@synthesize onlyDealsTableViewCell;
@synthesize onlyDealsSwitch;

- (void)dealloc {
	[onlyDealsTableViewCell         release];
	[setm							release];
	[twitterActivity                release];
	[twitterTableViewCell		    release];
	[buttonTwitterLogin             release];
	[facebookActivity               release];
	[facebookProfileViewController  release];
	[directoryProfileViewController release];
	[chooseProfileViewController    release];
	[lblCity                        release];
	[infoCity                       release];
	[buttonCleanCity                release];
	[txtCity                        release];
	[cellLocation                   release];
	[locationViewController         release];
	[setting                        release];
	[savingManagedObjectContext     release];
	[cell0                          release];
	[cell1                          release];
	[cell2                          release];
	[buttonFacebookLogin            release];
	[labelFacebookLogin             release];
	[facebookLoginTableViewCell     release];
	[loginTableViewCell             release];
	[buttonLogin                    release];
	[labelLogin                     release];
	[txtZipCode                     release];
	[nearbySwitch                   release];
	[onlyDealsSwitch                release];
	[tableView                      release];
	[myscroll                       release];
	[mySlider                       release];
	[radiusValueSelected            release];
	[NearMeSelected                 release];
	[CitySelected                   release];
	[ZipCodeSelected                release];	
	
    [pushDealsNotificationsLabel release];
    [distanceAmountLabel release];
    [bgView release];
    [nearbyRadioButton release];
    [zipcodeRadioButton release];
    [locationRadioButton release];
    [testFlightCell release];
    [super dealloc];
}

-(void)markSelectedRadioButton:(int)option{
    switch (option) {
        case 1:
            [self.nearbyRadioButton   setSelected:YES];
            [self.locationRadioButton setSelected:NO];            
            [self.zipcodeRadioButton  setSelected:NO];

            break;
        case 2:
            [self.nearbyRadioButton   setSelected:NO];
            [self.locationRadioButton setSelected:YES];            
            [self.zipcodeRadioButton  setSelected:NO];
            break;
        case 3:
            [self.nearbyRadioButton   setSelected:NO];
            [self.locationRadioButton setSelected:NO];            
            [self.zipcodeRadioButton  setSelected:YES];
            break;
        default:
            break;
    }
}

-(void) markSelectedCell{
    
    if(!isEmpty(self.setting.zipCode)) {
		[self markSelectedRadioButton:3];
	} else if (self.setting.city != nil) {
		[self markSelectedRadioButton:2];
	} else {
		[self markSelectedRadioButton:1];
	}
    
    
    
	//determines wich cell has the blue border indicating selection
	[self.NearMeSelected setHidden: (([setting.isNearMe boolValue] == YES) ? NO : YES)];
	[self.CitySelected setHidden: ((setting.city == nil) ? YES : NO)];
	[self.ZipCodeSelected setHidden: (([setting.zipCode isEqualToString:@""]) ? YES : NO)];
    
	[self.buttonCleanCity setHidden: ((setting.city == nil) ? YES : NO)];
	[self.infoCity setHidden: ((setting.city == nil) ? NO : YES)];	
	
}

-(void) viewWillAppear:(BOOL)animated {
	
	[twitterActivity stopAnimating];
	
	selectingCity = NO;
	
	[self markSelectedCell];
	
	[self refreshLogin];
	[self refreshTwitter];
    
	/*for(UIView *view in self.tabBarController.tabBar.subviews) {  
		if([view isKindOfClass:[UIImageView class]]) {  
			[view removeFromSuperview];  
		}  
	}      
    
    [self.tabBarController.tabBar insertSubview:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tabBar04.png"]] autorelease] atIndex:0];  
	*/
    
}

-(void)refreshTwitter {
	
	//if ([[setm twitterApiKey] length] == 0) return;
	
	_engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
	_engine.consumerKey    = [setm twitterApiKey];
	_engine.consumerSecret = [setm twitterApiSecret];	
	
    
    
	[buttonTwitterLogin setTitle: (![_engine isAuthorized]) ? NSLocalizedString(@"Authorize", nil) : _engine.username forState:UIControlStateNormal];
	[_engine release];
}

-(void)refreshLogin{
	
	LoginData *login = [[LoginData alloc] init];
	
	if ([login profileExist] == YES) {
		[labelLogin setText:[[login profile] name]];
		[buttonLogin setTitle:NSLocalizedString(@"LogoutButton", @"") forState:UIControlStateNormal];
	} else {
		[labelLogin setText:NSLocalizedString(@"DealsLoginOption", @"")];
		[buttonLogin setTitle:NSLocalizedString(@"LoginButton", @"") forState:UIControlStateNormal];
	}
	
	if ([login facebookProfileExist] == YES) {
//		[labelFacebookLogin setText: [NSString stringWithFormat:@" %@ - Click for logout", [[login facebookProfile] name]]  ];
		[labelFacebookLogin setText: [NSString stringWithFormat:@" %@", [[login facebookProfile] name]]  ];        
		[buttonFacebookLogin setTitle:NSLocalizedString(@"LogoutButton", @"") forState:UIControlStateNormal];
	} else {
		[labelFacebookLogin setText:NSLocalizedString(@"NotLoggedIn", @"")];
		[buttonFacebookLogin setTitle:NSLocalizedString(@"LoginButton", @"") forState:UIControlStateNormal];
	}
	
	[tableView reloadData];
	
	[login release];
	
}


-(void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:YES];
	
	if (![self.setting.isNearMe boolValue]) {
		
		if ((self.setting.zipCode==nil || [self.setting.zipCode length]<1) && ((setting.city == nil) && (!selectingCity) ) )  {
			
			[self.nearbySwitch setOn:YES];
			[self.setting setIsNearMe:[NSNumber numberWithBool:YES]];
			[self save:nil];
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SettingsTitle", @"")
															message:NSLocalizedString(@"NoSearchModeSelected" , nil)
														   delegate:nil 
												  cancelButtonTitle:NSLocalizedString(@"OK", @"")
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
			
		}
	}
	
	
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
#pragma mark - VIEW DID LOAD
- (void)viewDidLoad {
	
	[super viewDidLoad];	

	setm = [[SettingsManager alloc] initWithNoWhait];
	//setm = [[SettingsManager alloc] init];
    
    //setup the backgroundView for this table
    [self.tableView setBackgroundView:self.bgView];

	//if ( isEmpty([setm twitterApiKey]) ||  isEmpty([setm twitterApiSecret]) ) {
	//	showTwitterCell = FALSE;
	//}else {
		showTwitterCell = TRUE;
	//}
		
	[self.nearbySwitch setOn: [setting.isNearMe boolValue]];
	[self.onlyDealsSwitch setOn:[setting.isOnlyDeals boolValue]];
	[self.txtZipCode setText:[setting zipCode]];
	
	float distance = [[setting distance] floatValue] / 0.2;
	[self.mySlider setValue:distance animated:YES ];
	[self sliderValueChanged];
	
	UIImage *stetchLeftTrack = [[UIImage imageNamed:@"slider-bg1.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
	UIImage *stetchRightTrack = [[UIImage imageNamed:@"slider-bg1.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
	
	self.mySlider.backgroundColor = [UIColor clearColor];        
	[self.mySlider setThumbImage: [UIImage imageNamed:@"slider_knob2.png"] forState:UIControlStateNormal];
	[self.mySlider setThumbImage: [UIImage imageNamed:@"slider_knob2.png"] forState:UIControlStateHighlighted];
	
	[self.mySlider setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
	[self.mySlider setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
	[self.mySlider setMinimumTrackImage:stetchLeftTrack forState:UIControlStateHighlighted];
	[self.mySlider setMaximumTrackImage:stetchRightTrack forState:UIControlStateHighlighted];
	
	self.mySlider.minimumValue = 5.0;
	self.mySlider.maximumValue = 100.0;
    
    [lblCity setText:NSLocalizedString(@"searchByLocation", nil)];
    [infoCity setText:NSLocalizedString(@"ClickToSelectCity", nil)];
	[cell1Label setText:NSLocalizedString(@"NearMe", nil)];
    [cell2Label setText:NSLocalizedString(@"Zipcode", nil)];
    
    [pushDealsNotificationsLabel setText:NSLocalizedString(@"PushBusinessNotifications", nil)];
    
    
}

-(IBAction)twitterLogout:(id)sender
{
	
	_engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
	_engine.consumerKey    = [setm twitterApiKey];
	_engine.consumerSecret = [setm twitterApiSecret];	
	
	if (![_engine isAuthorized]) {
		[twitterActivity startAnimating];	
		
		
		UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:_engine delegate:self];
		
		[self presentModalViewController: controller animated: YES];
	} else {
		[_engine clearAccessToken];
		[buttonTwitterLogin setTitle: NSLocalizedString(@"Authorize", @"") forState:UIControlStateNormal];
	}
	
	
	[_engine release];
	
}

-(IBAction)logout:(id)sender
{
	
	LoginData *login = [[LoginData alloc] init];
	
	if ([login profileExist]) {
		[login logoutProfile];
		
		[labelLogin setText:NSLocalizedString(@"DealsLoginOption", @"")];
		[buttonLogin setTitle:NSLocalizedString(@"LoginButton", @"") forState:UIControlStateNormal];
        
        [[NSNotificationCenter defaultCenter] postNotificationName: @"SETTING::LOGOUT" object: self];
	} else {
		chooseProfileViewController = [[ChooseProfileViewController alloc] initWithNibName:@"ChooseProfileViewController" bundle:nil];
		[chooseProfileViewController setTitle: NSLocalizedString(@"ProfileNecessary", @"")];
		[chooseProfileViewController setSetm:setm];
		[chooseProfileViewController setHideFacebook:YES];
		[chooseProfileViewController setDelegate:self];
		[[self navigationController] pushViewController:chooseProfileViewController animated: YES];
	}
	
	[login release];
	
}

-(IBAction)facebookLogout:(id)sender
{
	
	LoginData *login = [[LoginData alloc] init];
	
	if ([login facebookProfileExist]) {
		[login logoutFacebookProfile];
		
		FacebookLogin *fb = [[FacebookLogin alloc] init];
		[fb logout];
		[fb release];
		
		[labelFacebookLogin setText:NSLocalizedString(@"NotLoggedIn", @"")];
		[buttonFacebookLogin setTitle:NSLocalizedString(@"LoginButton", @"") forState:UIControlStateNormal];
		
		[tableView reloadData];
        
        [[NSNotificationCenter defaultCenter] postNotificationName: @"SETTING::LOGOUT" object: self];
		
	} else {
		
		[buttonFacebookLogin setEnabled:NO];
		
		chooseProfileViewController = [[ChooseProfileViewController alloc] initWithNibName:@"ChooseProfileViewController" bundle:nil];
		[chooseProfileViewController setTitle: NSLocalizedString(@"ProfileNecessary", @"")];
		[chooseProfileViewController setSetm:setm];
		[chooseProfileViewController setDelegate:self];
		[facebookActivity startAnimating];
		[labelFacebookLogin setText:NSLocalizedString(@"Wait", @"")];
		//[[self navigationController] pushViewController:chooseProfileViewController animated: YES];
		[chooseProfileViewController FacebookButtonSelected:nil];
		
	}
	
	[login release];
	
	
	
}


- (void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	
	self.tableView.scrollsToTop = YES;
	
	[self.navigationController setTitle:NSLocalizedString(@"SettingsTitle", @"")];
	
}

- (IBAction)removeCity:(id)sender {
	
	self.setting.city = nil;
	[self.txtCity setText:nil];
	[self save:nil];
	if (self.setting.city == nil) {
		[self.buttonCleanCity setHidden:YES];
		[self.infoCity setHidden: NO];
	}
}

// Section Titles 
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	NSLocale *locale = [NSLocale currentLocale];
	NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
	
	NSString *countryName = [locale displayNameForKey: NSLocaleCountryCode
												value: countryCode];
	
	
	switch (section) {
		case 0:
			return NSLocalizedString(@"SearchNearby", @"");
			break;			
		case 1:
			break;			
		case 2:
			break;		
		case 3:
			return NSLocalizedString(@"LoginInformation", @"");
			break;
		case 4: //facebook and twiter cells
			break;
		case 5:
			return  NSLocalizedString(@"Business Finder", nil);            
			break;
		case 6:
            return @"Feedback(Testers only)";
			break;
		case 7:
            return @"Feedback(Testers only)";
			break;
		default:
			break;
	}
	
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // ATTENTION: To shoe the pushNotifications cell just return 6
    //return 5;
    return 6;
    //return 7;    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 4) {
        return 2;
    }else{
        return 1;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
			return self.cell0;
			break;
		case 1:
			[self.buttonCleanCity setHidden: ((self.setting.city == nil) ? YES : NO)];
			[self.infoCity setHidden: ((self.setting.city == nil) ? NO : YES)];
			if (setting.city != nil) {
				self.txtCity.text = [NSString stringWithFormat:@"%@, %@", [setting.city name], [setting.city.state abbreviation]];
			}
            
            [self.cellLocation setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            
			return self.cellLocation;
			break;
			
		case 2:
			return self.cell1;
			break;			
		case 3:
            [self.loginTableViewCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
			return self.loginTableViewCell;
			break;
			
		case 4:
			switch (indexPath.row) {
                case 0:
                    [self.facebookLoginTableViewCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    return self.facebookLoginTableViewCell;
                    break;
                case 1:
                    [self.twitterTableViewCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    
                    if (showTwitterCell) {
                        return self.twitterTableViewCell;
                    } else {
                        return self.onlyDealsTableViewCell;
                    }                    
                default:
                    break;
            }
            break;
			
		case 5:            
            [onlyDealsTableViewCell setSelectionStyle:UITableViewCellEditingStyleNone];
            
			return self.onlyDealsTableViewCell;
			break;

		case 6:
            return self.testFlightCell;
            break;
		default:
			break;
	}
}


- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    CGFloat result;
    
    switch (indexPath.section) {
		case 0:
            result = 90.0;
            break;
        default:
            result = 46.0;
			break;
	}
    
    return result;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section == 0 && indexPath.row == 0) {

        [self markSelectedRadioButton:1];
		
		[self.nearbySwitch setOn:YES animated:YES];
		
		[self removeCity:nil];
		[self.txtZipCode setText:@""];
		
		if ([self.txtZipCode isFirstResponder]) {
			[self.txtZipCode resignFirstResponder];
		}
		
	}
	
	if (indexPath.section == 1 && indexPath.row == 0) {

        [self markSelectedRadioButton:2];
		
		selectingCity = YES;
		[self.nearbySwitch setOn:FALSE animated:YES];
		[self.setting setIsNearMe:[NSNumber numberWithBool:NO]];

		[self.txtZipCode setText:@""];
		
		if ([self.txtZipCode isFirstResponder]) {
			[self.txtZipCode resignFirstResponder];
		}
		
		[self.locationViewController setManagedObjectContext:self.savingManagedObjectContext];
		[self.locationViewController setCountry: self.setting.city.state.country];
		[self.locationViewController setState: self.setting.city.state];
		[self.locationViewController setCity: self.setting.city];
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:locationViewController];
        nav.view.backgroundColor = [UIColor clearColor]; 
        [nav.view setClearsContextBeforeDrawing:NO];
        [nav setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
		[nav.navigationBar setBarStyle:UIBarStyleBlack];
		[self presentModalViewController:nav animated:YES];
		[nav release];

        
        
		return;
		
	}
	if (indexPath.section == 2 && indexPath.row == 0) {
        [self markSelectedRadioButton:3];
		[self.txtZipCode becomeFirstResponder];
	}
	
	
	if (indexPath.section == 3 ) {
		
        [self logout:nil];
	}
	
	if (indexPath.section == 4) {
		
        
        if (indexPath.row == 0) { //facebook cell
            [self facebookLogout:nil];
        }

        if (indexPath.row == 1) { //twitter cell
            [self twitterLogout: nil];
        }

        
        
        
	}
    
    if (indexPath.section == 5) {
        
        
        PushCategoriesViewController *pc = [[PushCategoriesViewController alloc] initWithNibName:@"PushCategoriesViewController" bundle:nil];
        [pc setDelegate:self];
		//Initialize the navigation controller with the info view controller
		infoNavController = [[UINavigationController alloc] initWithRootViewController:pc];
        [infoNavController.navigationBar setBarStyle:UIBarStyleBlack];
        [pc release];
        [self.navigationController presentModalViewController:infoNavController animated:YES];
        
        
    }
	
//    if (indexPath.section == 6) {
//         [TestFlight openFeedbackView];
//    }
	
	[self save:nil];
	
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [self setTestFlightCell:nil];
    [self setLocationRadioButton:nil];
    [self setZipcodeRadioButton:nil];
    [self setNearbyRadioButton:nil];
    [self setBgView:nil];
    [self setDistanceAmountLabel:nil];
    [pushDealsNotificationsLabel release];
    pushDealsNotificationsLabel = nil;
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (IBAction)sliderValueChanged{
	
	[self.radiusValueSelected setHidden:YES];
	
	int distance = [self.mySlider value] * 0.2; 
    
    NSString *pluralOrSingle = @"DistanceUnit";
    if (distance > 1) {
        pluralOrSingle = @"DistancePlural";
    }
    
    [self.distanceAmountLabel setText: [NSString stringWithFormat:NSLocalizedString(@"XIntDistance", @""), distance, NSLocalizedString(pluralOrSingle, @"") ]];
    
	double svalue = mySlider.value / 10.0;
	double dvalue = svalue - floor(svalue);
	//Check if the decimal value is closer to a 10 or not
	if(dvalue >= 0.25 && dvalue < 0.75)
		dvalue = floorf(svalue) + 1.0f;
	else
		dvalue = roundf(svalue);
	
	
//	switch (((int)(dvalue * 10))) {
//		case 0:
//			[self animatedValueSelected:39 FromupY:12 sliderValue:10];
//			break;
//			
//		case 10:
//			[self animatedValueSelected:39 FromupY:12 sliderValue:10];
//			break;
//		case 20:
//			[self animatedValueSelected:64 FromupY:12 sliderValue:20];
//			break;
//		case 30:
//			[self animatedValueSelected:89 FromupY:12 sliderValue:30];
//			break;
//		case 40:
//			[self animatedValueSelected:114 FromupY:12 sliderValue:40];
//			break;
//		case 50:
//			[self animatedValueSelected:138 FromupY:12 sliderValue:50];
//			break;
//		case 60:
//			[self animatedValueSelected:163 FromupY:12 sliderValue:60];
//			break;
//		case 70:
//			[self animatedValueSelected:186 FromupY:12 sliderValue:70];
//			break;
//		case 80:
//			[self animatedValueSelected:209 FromupY:12 sliderValue:80];
//			break;
//		case 90:
//			[self animatedValueSelected:236 FromupY:12 sliderValue:90];
//			break;
//		case 100:
//			[self animatedValueSelected:260 FromupY:12 sliderValue:100];
//			break;
//			
//		default:
//			break;
//	}
	
	[self save:nil];
}

//-(void)animatedValueSelected:(int)upX FromupY:(int)upY sliderValue:(int)sliderValue{
//	[self.radiusValueSelected setHidden:NO];
//	self.radiusValueSelected.frame = CGRectMake(upX, upY, 24, 23);
//	
//	self.mySlider.value = sliderValue;
//	
//	//animates the loader disapearing
//	CGContextRef context = UIGraphicsGetCurrentContext();
//	[UIView beginAnimations:nil context:context];
//	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//	[UIView setAnimationDelegate:self];
//	//[UIView setAnimationDidStopSelector:@selector(hidingLoaderFinished)];
//	[UIView setAnimationDuration:0.3];
//	
//	
//	self.radiusValueSelected.frame = CGRectMake((upX-10), (upY-10), 44, 43);
//	
//	[UIView commitAnimations];
//	
//	//animates the loader disapearing
//	[UIView beginAnimations:nil context:context];
//	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//	[UIView setAnimationDelegate:self];
//	//[UIView setAnimationDidStopSelector:@selector(hidingLoaderFinished)];
//	[UIView setAnimationDuration:0.3];
//	
//	
//	self.radiusValueSelected.frame = CGRectMake(upX, upY, 24, 23);
//	
//	[UIView commitAnimations];
//	
//}

- (IBAction)switcherValueChanged:(id)sender{
	UISwitch* nearmeSwitch = sender;
	
	if ([nearmeSwitch isOn]) {
		[self removeCity:nil];
		[[self txtZipCode] setText:@""];
	}
	
	[self save:nil];
	
	[self markSelectedCell];
	
}

- (IBAction)switcherDealValueChanged:(id)sender {
	
	[self save:nil];
	
	[self markSelectedCell];
	
    
    UISwitch *dealPushStart = (UISwitch *)sender;
    if ([dealPushStart isOn]) {
        
        PushCategoriesViewController *pc = [[PushCategoriesViewController alloc] initWithNibName:@"PushCategoriesViewController" bundle:nil];
        [pc setDelegate:self];
		//Initialize the navigation controller with the info view controller
		infoNavController = [[UINavigationController alloc] initWithRootViewController:pc];
        [infoNavController.navigationBar setBarStyle:UIBarStyleBlack];
        [pc release];
        [self.navigationController presentModalViewController:infoNavController animated:YES];
        
        
//        [(EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate] startUpdateLocation];
    } else {
        
//        [(EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate] stopUpdateLocation];
        
        
    }
    
}



- (IBAction)textFieldDidBeginEditing:(id)sender {
	
	[self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:cell1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
	[self.nearbySwitch setOn:FALSE animated:YES];
	[self removeCity:nil];
	
	[self save:nil];
	
	[self markSelectedCell];
	[self.ZipCodeSelected setHidden:NO];
	
}

- (IBAction)textFieldFinishedEditing:(id)sender{
	UITextField *whichTextField = (UITextField *)sender;
	[whichTextField resignFirstResponder];
	[self save:nil];
    [self markSelectedCell];
}

-(void)save:(id)sender {
	
	int distance = [self.mySlider value] * 0.2; 
	
	[setting setIsNearMe:[NSNumber numberWithBool:[nearbySwitch isOn]]];
	[setting setIsOnlyDeals:[NSNumber numberWithBool:[onlyDealsSwitch isOn]]];
	
	[setting setZipCode: txtZipCode.text];
	[setting setDistance: [NSNumber numberWithInt:distance]];
	
	NSError *error;
	//if (![savingManagedObjectContext save:&error]) {
	if (![savingManagedObjectContext save:&error]) {
		UIAlertView *errorAlert = [[UIAlertView alloc] 
                                   initWithTitle:NSLocalizedString(@"SaveErrorTitle", nil)
                                   message:NSLocalizedString(@"SaveErrorMessage", nil)
                                   delegate:nil 
                                   cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                   otherButtonTitles:nil
                                   ];
		[errorAlert show];
		[errorAlert release];
	}
    
    
//    [[[[self tabBarController] viewControllers] objectAtIndex:0] popToRootViewControllerAnimated:NO];
//    [[[[self tabBarController] viewControllers] objectAtIndex:1] popToRootViewControllerAnimated:NO];
//    [[[[self tabBarController] viewControllers] objectAtIndex:2] popToRootViewControllerAnimated:NO];
    
    [self saveCoordinates];
    
}

#pragma mark eAuthDelegate
-(void)didLogin {
	[facebookActivity stopAnimating];
	[buttonFacebookLogin setEnabled:YES];
	
	
	[[self navigationController] popToRootViewControllerAnimated:YES];
	[self refreshLogin];
}

-(void)didNotLogin {
	[facebookActivity stopAnimating];
	[buttonFacebookLogin setEnabled:YES];
	
	
	[self refreshLogin];
}

//=============================================================================================================================
#pragma mark SA_OAuthTwitterEngineDelegate
- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username {
	NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setObject: data forKey: @"authData"];
	[defaults synchronize];
}

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username {
	return [[NSUserDefaults standardUserDefaults] objectForKey: @"authData"];
}

//=============================================================================================================================
#pragma mark TwitterEngineDelegate
- (void) requestSucceeded: (NSString *) requestIdentifier {
	NSLog(@"Request %@ succeeded", requestIdentifier);
}

- (void) requestFailed: (NSString *) requestIdentifier withError: (NSError *) error {
	NSLog(@"Request %@ failed with error: %@", requestIdentifier, error);
}


#pragma mark - UITableViewDelegate methods
- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section{
    
    
    UIView * aView = [[[UIView alloc] init] autorelease];
    
    aView.backgroundColor = [UIColor clearColor];
    UILabel * label = [[[UILabel alloc] init] autorelease];
    
    CGRect tam = label.frame;
    tam.origin.x = 12;
    tam.origin.y = 0;
    tam.size.width = 320;
    tam.size.height = 30;
    [label setFrame:tam];
    
    label.font = [UIFont boldSystemFontOfSize:17];
    
    NSString *title=@"";
    
	switch (section) {
		case 0:
			title = NSLocalizedString(@"SearchNearby", @"");
			break;
		case 1:
			break;			
		case 2:
			break;
		case 3:
			title = NSLocalizedString(@"LoginInformation", @"");
			break;
		case 4:
			break;
		case 5:
//            if (showTwitterCell)
//            {
//                title = NSLocalizedString(@"TwitterAuthorization", @"");
//            } else {
//                title = NSLocalizedString(@"Deal", nil);
//            }
            title = NSLocalizedString(@"BusinessFinder", nil);
			break;
		case 6:
			title = NSLocalizedString(@"BusinessFinder", nil);
			break;
		default:
			break;
	}

    
    [label setText: title ];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor grayColor];
    label.backgroundColor = [UIColor clearColor]; 
    
    [aView addSubview:label];
    [aView bringSubviewToFront:label];
    
    return aView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    CGFloat result = 30.0;
    
	switch (section) {
		case 0:
			break;
		case 1:
            result = -10.0;
			break;			
		case 2:
            result = -10.0;
			break;
		case 3:
			break;
		case 4:
            result = -10.0;            
			break;
		case 5:
			break;
		case 6:
			break;
		default:
			break;
	}

    return result;
}

-(void)pushCategoriesDoneWithCount:(NSInteger)count andOptions:(NSString *)newOptions {
    
    if (count == 0) {
        [onlyDealsSwitch setOn:NO];
    } else {
        [onlyDealsSwitch setOn:YES];
    }
    [self save:nil];

    EdirectoryAppDelegate *app = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *token = [[app deviceToken] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSString *myDeviceID = [[UIDevice currentDevice] uniqueIdentifier];
    
	NSString            *path =                 [[NSBundle mainBundle] pathForResource:@"ConnectionStrings" ofType:@"plist"];		
	NSDictionary        *connPlist =            [NSDictionary dictionaryWithContentsOfFile:path];
	NSString            *url =                  [connPlist objectForKey:@"PushNotification"];
	NSString            *userAgent =            @"Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en)";
	NSMutableURLRequest *eDirectoryURLRequest = [[NSMutableURLRequest alloc] init];

    NSMutableString *params = [[NSMutableString alloc] init];
    
    [params appendString:url];
    [params appendFormat:@"?id=%@",myDeviceID];
    [params appendFormat:@"&token=%@", token];
    
    if (count > 0) {
        [params appendFormat:@"&notifications=YES&%@", newOptions];
        
    } else {
        [params appendString:@"&notifications=NO"];
    }
    
    [params appendString:@"&module=businesses"];
	[eDirectoryURLRequest setURL: [NSURL URLWithString:params]];
    
    [params release];
    
	[eDirectoryURLRequest setValue:userAgent forHTTPHeaderField:@"User-Agent"];
	NSURLConnection *eDirectoryConnection = [[NSURLConnection alloc] initWithRequest:eDirectoryURLRequest delegate:nil];
    
    [eDirectoryURLRequest release];
    [eDirectoryConnection release];
    
}
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
