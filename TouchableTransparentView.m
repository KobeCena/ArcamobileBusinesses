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

#import "TouchableTransparentView.h"
#import "MapViewController.h"

@implementation TouchableTransparentView

@synthesize draggViewController, selectedCustomAnnotation, mapDelegate;



- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [super dealloc];
}

-(void) hidesInfoBubbleAndReturnStateForPin{
    
    
    if (self.draggViewController.view) {
        //animates the infoBubble disappearing
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:nil context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.4];
        self.draggViewController.view.alpha = 0.0f;	
        [UIView commitAnimations];
    }
    
	//self.draggViewController.view.hidden = YES;
	
	//Turns all states back for previous pin
	
	[[[self mapDelegate] previousPinSelected] setHighlighted:NO];
	[[[self mapDelegate] previousPinSelected] setSelected:NO];
    
     
    
	UIImage *customImage = [UIImage imageNamed:@"pinmark_unselected.png"];
	[[[self mapDelegate] previousPinSelected] setImage:customImage];

    

    
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {

	//catches the UIView that received the event
    UIView *touchedView = [super hitTest:point withEvent:event];

	
	if ( [touchedView isKindOfClass:[ListingAnnotationView class]]) {
		self.selectedCustomAnnotation = (ListingAnnotationView *)touchedView;
        
	} 
	
	
	NSString *touchedType = [[touchedView class] description];
	
	if ([touchedType isEqualToString:@"MKAnnotationContainerView"] || [touchedType isEqualToString:@"MKScrollView"]) {
		//hides the info bubble and de-selects the pin
        if (![[self mapDelegate] disableHideWhenMapTouched]) {
            [self hidesInfoBubbleAndReturnStateForPin];
        }
	}
	
    
	return touchedView;
}





@end
