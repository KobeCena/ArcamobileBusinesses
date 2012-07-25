//
//  ReviewTextViewController.m
//  ArcaMobileProducts
//
//  Created by Ricardo Silva on 10/10/11.
//  Copyright (c) 2011 Arca Solutions Inc. All rights reserved.
//

#import "ReviewTextViewController.h"

@implementation ReviewTextViewController

@synthesize reviewText;
@synthesize parentReviewViewController;

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

-(IBAction)handleDoneButtonPress:(id)sender{

    if (! [self.reviewText.text isEqualToString:@""]) {
        self.parentReviewViewController.reviewTextView.text = self.reviewText.text;
    }
    


    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    reviewText.layer.cornerRadius = 3.25f;
    
    if ([self.parentReviewViewController.reviewTextView.text isEqualToString:NSLocalizedString(@"reviewtextInitialMessage", nil)]) {
        reviewText.text = @"";
    }else{
        reviewText.text = self.parentReviewViewController.reviewTextView.text;    
    }
    
    // Do any additional setup after loading the view from its nib.
    [self.reviewText becomeFirstResponder];
    
}


- (void)viewDidUnload
{
    [self setReviewText:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [reviewText release];
    [super dealloc];
}
@end
