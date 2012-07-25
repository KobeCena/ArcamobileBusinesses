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

#import "ListingAnnotationView.h"
#import "Listing.h"
#import "EdirectoryAppDelegate.h"
#import "MapViewController.h"
#import "Utility.h"


@implementation ListingAnnotationView


@synthesize touchedPoint;
@synthesize isZipPosition;

- (void)dealloc {
    [super dealloc];
}


/******/
#pragma mark -
#pragma mark Handling events

// Reference: iPhone Application Programming Guide > Device Support > Displaying Maps and Annotations > Displaying Annotations > Handling Events in an Annotation View
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
    [super touchesBegan:touches withEvent:event];

	if ([self isZipPosition]) {
		return;
	}

    //retain the touchedPoint
	touchedPoint = [[touches anyObject] locationInView:self];
        
    //Post a notification about pinselected
	[[NSNotificationCenter defaultCenter] postNotificationName:PIN_SELECTED object:self];   
    
   
    
	[self setHighlighted:YES];
	[self setSelected: YES];
	//[self setPinColor:MKPinAnnotationColorRed];
	UIImage *customImage = [UIImage imageNamed:@"pinmark_selected.png"];
	[self setImage:customImage];


	
}

/*
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
}

 Only implement these methods if you are planning do drag'n drop with a pin.
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
}



- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
}
*/



/******/

/*
-(id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
	self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
	
	if (self != nil){
		CGRect frame = self.frame;
		frame.size = CGSizeMake(60.0, 85.0);
		self.frame = frame;
		self.backgroundColor = [UIColor clearColor];
		self.centerOffset = CGPointMake(30.0, 42.0);
	}
	 
	return self;
}
*/

-(void) setAnnotation:(id <MKAnnotation>)annotation{
	[super setAnnotation:annotation];
}
/*	
-(void) drawRect:(CGRect)rect{

	Listing *listingItem = (Listing *)self.annotation;
	
	if (listingItem != nil){
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextSetLineWidth(context, 1);
		
		//draw the rounded box
		CGMutablePathRef path = CGPathCreateMutable();
		CGPathMoveToPoint(path, NULL, 15.0, 0.5);
		CGPathAddArcToPoint(path, NULL, 59.5, 00.5, 59.5, 5.0, 5.0);
		CGPathAddArcToPoint(path, NULL, 59.5, 69.5, 55.0, 69.5, 5.0);
		CGPathAddArcToPoint(path, NULL, 10.5, 69.5, 10.5, 64.0, 5.0);
		CGPathAddArcToPoint(path, NULL, 10.5, 00.5, 15.0, 0.5, 5.0);
		CGContextAddPath(context, path);
		CGContextSetFillColorWithColor(context, [UIColor cyanColor].CGColor);
		CGContextDrawPath(context, kCGPathFillStroke);
		CGPathRelease(path);
		
		NSString *title = [listingItem title];
		
		[[UIColor blackColor] set];
		[title drawInRect:CGRectMake(15.0, 5.0, 50.0, 40.0) withFont:[UIFont systemFontOfSize:11.0]];
	}
		
}
 */


@end
