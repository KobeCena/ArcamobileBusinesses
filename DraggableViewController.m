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
#import "BusinessDetailsViewController.h"
#import "DraggableViewController.h"
#import "EdirectoryAppDelegate.h"
#import "Deal.h"
#import "MapViewController.h"

@interface DraggableViewController()

    @property(nonatomic, assign) MapViewController *mapController;

@end

@implementation DraggableViewController
@synthesize image;
@synthesize mapController;

@synthesize draggView, detailButton, dragTitle, ratingView, latitude, longitude, listingBean, currentNavigationController, directionsButton;

- (void)dealloc {
	[detailButton                       release];
	[directionsButton                   release];
	[currentNavigationController        release];
	[draggView                          release];
	[ratingView                         release];
	[listingBean                        release];
	[dragTitle                              release];

    [directionsLabel release];
    [image release];
    [super dealloc];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [directionsLabel release];
    directionsLabel = nil;
    [self setImage:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidLoad
{
	setm = [[SettingsManager alloc] initWithNoWhait];
    
    [directionsLabel setText:NSLocalizedString(@"Directions", nil)];
}

-(void)setMapReference:(UIViewController*)mapReference{
    [self setMapController:(MapViewController*) mapReference];
}

-(IBAction)handleGetDirections:(id)sender{
	
    NSString* directionsUrl = @"http://maps.google.com/maps?daddr=%@&saddr=%f,%f";
    
    if ([[listingBean mapTunning] length] > 0 || isEmpty([listingBean address])) {
        NSString *destinationLL = @"";
        
        if ([[listingBean mapTunning] length] > 0) {
            destinationLL = [listingBean mapTunning];
        } else {
            destinationLL = [NSString stringWithFormat:@"%f,%f", [listingBean latitude], [listingBean longitude]];
        }
        
        directionsUrl = [NSString stringWithFormat: directionsUrl,destinationLL, latitude, longitude ];
    } else {
        
        //directionsUrl = [NSString stringWithFormat: directionsUrl,
        //                latitude, longitude, [listingBean address]];
        
        directionsUrl = [NSString stringWithFormat:directionsUrl, [listingBean address], latitude, longitude];
    }
    
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[directionsUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	
}


-(IBAction)handleGetDetail:(id)sender{
    
	[self.mapController showDetail:self.listingBean];
	
}

@end
