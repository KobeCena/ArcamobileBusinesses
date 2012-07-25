//
//  ZoomingView.h
//  TestTabBar
//
//  Created by Ricardo Silva on 9/13/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZoomingView : UIView{
    UIView *proxyView;
}


@property (nonatomic, retain, readonly) UIView *proxyView;
- (void)dismissFullscreenView;
- (void)toggleZoom:(BOOL)fullscreenDismissed;
@end
