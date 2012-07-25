//
//  ImagePageViewController.m
//  iTravleNZ
//
//  Created by Rafael Gustavo Gali on 22/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImagePageViewController.h"


@implementation ImagePageViewController


@synthesize pageImage;
@synthesize dataSource;
@synthesize asynchImage;
@synthesize loading;

@synthesize imageCaption;
@synthesize thumbCaption;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    NSLog(@"initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil");
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

// Load the view nib and initialize the pageNumber ivar.
- (id)initWithPageNumber:(int)page {
    
    NSLog(@"initWithPageNumber:(int)page");
    
    if (self == [super initWithNibName:@"ImagePageViewController" bundle:nil]) {
        pageNumber = page;
    }
    return self;
}

// Load the view nib and initialize the pageNumber ivar.
- (id)initWithPageNumber:(int)page withSource:(NSMutableArray *)source {
    
    
    NSLog(@"initWithPageNumber:(int)page withSource:(NSMutableArray *)source");
    
    if (self == [super initWithNibName:@"ImagePageViewController" bundle:nil]) {
        pageNumber = page;
        dataSource = source;
    }
    return self;
}


- (void)dealloc
{
    
    [dataSource release];
    [loading release];
    // Abort the download. Doesn't do anything if the image has been downloaded already.
	[asynchImage abortDownload];
	// Then release.
	[asynchImage release];
    
    [pageImage release];
    
    [imageCaption release];
    [thumbCaption release];
    
//    [dataSource release];

    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    if ([dataSource count] > 0) {
        NSString *url = [dataSource objectAtIndex:pageNumber];
        
        [self downloadImageFromInternet:url];
        [loading startAnimating];
        
    }
    
    
}

- (void) downloadImageFromInternet:(NSString*) urlToImage
{
	// Create a instance of InternetImage
	asynchImage = [[InternetImage alloc] initWithUrl:urlToImage];
	
	// Start downloading the image with self as delegate receiver
	[asynchImage downloadImage:self];
}


-(void) internetImageReady:(InternetImage*)downloadedImage
{	
	// The image has been downloaded. Put the image into the UIImageView
	[pageImage setImage:downloadedImage.Image];
    [loading stopAnimating];

}




- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
