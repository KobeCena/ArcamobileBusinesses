//
//  ForgotPasswordViewController.h
//  ArcamobileBusinessFinder
//
//  Created by Ricardo Silva on 4/9/12.
//  Copyright (c) 2012 Arca Solutions Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgotPasswordViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIView *alertView;
@property (nonatomic, retain) IBOutlet UILabel *alertLabel;
@property (retain, nonatomic) IBOutlet UITextField *emailField;
@property (retain, nonatomic) IBOutlet UIButton *retrieveButton;
@property (retain, nonatomic) IBOutlet UILabel *retrieveLabel;


- (IBAction)proceedButtonPressed:(id)sender;

@end
