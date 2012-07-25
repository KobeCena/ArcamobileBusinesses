//
//  ForgotPasswordViewController.m
//  ArcamobileBusinessFinder
//
//  Created by Ricardo Silva on 4/9/12.
//  Copyright (c) 2012 Arca Solutions Inc. All rights reserved.
//

#import "ForgotPasswordViewController.h"

#import "ARCAserver_businesses.h"
#import "EdirectoryParserToWSSoapAdapter.h"

@interface ForgotPasswordViewController ()

- (BOOL)fieldsValidated:(NSString **)message;
- (void)handleError:(NSString *)message;

@end

@implementation ForgotPasswordViewController

@synthesize emailField;
@synthesize retrieveButton;
@synthesize retrieveLabel;


@synthesize alertView, alertLabel;


#pragma mark - Blocks the screen
-(void)addWaitingAlertOverCurrentView{
    //ALERT MESSAGE
    [self.view setUserInteractionEnabled:NO];
    [self.view addSubview:alertView];
    alertView.backgroundColor = [UIColor clearColor];
    alertView.center = self.view.superview.center;
    CALayer *viewLayer = self.alertView.layer;
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.duration = 0.35555555;
    animation.values = [NSArray arrayWithObjects:
                        [NSNumber numberWithFloat:0.6],
                        [NSNumber numberWithFloat:1.1],
                        [NSNumber numberWithFloat:.9],
                        [NSNumber numberWithFloat:1],
                        nil];
    animation.keyTimes = [NSArray arrayWithObjects:
                          [NSNumber numberWithFloat:0.0],
                          [NSNumber numberWithFloat:0.6],
                          [NSNumber numberWithFloat:0.8],
                          [NSNumber numberWithFloat:1.0], 
                          nil];    
    [viewLayer addAnimation:animation forKey:@"transform.scale"];
    [self performSelector:@selector(updateText:) withObject:NSLocalizedString(@"Wait", @"") afterDelay:0.0];
}

- (void)updateText:(NSString *)newText
{
    self.alertLabel.text = newText;
}
- (void)finalUpdate
{
    [UIView beginAnimations:@"" context:nil];
    self.alertView.alpha = 0.0;
    [UIView commitAnimations];
    [UIView setAnimationDuration:0.35];
    [self performSelector:@selector(removeAlert) withObject:nil afterDelay:0.5];
}
- (void)removeAlert
{
    [self.alertView removeFromSuperview];
    self.alertView.alpha = 1.0;
    [self.view setUserInteractionEnabled:YES];    
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.retrieveButton setTitle: NSLocalizedString(@"RetrieveButtonTitle", nil)  forState:UIControlStateNormal];
    [self.retrieveLabel setText: NSLocalizedString(@"RetrieveMessage", nil) ];
    
}

- (void)viewDidUnload
{
    [self setEmailField:nil];
    [self setRetrieveButton:nil];
    [self setRetrieveLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)proceedButtonPressed:(id)sender {
    
	NSString *messageValidate;
	if (![self fieldsValidated:&messageValidate]) {
		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle:NSLocalizedString(@"RetrieveTitle", @"")
							  message:messageValidate
							  delegate:nil 
							  cancelButtonTitle:NSLocalizedString(@"OK", @"")
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}    
    
    [self addWaitingAlertOverCurrentView];
    
    
    ARCAserver_businesses* service = [ARCAserver_businesses service];
    EdirectoryParserToWSSoapAdapter *adapter = [EdirectoryParserToWSSoapAdapter sharedInstance];
    [service setHeaders:[adapter getDomainToken]];
    service.logging = YES;
    
    [service forgotPassword:self action:@selector(forgotPasswordHandler:) email:self.emailField.text];
    
}

// Handle the response from forgotPassword.
- (void) forgotPasswordHandler: (id) value {
    
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
        
        NSError *error = (NSError *)value;
        [self handleError: [error localizedDescription] ];
		return;
	}
    
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {

        SoapFault * fault = (SoapFault *)value;
        [self handleError: [fault faultString] ];        
		return;
	}				
    
	// Do something with the ARCAStandardReturn* result
    ARCAStandardReturn* result = (ARCAStandardReturn*)value;
	
    [self handleError: [result Message] ];
    
    [self finalUpdate];
    [self.navigationController popViewControllerAnimated:YES];
    
}


-(BOOL)fieldsValidated:(NSString **)message
{
    
	if ([emailField.text length] == 0)
	{
		*message = NSLocalizedString(@"EmailRequired", @"");
		return NO;
	}
    
	return YES;
}

- (void)handleError:(NSString *)message{
	
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle:nil
                          message: message
                          delegate:nil 
                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}


- (void)dealloc {
    [emailField release];
    [retrieveButton release];
    [retrieveLabel release];
    [alertView release];
    [alertLabel release];
    
    [super dealloc];
}
@end
