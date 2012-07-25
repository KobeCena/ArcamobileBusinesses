//
//  ReviewTextViewController.h
//  ArcaMobileProducts
//
//  Created by Ricardo Silva on 10/10/11.
//  Copyright (c) 2011 Arca Solutions Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RatingReviewViewController.h"

@interface ReviewTextViewController : UIViewController

@property (retain, nonatomic) IBOutlet UITextView *reviewText;
@property (nonatomic, assign) RatingReviewViewController * parentReviewViewController;

-(IBAction)handleDoneButtonPress:(id)sender;
@end
