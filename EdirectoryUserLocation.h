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
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@protocol EdirectoryUserLocationDelegate <NSObject>

//This is called by the eDirectoryUserLocation when a new GPS location was successfully received
-(void) didReceivedNewLocation:(CLLocationCoordinate2D)newUserLocation;
//This is called by the eDirectoryUserLocation when an Error message was received
-(void) didReceiveAnErrorMessage:(NSError *)error;
//This is called by the eDirectoryUserLocation to inform a delegate that the Locations service for iPhone is disabled
-(void) locationsServiceIsNotEnable;
//This is called by the eDirectoryUserLocation when LocationManager is still waiting to Location results after 30 secs.
-(void) didHitTheMaximumTimeIntervalWithNoResults;

@end



@interface EdirectoryUserLocation : NSObject <CLLocationManagerDelegate> {
	
	CLLocationManager *locationManager;
	id <EdirectoryUserLocationDelegate> delegate;	

}

@property (nonatomic, retain) 	CLLocationManager *locationManager;
@property (nonatomic, assign) 	id <EdirectoryUserLocationDelegate> delegate;

-(void)setupEdirectoryUserLocation;

@end
