//
//  LocationViewController.h
//  Gayborhood
//
//  Created by Roberto on 30/07/10.
//  Copyright 2010 Arca Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationFactory.h"

@class Country;
@class State;
@class City;

@interface LocationViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, LocationFactoryDelegate> {

	UIView *viewPicker;
	UITableView *tableLocation;
	UIPickerView *pickerLocation;
	NSArray *pickerViewArray;
	NSManagedObjectContext *managedObjectContext;
	LocationFactory *locationFactory;
	
	UIButton * selectCitiesByLetterButton;
	
	NSArray *countries;
	NSArray *states;
	NSArray *cities;
	NSArray *citiesIndex;
	NSIndexPath *currentIndexPath;
	
	Country *country;
	State *state;
	City *city;
	
	BOOL wait;
	BOOL seachByCity;
}


@property (nonatomic, retain) IBOutlet UITableView *tableLocation;
@property (nonatomic, retain) IBOutlet UIPickerView *pickerLocation;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *wait;
@property (nonatomic, retain) IBOutlet UIView *viewPicker;
@property (nonatomic, retain) IBOutlet UIButton *selectCitiesByLetterButton;
@property (nonatomic, retain) NSArray *pickerViewArray;
@property (nonatomic, retain) NSIndexPath *currentIndexPath;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign) BOOL seachByCity;

@property (nonatomic, retain) Country *country;
@property (nonatomic, retain) State *state;
@property (nonatomic, retain) City *city;
@property (nonatomic, retain) NSArray *citiesIndex;

@property (nonatomic, retain) NSArray *countries;
@property (nonatomic, retain) NSArray *states;
@property (nonatomic, retain) NSArray *cities;
@property (retain, nonatomic) IBOutlet UILabel *lblFilterBy;

- (void)didSelectLocation:(id)sender;
-(IBAction)selectCitiesByLetter:(id)sender;
@end
