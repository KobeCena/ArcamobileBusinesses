/*
 ######################################################################
 #                                                                    #
 # Copyright 2010 Arca Solutions, Inc. All Rights Reserved.           #
 #                                                                    #
 # This file may not be redistributed in whole or part.               #
 # eDirectory is licensed on a per-domain basis.                      #
 #                                                                    #
 # ---------------- eDirectory IS NOT FREE SOFTWARE ----------------- #
 #                                                                    #
 # http://www.edirectory.com | http://www.edirectory.com/license.html #
 ######################################################################
 
 ClassDescription: Transparent UIView used above mapView to intercept taps in empyt areas of the map to be able to hide our custom bubble.
 Author: Ricardo P. Silva
 Since: 07/22/2010
 */

#import <UIKit/UIKit.h>
#import "DraggableViewController.h"
#import "ListingAnnotationView.h"
#import "MapViewController.h"

@interface TouchableTransparentView : UIView {
	
	DraggableViewController *draggViewController;
	ListingAnnotationView *selectedCustomAnnotation;
    MapViewController * mapDelegate;
}

//NOTE: These objects doesn't need to be released since they are assigned by this class.
@property(nonatomic, assign) IBOutlet DraggableViewController *draggViewController;
@property(nonatomic, assign) ListingAnnotationView *selectedCustomAnnotation;
@property (nonatomic, assign) IBOutlet MapViewController * mapDelegate;

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;


@end
