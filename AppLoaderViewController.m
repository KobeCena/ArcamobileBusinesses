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
#import "AppLoaderViewController.h"
#import "Utility.h"
#import "EdirectoryAppDelegate.h"

@implementation AppLoaderViewController
@synthesize loadingTextImageView;

@synthesize imageView, activityIndicatorView, cancelButton;

- (void)dealloc {
	[activityIndicatorView release];
	[imageView release];
    [copyrightLabel release];
    [cancelButton release];
    [loadingTextImageView release];
    [super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.loadingTextImageView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"s01_01.png"],
                                                                         [UIImage imageNamed:@"s02_02.png"],
                                                                         [UIImage imageNamed:@"s03_03.png"],
                                                                         [UIImage imageNamed:@"s04_04.png"],
                                                                         [UIImage imageNamed:@"s05_05.png"],
                                                                         [UIImage imageNamed:@"s06_06.png"],
                                                                         [UIImage imageNamed:@"s07_07.png"],
                                                                         [UIImage imageNamed:@"s08_08.png"],
                                                                         [UIImage imageNamed:@"s09_09.png"],
                                                                         [UIImage imageNamed:@"s10_10.png"],
                                                                         [UIImage imageNamed:@"s11_11.png"],
                                                                         [UIImage imageNamed:@"s12_12.png"],
                                                                         [UIImage imageNamed:@"s13_13.png"],
                                                                         [UIImage imageNamed:@"s14_14.png"],
                                                                         [UIImage imageNamed:@"s15_15.png"],
                                                                         [UIImage imageNamed:@"s16_16.png"],
                                                                         [UIImage imageNamed:@"s17_17.png"],
                                                                         [UIImage imageNamed:@"s18_18.png"],                                                 
                                                                         [UIImage imageNamed:@"s19_19.png"], nil];    
    // all frames will execute in 1.75 seconds
    self.loadingTextImageView.animationDuration = 1.75;
    // repeat the annimation forever
    self.loadingTextImageView.animationRepeatCount = 0;
    // start animating
    [self.loadingTextImageView startAnimating];
    
    [copyrightLabel setText:NSLocalizedString(@"Copyright", @"")];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [copyrightLabel release];
    copyrightLabel = nil;
    [self setLoadingTextImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(IBAction)handleCancelButton:(id)sender{
    //post a notification
    [[NSNotificationCenter defaultCenter] postNotificationName:DEALS_CANCELED object:self];
    
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self.navigationController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

@end
