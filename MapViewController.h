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
#import <MapKit/MapKit.h>
#import "Setting.h"
#import "EdirectoryXMLParser.h"
#import "DraggableViewController.h"

@class Listing;

@interface MapViewController : UIViewController <MKMapViewDelegate, EdirectoryXMLParserDelegate>{
	MKMapView *mapView;
	NSMutableArray *mapAnnotations;
	DraggableViewController *draggViewController;
	UIBarButtonItem *buttonList;
	
	//This is the view that "locks" the mapView until the results aren't fully parsed.
	UIView *searching;
	
	//This is a tweak to change the color of selected pin
	MKAnnotationView * previousPinSelected;
	
	NSArray *listings;
	
	Setting *setting;
	
	double zipcodeLatitude, zipcodeLongitude;
    
    
    IBOutlet UILabel *searchingLabel;
    
    EdirectoryXMLParser * parser; 
    
    MKCoordinateRegion originalLocation;
    
    //to determining when maps needs to refresh aftaer a region change operation
    BOOL refreshWhenRegionChanges;
    
    //to show or ot the rightButton in the navigation bar
    BOOL showRighNavigationButton;
    
    BOOL disableHideWhenMapTouched;
	
}

@property (nonatomic, retain) NSMutableArray *mapAnnotations;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet DraggableViewController *draggViewController;
@property (nonatomic, retain) UIBarButtonItem *buttonList;
@property (nonatomic, retain) IBOutlet UIView *searching;
@property (nonatomic, retain) NSArray *listings;
@property (nonatomic, retain) Setting *setting;
@property (nonatomic, assign) double zipcodeLatitude;
@property (nonatomic, assign) double zipcodeLongitude;
@property (nonatomic, retain) MKAnnotationView * previousPinSelected;
@property (nonatomic, retain) EdirectoryXMLParser * parser;
@property (nonatomic, assign) BOOL refreshWhenRegionChanges;
@property (nonatomic, assign) BOOL showRighNavigationButton;
@property (nonatomic) BOOL disableHideWhenMapTouched;


- (void)gotoLocation:(double)newLatitude newLongitude:(double)newLongitude;
- (void) showInfoBubble:(CGPoint)point fromView:(UIView *) aView withData:(Listing *)data;
- (void) hideInfoBubble;
- (Setting *)  getSetting;
- (void)zoomToFitMapAnnotations;
-(void)blockMapView;
-(void)unBlockMapView;
-(void)draggViewSetup:(Listing *)data;
- (void)listenPinViewNotifications:(NSNotification *) notification;
-(void)showDetail:(Listing *) listingObj;
@end
