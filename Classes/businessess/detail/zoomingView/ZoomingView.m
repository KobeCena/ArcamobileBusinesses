//
//  ZoomingView.m
//  TestTabBar
//
//  Created by Ricardo Silva on 9/13/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import "ZoomingView.h"

@implementation ZoomingView

@synthesize proxyView;


- (void)dealloc {
	[proxyView removeFromSuperview];
	[proxyView release];
	proxyView = nil;

    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (CGAffineTransform)orientationTransformFromSourceBounds:(CGRect)sourceBounds
{
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	if (orientation == UIDeviceOrientationFaceUp ||
		orientation == UIDeviceOrientationFaceDown)
	{
		orientation = [UIApplication sharedApplication].statusBarOrientation;
	}
	
	if (orientation == UIDeviceOrientationPortraitUpsideDown)
	{
		return CGAffineTransformMakeRotation(M_PI);
	}
	else if (orientation == UIDeviceOrientationLandscapeLeft)
	{
		CGRect windowBounds = self.window.bounds;
		CGAffineTransform result = CGAffineTransformMakeRotation(0.5 * M_PI);
		result = CGAffineTransformTranslate(result,
                                            0.5 * (windowBounds.size.height - sourceBounds.size.width),
                                            0.5 * (windowBounds.size.height - sourceBounds.size.width));
		return result;
	}
	else if (orientation == UIDeviceOrientationLandscapeRight)
	{
		CGRect windowBounds = self.window.bounds;
		CGAffineTransform result = CGAffineTransformMakeRotation(-0.5 * M_PI);
		result = CGAffineTransformTranslate(result,
                                            0.5 * (windowBounds.size.width - sourceBounds.size.height),
                                            0.5 * (windowBounds.size.width - sourceBounds.size.height));
		return result;
	}
    
	return CGAffineTransformIdentity;
}

- (CGRect)rotatedWindowBounds
{
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	if (orientation == UIDeviceOrientationFaceUp ||
		orientation == UIDeviceOrientationFaceDown)
	{
		orientation = [UIApplication sharedApplication].statusBarOrientation;
	}
	
	if (orientation == UIDeviceOrientationLandscapeLeft ||
		orientation == UIDeviceOrientationLandscapeRight)
	{
		CGRect windowBounds = self.window.bounds;
		return CGRectMake(0, 0, windowBounds.size.height, windowBounds.size.width);
	}
    
	return self.window.bounds;
}

- (void)deviceRotated:(NSNotification *)aNotification
{
	if (proxyView)
	{
		if (aNotification)
		{
			CGRect windowBounds = self.window.bounds;
			UIView *blankingView =
            [[[UIView alloc] initWithFrame:
              CGRectMake(-0.5 * (windowBounds.size.height - windowBounds.size.width),
                         0, windowBounds.size.height, windowBounds.size.height)] autorelease];
			blankingView.backgroundColor = [UIColor blackColor];
			[self.superview insertSubview:blankingView belowSubview:self];
			
			[UIView animateWithDuration:0.25 animations:^{
				self.bounds = [self rotatedWindowBounds];
				self.transform = [self orientationTransformFromSourceBounds:self.bounds];
			} completion:^(BOOL complete){
				[blankingView removeFromSuperview];
			}];
		}
		else
		{
            
            [UIView animateWithDuration:0.5 animations:^{
                self.bounds = [self rotatedWindowBounds];
                self.transform = [self orientationTransformFromSourceBounds:self.bounds];
			}];            
            
		}
	}
	else
	{
		self.transform = CGAffineTransformIdentity;
	}
}

- (void)toggleZoom:(BOOL)fullscreenDismissed
{
	if (proxyView)
	{
		CGRect frame =
        [proxyView.superview
         convertRect:self.frame
         fromView:self.window];
		self.frame = frame;
		
		CGRect proxyViewFrame = proxyView.frame;
        
		[proxyView.superview addSubview:self];
		[proxyView removeFromSuperview];
		[proxyView autorelease];
		proxyView = nil;
        
        
        float animationDuration=0;
        if (fullscreenDismissed) {
            animationDuration=0.5;
        }else{
            animationDuration=0.2;
        }
        
		[UIView
         animateWithDuration: animationDuration
         animations:^{
             self.frame = proxyViewFrame;
         } completion:^(BOOL complete){
             
         }];
		
		[[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:UIDeviceOrientationDidChangeNotification
         object:[UIDevice currentDevice]];
	}
	else
	{
		proxyView = [[UIView alloc] initWithFrame:self.frame];
		proxyView.hidden = YES;
		proxyView.autoresizingMask = self.autoresizingMask;
		[self.superview addSubview:proxyView];
		
		CGRect frame =
        [self.window
         convertRect:self.frame
         fromView:proxyView.superview];
		[self.window addSubview:self];
		self.frame = frame;
        
		[UIView
         animateWithDuration:0.25
         animations:^{
             self.frame = self.window.bounds;
         }];
		[[UIApplication sharedApplication]
         setStatusBarHidden:YES
         withAnimation:UIStatusBarAnimationFade];
        
		[[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(deviceRotated:)
         name:UIDeviceOrientationDidChangeNotification
         object:[UIDevice currentDevice]];
        
	}

	[self deviceRotated:nil];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"ENTERSFULLSCREEN" object:self];
    
    
}


- (void)dismissFullscreenView
{
	if (proxyView)
	{
		[self toggleZoom:YES];

	}
}

@end
