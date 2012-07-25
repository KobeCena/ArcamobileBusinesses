//
//  LocationViewController.m
//  Gayborhood
//
//  Created by Roberto on 30/07/10.
//  Copyright 2010 Arca Solutions, Inc. All rights reserved.
//

#import "LocationViewController.h"
#import "Country.h"
#import "State.h"
#import "City.h"
#import "EdirectoryAppDelegate.h"


#define kViewPickerOffScreen CGRectMake(0, 416, 325, 260)
//#define kViewPickerOnScreen CGRectMake(0, 116, 325, 260)
#define kViewPickerOnScreen CGRectMake(0, 165, 325, 260)
#define kDatePickerOffScreen CGRectMake(0, 416, 325, 250)
//#define kDatePickerOnScreen CGRectMake(0, 156, 325, 250)
#define kDatePickerOnScreen CGRectMake(0, 205, 325, 250)


@implementation LocationViewController
@synthesize lblFilterBy;

@synthesize tableLocation;
@synthesize pickerLocation;
@synthesize pickerViewArray;
@synthesize currentIndexPath;
@synthesize country, state, city, citiesIndex;
@synthesize managedObjectContext;
@synthesize seachByCity, viewPicker, selectCitiesByLetterButton;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

//	country = (Country *)[NSEntityDescription insertNewObjectForEntityForName:@"Country" inManagedObjectContext:self.managedObjectContext];
//	country.country_id = [NSNumber numberWithInt:1];
//	country.name = @"United States";
//	
//
//	state = (State *)[NSEntityDescription insertNewObjectForEntityForName:@"State" inManagedObjectContext:self.managedObjectContext];
//	state.state_id = [NSNumber numberWithInteger:1];
//	state.name = @"North Carolina";
//	state.abbreviation = @"NC";
//	state.country = country;

	locationFactory = [[LocationFactory alloc] init];
	locationFactory.managedObjectContext = self.managedObjectContext;
	locationFactory.delegate = self;
	self.citiesIndex = [NSArray arrayWithObjects: @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];

	
	UIBarButtonItem *buttonLeft = [[UIBarButtonItem alloc] 
                                   initWithTitle:NSLocalizedString(@"Cancel", @"")
                                   style:UIBarButtonItemStyleDone 
                                   target:self 
                                   action:@selector(cancelButtonPressed)
                                   ];
	self.navigationItem.leftBarButtonItem = buttonLeft;
	
}

-(void) cancelButtonPressed {
	[self dismissModalViewControllerAnimated:YES];
}

-(void) viewWillAppear:(BOOL)animated {

	self.seachByCity = NO;
	[self.tableLocation reloadData];
	
}

-(void) addBarButtonDone {

	UIBarButtonItem *buttonRight = [[UIBarButtonItem alloc] 
                                    initWithTitle:NSLocalizedString(@"DoneButton", @"")
                                    style:UIBarButtonItemStyleDone 
                                    target:self 
                                    action:@selector(locationSelected:)
                                    ];
	self.navigationItem.rightBarButtonItem = buttonRight;
	[buttonRight release];
	
	
}

-(void) addBarButtonSave {
	
	UIBarButtonItem *buttonRight = [[UIBarButtonItem alloc] 
                                    initWithTitle:NSLocalizedString(@"SaveBack", @"")
                                    style:UIBarButtonItemStyleDone 
                                    target:self 
                                    action:@selector(saveLocationSelected:)
                                    ];
	self.navigationItem.rightBarButtonItem = buttonRight;
	[buttonRight release];
}

-(void) saveLocationSelected:(id)sender {
	
	EdirectoryAppDelegate *appDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
	

	//self.state.country = self.country;
	//self.city.state = self.state;
	
	
	[appDelegate.settingsViewController.setting setCity:self.city];
	
	
	[appDelegate clearLocationsBut:self.city.state.country entityName:@"Country"];
	[appDelegate clearLocationsBut:self.city.state entityName:@"State"];
	[appDelegate clearLocationsBut:self.city entityName:@"City"];
	
	
	
	self.navigationItem.rightBarButtonItem = nil;
	appDelegate.settingsViewController.txtCity.text = [NSString stringWithFormat:@"%@, %@", [city name], [state abbreviation]];
	[appDelegate.settingsViewController save:nil];
	
	//[self.navigationController popViewControllerAnimated:YES];
	[self dismissModalViewControllerAnimated:YES];
	
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

// return the picker frame based on its size, positioned at the bottom of the page
- (CGRect)pickerFrameWithSize:(CGSize)size {
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGRect pickerRect = CGRectMake(	0.0,
								   screenRect.size.height - 84.0 - size.height,
								   size.width,
								   size.height);
	return pickerRect;
}


-(IBAction)selectCitiesByLetter:(id)sender {

	NSInteger row = [self.pickerLocation selectedRowInComponent:1];
	
	[self didSelectLocation:nil];
	[locationFactory retrieveAllCitiesFromStateAndLetter:self.state letter:[self.citiesIndex objectAtIndex:row]];
	
}

#pragma mark -
#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	// change the left most bar item to what's in the picker
	//currentSystemItem = [pickerView selectedRowInComponent:0];
	//[self createToolbarItems];	// this will re-create all the items
	
	if (component == 1)
		self.lblFilterBy.text = [NSString stringWithFormat:@"%@ \"%@\"", NSLocalizedString(@"SelectCitiesWithLetter", @""), [self.citiesIndex objectAtIndex:row]]; 
}


#pragma mark -
#pragma mark UIPickerViewDataSource

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{	
	if (component == 1) {
		return [self.citiesIndex objectAtIndex:row];
	}
	return [[pickerViewArray objectAtIndex:row] name];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	return 240.0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 40.0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	if (component == 1) {
		return [self.citiesIndex count];
	}
	return [pickerViewArray count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	if (self.seachByCity) {
		return 2;
	}
	return 1;
}

#pragma mark -
#pragma mark UITableViewDataSource methods
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}



-(NSInteger) tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	return 1;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

	NSString * titles[] = {
        NSLocalizedString(@"Country", @""), 
        NSLocalizedString(@"State", @""), 
        NSLocalizedString(@"City", @"")
    };
	return titles[section];
	
}



-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	static NSString *CellIdentifier = @"LocationCell";
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	
	
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
	
	switch (indexPath.section) {
		case 0:
			cell.textLabel.textColor = (country!=nil) ? [UIColor blackColor] : [UIColor grayColor];
			cell.textLabel.text = (country!=nil) ? country.name : NSLocalizedString(@"ClickToSelect", @"");
			break;
		
		case 1:
			cell.textLabel.textColor = (state!=nil) ? [UIColor blackColor] : [UIColor grayColor];
			cell.textLabel.text = (state!=nil) ? state.name : NSLocalizedString(@"ClickToSelect", @"");
			break;
			
		case 2:
			cell.textLabel.textColor = (city!=nil) ? [UIColor blackColor] : [UIColor grayColor];
			cell.textLabel.text = (city!=nil) ? city.name : NSLocalizedString(@"ClickToSelect", @"");
			break;
		
		default:
			break;
	}
	
	
	return cell;
	
}

-(void) showActivityIndicator {
	UITableViewCell *cell = [tableLocation cellForRowAtIndexPath:currentIndexPath];
	UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]; 
	cell.accessoryView = spinner;
	cell.textLabel.text = NSLocalizedString(@"Loading", @"");
	[spinner startAnimating];
	[spinner release];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	if (wait) {
		return;
	}
	
	self.seachByCity = NO;
	
	wait =YES;
	self.currentIndexPath = indexPath;
	UITableViewCell *cell = [tableLocation cellForRowAtIndexPath:currentIndexPath];
	
	
	switch (indexPath.section) {
		case 0:
			[self showActivityIndicator];
			[locationFactory retrieveAllCountries];
			break;
			
		case 1:
			if (self.country != nil) {
				[self showActivityIndicator];
				[locationFactory retrieveAllStatesFromCountry:self.country];
			} else {
				cell.textLabel.text = NSLocalizedString(@"SelectCountryFirst", @"");
				wait = NO;
			}

			break;

		case 2:
			if (self.state != nil) {
				self.seachByCity = YES;
				[self showActivityIndicator];
				[locationFactory retrieveAllCitiesFromState:self.state];
			
			} else {
				cell.textLabel.text = NSLocalizedString(@"SelectStateFirst", @"");
				wait = NO;
			}
			break;

			
		default:
			break;
	}
	
}


-(void) locationDidFinishWithArray:(NSArray *)locations {
	wait = NO;
	UITableViewCell *cell = [tableLocation cellForRowAtIndexPath:currentIndexPath];
	cell.accessoryView = nil;
	
	if ([locations count]==1) {
		
		id object = [locations objectAtIndex:0];
		
		switch (currentIndexPath.section) {
			case 0:
				self.country = object;				
				break;
			
			case 1:
				self.state = object;
				break;

			case 2:
				self.city = object;
				[self addBarButtonSave];
				break;

			
			default:
				break;
		}
		
		
		[tableLocation reloadData];
		return;
	}

	
	
	
	if ([locations count] < 1) {
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NoResults", @"")
														message:NSLocalizedString(@"NoResultsFound", @"")
													   delegate:nil 
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil
                              ];
		[alert show];
		[alert release];
		[self.tableLocation reloadData];
		return;
		
	}
	
	self.pickerViewArray = locations;
	[self.pickerLocation reloadAllComponents];
	
	if ([self.pickerLocation numberOfComponents] > 1) {
		NSInteger row = [self.pickerLocation selectedRowInComponent:1];
		self.lblFilterBy.text = [NSString stringWithFormat:@"%@ \"%@\"", NSLocalizedString(@"SelectCitiesWithLetter", @""),[self.citiesIndex objectAtIndex:row]]; 
	}
		NSLog(@"Here!!");
	
	[self didSelectLocation:nil];
	[self.pickerLocation selectedRowInComponent:0];
}




- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [self setLblFilterBy:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) locationSelected:(id)sender {
	

	int row = [pickerLocation selectedRowInComponent:0];
	
	
	id objectSelected = [pickerViewArray objectAtIndex:row];
	

	
	switch (currentIndexPath.section) {
		case 0:
			self.country = objectSelected;
			self.state = nil;
			self.city = nil;
			self.navigationItem.rightBarButtonItem = nil;
			break;
			
		case 1:
			self.state = objectSelected;
			self.city = nil;
			self.navigationItem.rightBarButtonItem = nil;
			break;
			
		case 2:
			self.city = objectSelected;
			[self addBarButtonSave];
			break;
			
			
		default:
			break;
	}
	

	[self didSelectLocation:nil];
	[self.tableLocation reloadData];
	
}

-(void) unLockScreen{
    
    for (UIView *subView in self.view.subviews) {
        if (subView.tag == 987654321) {
            [subView removeFromSuperview];
        }
    }
    
}

-(void) lockScreen{
    
    CGRect lockViewSize = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.viewPicker.frame.origin.y );
    
    //draws a lock view
    UIView *lockView = [[UIView alloc] initWithFrame:lockViewSize];
    
    
    [lockView setTag:987654321];
    [lockView setBackgroundColor:[UIColor blackColor]];
    lockView.alpha = 0.5f;
    
    [self.view addSubview:lockView];
    [self.view bringSubviewToFront:lockView];
    
    [lockView release];
    
    
}

/**
 * Move the UIPickerView on screen if it is off screen, or off screen if it is
 * on screen. Wrap the logic around a UIView animation to get a slide effect.
 */
- (void)didSelectLocation:(id)sender {
	[UIView beginAnimations:@"PickerTransition" context:nil];
	[UIView setAnimationDuration:0.3];
	
	
	if (self.seachByCity) {
		self.pickerLocation.frame = CGRectMake(0, 44, 325, 216);
	} else {
		self.pickerLocation.frame = CGRectMake(0, 0, 325, 216);
	}

	
	if(self.viewPicker.frame.origin.y < kViewPickerOffScreen.origin.y) { // off screen
		self.viewPicker.frame = (self.seachByCity) ? kViewPickerOffScreen : kDatePickerOffScreen;
        [self unLockScreen];
		// update new transit lines
		
	} else { // on screen, show a done button
		self.viewPicker.frame = (self.seachByCity) ? kViewPickerOnScreen : kDatePickerOnScreen;
		//self.navigationItem.rightBarButtonItem.title = @"Done";
		[self addBarButtonDone];
        [self lockScreen];
	}
	
	
//	if(self.pickerLocation.frame.origin.y < kDatePickerOffScreen.origin.y) { // off screen
//		self.pickerLocation.frame = kDatePickerOffScreen;
//		// update new transit lines
//		
//	} else { // on screen, show a done button
//		self.pickerLocation.frame = kDatePickerOnScreen;
//		//self.navigationItem.rightBarButtonItem.title = @"Done";
//		[self addBarButtonDone];
//	}

	[UIView commitAnimations];
}




- (void)dealloc {
	[selectCitiesByLetterButton release];
	[viewPicker release];
	[managedObjectContext release];
	[currentIndexPath release];
	[city release];
	[citiesIndex release];
	[cities release];
	[state	release];
	[states release];
	[country release];
	[countries release];
	[locationFactory release];
	[pickerViewArray release];
	[tableLocation release];
	[pickerLocation release];
    [lblFilterBy release];
    [super dealloc];
}


@end
