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

#import "RatingView.h"

#define HORIZONTAL_STAR_SPACE 17.0
#define HORIZONTAL_PADDING_ADJUST 3.0
#define MAX_RATING 5

@implementation RatingView

@synthesize bgImgView;
@synthesize fgImgView;
@synthesize rating;

- (void)_commonInit {
    [self setClipsToBounds:YES];
    [self setContentMode:UIViewContentModeScaleToFill];
    [self setContentStretch:self.frame];
    
    bgImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rateBarBackgroundH.png"]];
    bgImgView.contentMode = UIViewContentModeTopLeft;
    [self addSubview:bgImgView];
    
    fgImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rateBarForegroundH.png"]];
    fgImgView.contentMode = UIViewContentModeTopLeft;
    fgImgView.clipsToBounds = YES;
    
    CGRect tam = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height + 10);
    tam.origin.y = tam.size.height + 10;  
    fgImgView.frame = tam;
    
    [self addSubview:fgImgView];	
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self _commonInit];
    }
    
    return self;
}

- (void)setRating:(float)newRating {
    
    [self _commonInit];
    
    rating = newRating;
    float newWidth = bgImgView.frame.size.width * (rating / MAX_RATING);
    
    CGRect bgRect = bgImgView.frame;
    bgRect.size.width = newWidth;
    fgImgView.frame = bgRect;
    
    if (fgImgView.superview != nil) {
        [fgImgView removeFromSuperview];
    }
    
    [self addSubview:fgImgView];
    
}

- (float)rating {
    return rating;
}

- (void)dealloc {
    [bgImgView release];
    [fgImgView release];
	
    [super dealloc];
}



@end
