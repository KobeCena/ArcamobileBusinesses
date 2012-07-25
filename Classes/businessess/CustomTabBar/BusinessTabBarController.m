//
//  BusinessTabBarController.m
//  ArcaMobileBusinesses
//
//  Created by Ricardo Silva on 9/12/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import "BusinessTabBarController.h"
#import "BusinessDetailsViewController.h"

#import "BusinessNearbyViewController.h"
#import "BusinessDashBoardViewController.h"
#import "MyBusinessViewController.h"
#import "SettingsViewController.h"

@implementation BusinessTabBarController

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    
    BOOL result = NO;
    
    UIViewController * topViewController = [(UINavigationController *)[self selectedViewController] topViewController];
    if ([topViewController isKindOfClass:[BusinessDetailsViewController class] ]) {
        //only rotates to rightLandscape and portrait
        result = (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight); 
    }
    
    return result;

}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    UIViewController * topViewController = [(UINavigationController *)[self selectedViewController] topViewController];
    if ([topViewController isKindOfClass:[BusinessDetailsViewController class] ]) {
        [topViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
    
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    UIViewController * topViewController = [(UINavigationController *)[self selectedViewController] topViewController];
    if ([topViewController isKindOfClass:[BusinessDetailsViewController class] ]) {
        [topViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    }
    
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    /*
	for(UIView *view in tabBarController.tabBar.subviews) {  
		if([view isKindOfClass:[UIImageView class]]) {  
			[view removeFromSuperview];  
		}  
	}  
	
    if ([viewController isKindOfClass: [UINavigationController class] ]) {
        UINavigationController *navTemp = (UINavigationController *)viewController;
        
        id selectedController = [[navTemp viewControllers] objectAtIndex:0];

        
        if ([selectedController isKindOfClass: [BusinessNearbyViewController class] ]){
            
            [tabBarController.tabBar insertSubview:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tabBar01.png"]] autorelease] atIndex:0];  
        }
        if ([selectedController isKindOfClass: [BusinessDashBoardViewController class]]){
            [tabBarController.tabBar insertSubview:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tabBar02.png"]] autorelease] atIndex:0];  
            
        }
        if ([selectedController isKindOfClass: [MyBusinessViewController class]]){
            [tabBarController.tabBar insertSubview:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tabBar03.png"]] autorelease] atIndex:0];  
            
        }
        if ([selectedController isKindOfClass: [SettingsViewController class]]){
            [tabBarController.tabBar insertSubview:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tabBar04.png"]] autorelease] atIndex:0];  
            
        }
        
        
    }*/
    
    return YES;
}


@end
