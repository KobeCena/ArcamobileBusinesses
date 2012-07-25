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

#import <MapKit/MapKit.h>
#import "MapViewController.h"

//@interface ListingAnnotationView : MKPinAnnotationView {
@interface ListingAnnotationView : MKAnnotationView {
	

	BOOL isZipPosition;
    CGPoint touchedPoint;    
	
}

@property (nonatomic, assign) BOOL isZipPosition;
@property (nonatomic, assign) CGPoint touchedPoint;



@end
