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

#import "DraggableView.h"


@implementation DraggableView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	CGPoint myPoint = [[touches anyObject] locationInView:self];
	startlocation = myPoint;
	//[[self superView] bringSubviewToFront:self];
	
}


-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	CGPoint mypoint = [[touches anyObject] locationInView:self];
	CGRect frame = [self frame];
	
	frame.origin.x += mypoint.x - startlocation.x;
	frame.origin.y += mypoint.y - startlocation.y;
	[self setFrame:frame];
	
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


@end
