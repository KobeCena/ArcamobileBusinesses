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

#import <CoreLocation/CoreLocation.h>
#import "eDirectoryUserLocation.h"

@implementation EdirectoryUserLocation

@synthesize locationManager, delegate;


#pragma mark -
#pragma mark EdirectoryUserLocation Logic

-(void) dealloc{
    
    
    [self setDelegate:nil];
    [delegate release];
    
	[locationManager release];
	[super dealloc];
}


/**
 Performs all necessary initializations to put this object in a consistent state.
 **/
-(void)setupEdirectoryUserLocation{
	
	self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.delegate = self;
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	
	if (self.locationManager.locationServicesEnabled == NO) {
		//The eDirectoryUserLocation is responsible to show the error message to user
		UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] 
                                              initWithTitle:NSLocalizedString(@"LocationServicesDisabledTitle", @"")
                                              message:NSLocalizedString(@"LocationServicesDisabledMsg", @"")
                                              delegate:nil 
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil
                                              ];
		[servicesDisabledAlert show];
		[servicesDisabledAlert release];
		
		//informs the delegate that the LocationsService is not enable
		if (self.delegate != nil && [self.delegate respondsToSelector:@selector(locationsServiceIsNotEnable:)]) {
			[self.delegate locationsServiceIsNotEnable];
		}
		
	}else {
		//Asks location manager to update position
		[self.locationManager startUpdatingLocation];
		//TODO: We need to put the amount of time for GPS waiting in the Settings tab in the future versions.
		//This will garantee that in case of an amount of 30 seconds with no GPS response, we can proceed to cancel the LocationManager
		[self performSelector:@selector(stopGettingLocationWhenMaximumWaitingTimeExpired) withObject:nil afterDelay:30.0];
	}
	
}

- (void)stopGettingLocationWhenMaximumWaitingTimeExpired {
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
	
	//This in just the case when the location Manager did not received a new Location after 30 secs.
	//informs the delegate that the LocationsService was not able to get a newlLocation after 30 secs.
	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didHitTheMaximumTimeIntervalWithNoResults)]) {
		[self.delegate didHitTheMaximumTimeIntervalWithNoResults];
	}
}


/**
 This method will stops the locationManager to gather data about user location
 **/
- (void)stopGettingLocation {
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
}

#pragma mark -
#pragma mark CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{

	/*
	//Verifies the lat time when the location was obtained
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;
    // Avoid invalid measurement for GPS position
    if (newLocation.horizontalAccuracy < 0) return;
	*/
	
	// We`re going to stop the location manager ASAP to minimize power usage.
	[self stopGettingLocation];
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopGettingLocationWhenMaximumWaitingTimeExpired) object:nil];
	
	//calls delegate to receive the new location
	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didReceivedNewLocation:)]) {
		[self.delegate didReceivedNewLocation:newLocation.coordinate];
	}
	

	
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
	
	NSString * ErrorMessage;
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopGettingLocationWhenMaximumWaitingTimeExpired) object:nil];
	[self stopGettingLocation];
	/**
	 This section will provide some usefull explanations to user in case of error.
	 **/
	switch ([error code]) {
		case kCLErrorLocationUnknown:
			ErrorMessage = NSLocalizedString(@"GPSErrorLocationUnknown", @"");
			break;
		case kCLErrorDenied:
			ErrorMessage = NSLocalizedString(@"GPSErrorDenied", @"");
			break;
		case kCLErrorHeadingFailure:
			ErrorMessage = NSLocalizedString(@"GPSErrorHeadingFailure", @"");
			break;

		default:
			ErrorMessage = NSLocalizedString(@"GPSErrorDefault", @"");
			break;
	}
	
	
	UIAlertView *errorAlert = [[UIAlertView alloc] 
                               initWithTitle:NSLocalizedString(@"GPSErrorTitle", @"")
                               message:ErrorMessage 
                               delegate:nil 
                               cancelButtonTitle:NSLocalizedString(@"OK", @"")
                               otherButtonTitles:nil
                               ];
	[errorAlert show];
	[errorAlert release];
	
	//calls delegate to receive the error
	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didReceiveAnErrorMessage:)]) {
		[self.delegate didReceiveAnErrorMessage:error];
	}
}



@end
