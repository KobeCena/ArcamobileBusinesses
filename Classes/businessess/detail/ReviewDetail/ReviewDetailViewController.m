//
//  ReviewDetailViewController.m
//  ArcaMobileBusinesses
//
//  Created by Ricardo Silva on 9/12/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import "ReviewDetailViewController.h"
#import "EdirectoryAppDelegate.h"

@implementation ReviewDetailViewController

@synthesize lblRate;
@synthesize gifLoading;
@synthesize reviewObject;
@synthesize reviwerImage;
@synthesize reviewerName;
@synthesize reviewDate;
@synthesize reviewRatingView;
@synthesize reviewText;
@synthesize reviewImage;
@synthesize cacheControl;
@synthesize lblListingTitle;
@synthesize lblUserReviews;
@synthesize imageDownloader;

- (void)dealloc {
    [reviewObject release];
    [reviwerImage release];
    [reviewerName release];
    [reviewDate release];
    [reviewRatingView release];
    [reviewText release];
    [reviewImage release];
    
    [cacheControl setDelegate:nil];
    [cacheControl release];
    
    [imageDownloader setDelegate:nil];
    [imageDownloader release];
    
    [lblListingTitle release];
    [lblUserReviews release];
    
    [gifLoading release];
    [lblRate release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
    // Do any additional setup after loading the view from its nib.
    [self setTitle: NSLocalizedString(@"ReviewDetails", @"")];
    
    //init the cacheController
    RpCacheController * tempCache = [[RpCacheController alloc] initWhithLastUpdateFromServer: [NSDate date] ];
    [self setCacheControl:tempCache];
    [tempCache release];
    //sets the delegate
    [self.cacheControl setDelegate: self];
    
    imageDownloader = [[RpAsyncImageDownloader alloc] init];
    [imageDownloader setDelegate:self];
    
    //creates a dateformatter using the pattern described into i18N files
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: NSLocalizedString(@"dateFormat", nil) ];
    
    [lblRate setText:NSLocalizedString(@"Rate", @"")];
    
    self.reviewRatingView.rating = [[self.reviewObject rating] floatValue];
    self.reviewerName.text = [self.reviewObject reviewer_name];
    self.reviewDate.text = [dateFormatter stringFromDate:[self.reviewObject added]];

    NSLog(@"Review ->>  %@",[self.reviewObject review] );
    
    self.reviewText.text = [self.reviewObject review];
    
    self.lblListingTitle.text = [NSString stringWithFormat:NSLocalizedString(@"BusinessTitleReview", @""), self.reviewObject.business_title];
    
    self.lblUserReviews.text = [NSString stringWithFormat: NSLocalizedString(([[self.reviewObject total_user_reviews] integerValue]>1?@"XReviewsPlural":@"XReviews"), @""), [[self.reviewObject total_user_reviews] integerValue]];
    
    [self.reviwerImage setImage: nil];
    if (self.reviewObject.facebook_image) {
        [imageDownloader setIndexForElement: 0];
        [imageDownloader startDownload:[NSURL URLWithString:self.reviewObject.facebook_image] withProgress:nil];
        [gifLoading setHidden: NO];
    }
    
    [self.reviewImage setImage: nil];
    if (self.reviewObject.galleryImage) {
        [self.cacheControl prepareCachedImage:[NSURL URLWithString:self.reviewObject.galleryImage] forThisIndex:1];
    }
    
    
	EdirectoryAppDelegate *appDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];        
    UIColor *themeColor = [appDelegate.themeSettings createColorForTheme:THEME_DEFAULTS];
    UIFont *themeFont = [appDelegate.themeSettings createFontForTheme:THEME_DEFAULTS withSize:16];
    
    [self.lblListingTitle setTextColor: themeColor];
    [self.lblListingTitle setFont: themeFont];
    
    [dateFormatter release];
    
}

- (void)viewDidAppear:(BOOL)animated {
}

- (void)viewDidUnload
{
    [self setLblRate:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)appImageDidLoad:(NSData *)imageData forIndex:(int)index {
    if(index == 0) {
        [self.reviwerImage setImage: [UIImage imageWithData:imageData]];
        [gifLoading setHidden:YES];
    } else if(index == 1) {
        [self.reviewImage setImage: [UIImage imageWithData:imageData]];
    }
}

- (void)appImageLoadFailed:(int)index {
    if(index == 0) {
        [self.reviwerImage setImage: [UIImage imageNamed:@"review_profile_no_image.png"]];
        [gifLoading setHidden:YES];
    }
}

@end
