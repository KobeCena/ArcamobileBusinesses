//
//  RatingReviewViewController.m
//  ArcaMobileBusinesses
//
//  Created by Ricardo Silva on 8/31/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import "RatingReviewViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ARCAserver_businesses.h"
#import "LoginData.h"
#import "CoreUtility.h"
#import "ReviewTextViewController.h"
#import "EdirectoryAppDelegate.h"


@interface RatingReviewViewController() 

- (void) submitReview;
- (void) updateText:(NSString *)newText;

@end


@implementation RatingReviewViewController

@synthesize parentDetailViewController;
@synthesize btnShareEmail;
@synthesize moduleName = _moduleName;
@synthesize cameraButton;
@synthesize reviewTextView;
@synthesize imagetakenBadge;
@synthesize facebookSwitch;
@synthesize twitterSwitch;
@synthesize businessTitleLabel;
@synthesize alertLabel;
@synthesize alertView;
@synthesize imageTestView;
@synthesize reviewStarsView;
@synthesize cameraMediaView;

@synthesize businessID, reviewNote;
@synthesize overlayViewController, capturedImage;
@synthesize businessTittle;

@synthesize emailPromptText;
@synthesize promptView;
@synthesize lblRateIt;
@synthesize lblShareFacebook;
@synthesize lblShareTwitter;
@synthesize btnFromLibrary;
@synthesize btnCameraCancel;


@synthesize setm;
@synthesize foursquare_id;
@synthesize delegate;

@synthesize adapter = _adapter;

#pragma mark - Blocks the screen
-(void)addWaitingAlertOverCurrentView{
    //ALERT MESSAGE
    
    //blocks this view
    [self.view setUserInteractionEnabled:NO];
    
    [self.view addSubview:alertView];
    alertView.backgroundColor = [UIColor clearColor];
    alertView.center = self.view.center;
    self.alertView.alpha = 1.0;
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
    
    [self updateText:NSLocalizedString(@"businessGeneralWaitMessage", @"")];
    
}

- (void)updateText:(NSString *)newText
{
    self.alertLabel.text = newText;
}
- (void)finalUpdate
{
    //Unblocks this view
    [self.view setUserInteractionEnabled:YES];
    
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

-(void)applyTheme {
    
    //gets a reference to application delegate
	EdirectoryAppDelegate *appDelegate = (EdirectoryAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIColor * themeColor = [appDelegate.themeSettings createColorForTheme:THEME_DEFAULTS];    
    
    [self.businessTitleLabel setTextColor:themeColor];
    
}

#pragma mark SA_OAuthTwitterEngineDelegate
- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username {
	NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setObject: data forKey: @"authData"];
    
    
    
	[defaults synchronize];
}
- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username {
	return [[NSUserDefaults standardUserDefaults] objectForKey: @"authData"];
}

- (IBAction)handleTwitterSwitch:(id)sender {
    
    if (twitterSwitch.on) {
        
        SA_OAuthTwitterEngine * _engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
        _engine.consumerKey    = [setm twitterApiKey];
        _engine.consumerSecret = [setm twitterApiSecret];
        if(![_engine isAuthorized]) {
            UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:_engine delegate:self];
            
            [self presentModalViewController: controller animated: YES];
        }
        [_engine release];
        
    } else {}
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [lblRateIt setText:NSLocalizedString(@"Rate", @"")];
    [lblShareFacebook setText:NSLocalizedString(@"ShareWithFacebook", @"")];
    [lblShareTwitter setText:NSLocalizedString(@"ShareWithTwitter", @"")];
    //[lblShareEmail setText:NSLocalizedString(@"ShareWithEmail", @"")];
    [btnShareEmail setTitle:NSLocalizedString(@"ShareWithEmail", @"") forState:UIControlStateNormal];
    [btnCameraCancel setTitle:NSLocalizedString(@"Cancel", @"") forState:UIControlStateNormal];
    [btnFromLibrary setTitle:NSLocalizedString(@"ChooseFromLibrary", @"") forState:UIControlStateNormal];
    [cameraButton setTitle:NSLocalizedString(@"TakeWithCamera", @"") forState:UIControlStateNormal];
    
    
    //Configure a Done button in the NavigationBar
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(submitReview)];
    [self.navigationItem setRightBarButtonItem:doneButton ];
    [doneButton release];
    
    
    emailPromptText = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 50.0, 260.0, 25.0)];
    [emailPromptText setBackgroundColor:[UIColor whiteColor]];
    [emailPromptText setBorderStyle:UITextBorderStyleRoundedRect];
    [emailPromptText setClearButtonMode:UITextFieldViewModeAlways];
    [emailPromptText setKeyboardType:UIKeyboardTypeEmailAddress];
    [emailPromptText setReturnKeyType:UIReturnKeyDefault];
    [emailPromptText setAlpha: 0.9f];
    [emailPromptText setPlaceholder:@"E-mail"];
    [emailPromptText setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    
    [self.businessTitleLabel setText: self.businessTittle ];
    
    self.overlayViewController =
    [[[OverlayViewController alloc] initWithNibName:@"OverlayViewController" bundle:nil] autorelease];
    [self.overlayViewController setDelegate:self];
    
    [self.reviewTextView.layer setCornerRadius:5.0f];
    self.reviewTextView.text = NSLocalizedString(@"reviewtextInitialMessage", nil);
    
    
    //verifies the camera availability 
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        // camera is not on this device, don't show the camera button
        [self.cameraButton setHidden:TRUE];
    }
    
    //applys the theme
    [self applyTheme];
    
    //adds a gesture to the uiImageView
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCameraButtonPress:)];
    
    [self.imagetakenBadge addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    self.imagetakenBadge.layer.cornerRadius = 5.0f;
    
    
    SA_OAuthTwitterEngine * _engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
    _engine.consumerKey    = [setm twitterApiKey];
    _engine.consumerSecret = [setm twitterApiSecret];
    if([_engine isAuthorized]) {
        [self.twitterSwitch setOn:YES];
    } else {
        [self.twitterSwitch setOn:NO];
    }
    [_engine release];
    
}

- (void)viewDidUnload
{
    [self setReviewStarsView:nil];
    [self setCameraMediaView:nil];
    [self setCameraButton:nil];
    
    self.overlayViewController = nil;
    self.capturedImage = nil;
    
    [self setReviewTextView:nil];
    [self setImagetakenBadge:nil];
    [self setFacebookSwitch:nil];
    [self setTwitterSwitch:nil];
    [self setBusinessTittle:nil];
    [self setBusinessTitleLabel:nil];
    [self setAlertView:nil];
    [self setAlertLabel:nil];
    [self setImageTestView:nil];
    [btnEmailInsert release];
    btnEmailInsert = nil;
    [self setLblRateIt:nil];
    [self setLblShareFacebook:nil];
    [self setLblShareTwitter:nil];
    [self setBtnFromLibrary:nil];
    [self setBtnCameraCancel:nil];
    [self setBtnShareEmail:nil];
    [self setChoseProfileViewController:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)handleReviewStarPress:(id)sender{
    UIButton * starButton = (UIButton *)sender;
    
    //records the review Note
    [self setReviewNote:starButton.tag];
    
    for (UIButton *btn in self.reviewStarsView.subviews) {        
        if (btn.tag <= starButton.tag) {
            [btn setSelected:TRUE];
        }else{
            [btn setSelected:FALSE];
        }
    }
    
    
}


- (void)dealloc {
    [reviewStarsView        release];
    [cameraMediaView        release];
    [overlayViewController  release];
    [capturedImage          release];
    [cameraButton           release];
    [reviewTextView         release];
    [imagetakenBadge        release];
    [facebookSwitch         release];
    [twitterSwitch          release];
    [businessTittle         release];
    [businessTitleLabel     release];
    [alertView              release];
    [alertLabel             release];
    [imageTestView          release];
    [btnEmailInsert         release];
    [emailPromptText        release];
    [lblRateIt              release];
    [lblShareFacebook       release];
    [lblShareTwitter        release];
    [btnFromLibrary         release];
    [btnCameraCancel        release];
    [self.adapter           release];
    [self.moduleName        release];
    [self.foursquare_id release];
    [setm                       release];
    [btnShareEmail release];
    [super dealloc];
}

#pragma mark - Show and hide social media view
-(void)showCameraMediaView{
    
    self.cameraMediaView.frame = CGRectMake(0,
                                            self.tabBarController.view.frame.size.height,
                                            self.cameraMediaView.frame.size.width,
                                            self.cameraMediaView.frame.size.height);
    
    [self.tabBarController.view addSubview:self.cameraMediaView];
    [self.tabBarController.view sendSubviewToBack:self.cameraMediaView];
    
    CGRect tam = self.cameraMediaView.frame;
    
    tam.origin.y = self.tabBarController.view.frame.size.height-tam.size.height;
    
    //blocks the viewController's view to receive actions
    UIView * blockView = [[UIView alloc] initWithFrame:self.view.frame];
    [blockView setBackgroundColor:[UIColor blackColor]];
    [blockView setAlpha:0.6];
    [blockView setTag:123456];
    
    [self.view addSubview:blockView];
    
    [blockView release];
    
	//show the social media view
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelegate:self];
	//[UIView setAnimationDidStopSelector:@selector(hidingLoaderFinished)];
	[UIView setAnimationDuration:0.3];
    
    
    self.cameraMediaView.frame = tam;
    //[self.view bringSubviewToFront:self.cameraMediaView];
    [self.tabBarController.view bringSubviewToFront:self.cameraMediaView];
    
	[UIView commitAnimations];
	
    
    
}
-(void)removeCameraMediaViewAfterHide{
    [self.cameraMediaView removeFromSuperview];
}

-(void)hideCameraMediaView{
    
    CGRect tam = self.cameraMediaView.frame;
    tam.origin.y = self.tabBarController.view.frame.size.height;
    
    
	//show the social media view
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(removeCameraMediaViewAfterHide)];
	[UIView setAnimationDuration:0.3];
    
    self.cameraMediaView.frame = tam;
    
	[UIView commitAnimations];
    
    //Unblocks the viewController's view to receive actions
    for (UIView* subView in self.view.subviews) {
        if (subView.tag == 123456) {
            [subView removeFromSuperview];
        }
    }
    
}

#pragma mark - Handle media buttons press
-(IBAction)handleCancelButtonPressed:(id) sender{
    [self hideCameraMediaView];
}


#pragma mark - handle camera button press
-(IBAction)handleCameraButtonPress:(id)sender{ 
    
    if (!self.imagetakenBadge.hidden) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DeteleActualPhoto", @"") message:NSLocalizedString(@"TakeAnotherPicture", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") otherButtonTitles:NSLocalizedString(@"JustDelete", @""), NSLocalizedString(@"TakeAnother", @""), nil];
        
        [alert show];
        [alert release];
    }else{
        [self showCameraMediaView];
    }
}

- (void)showImagePicker:(UIImagePickerControllerSourceType)sourceType
{
    
    if ([UIImagePickerController isSourceTypeAvailable:sourceType])
    {
        [self.overlayViewController setupImagePicker:sourceType];
        [self presentModalViewController:self.overlayViewController.imagePickerController animated:YES];
    }
}

- (IBAction)photoLibraryAction:(id)sender
{   
	[self hideCameraMediaView];
    [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (IBAction)cameraAction:(id)sender
{
    [self hideCameraMediaView];
    [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
}

#pragma mark - E-mail Prompt
- (IBAction)handleEmailInsertButton:(id)sender {
    promptView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EmailAddress", @"") message:@"  " delegate:self cancelButtonTitle:NSLocalizedString(@"Remove", @"") otherButtonTitles:@"OK", nil];
    [promptView addSubview:emailPromptText];
    [promptView setTag: 2011];
    [promptView show];
    
    // set place
    [promptView setTransform:CGAffineTransformMakeTranslation(0, 110.0)];
    [emailPromptText becomeFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) { //cancel
        //[emailPromptText setText:@""];
        //[lblEmailSample setText:@""];
        [btnShareEmail setTitle:NSLocalizedString(@"ShareWithEmail", @"") forState:UIControlStateNormal];
    } else { // ok
        //[lblEmailSample setText: emailPromptText.text];
        [btnShareEmail setTitle:emailPromptText.text forState:UIControlStateNormal];
    }
}



#pragma mark - Overlay Delegate Methods
- (void)didTakePicture:(UIImage *)picture{
    self.capturedImage = picture;
    [self.imagetakenBadge setHidden:NO];
    [self.imagetakenBadge setImage:self.capturedImage];
    self.imagetakenBadge.layer.cornerRadius = 5.0f;
    self.imagetakenBadge.layer.masksToBounds = YES;
    self.imagetakenBadge.layer.borderWidth = 2.0f;
    self.imagetakenBadge.layer.borderColor = [[UIColor blackColor] CGColor];
}
- (void)didFinishWithCamera{
    [self  dismissModalViewControllerAnimated:YES];
}

-(IBAction)handleBeginTextFieldEdit:(id)sender{
    NSLog(@"begin edit");
}


#pragma mark - UIAlertView Delegate Method
- (void)alertView:(UIAlertView *)curAlertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if ([curAlertView tag] != 2011) {
        switch (buttonIndex) {
            case 1:
                [self.imagetakenBadge setHidden:YES];
                self.capturedImage = nil;
                break;
            case 2:
                [self.imagetakenBadge setHidden:YES];
                [self handleCameraButtonPress:nil];
                break;
            default:
                break;
        }
    }
}

#pragma mark - handle the invisible button press
-(IBAction)handleInvisibleButtonPress:(id)sender{
    [self.reviewTextView resignFirstResponder];
}

-(BOOL)validateReview{
    if (self.reviewNote == 0) {
        [CoreUtility showAnAlertMessage:NSLocalizedString(@"noReviewRateValue", nil) withTitle:NSLocalizedString(@"postReviewProblemTitle", @"")];
        return FALSE;
    }
    
    if (isEmpty( [self.reviewTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] ) ) {
        [CoreUtility showAnAlertMessage:NSLocalizedString(@"noReviewText", nil) withTitle:NSLocalizedString(@"postReviewProblemTitle", @"")];
        return FALSE;
    }
    return TRUE;
}

#pragma mark - Do the review submission
-(void)submitReview{
    
    //only proceeds after validating the screen
    if ([self validateReview]) {
        
        [self addWaitingAlertOverCurrentView];
        
        //get login credentials
        LoginData *loginData = [[LoginData alloc] init];
        NSString *username = nil;
        
        if ([loginData facebookProfileExist ]) {
            username = [[loginData facebookProfile] userName];//user_name
        } else {
            username = [[loginData profile] userName];//user_name 	
        }
        
        //WS-SOAP access bridge    
        EdirectoryParserToWSSoapAdapter * tempAdapter = [[EdirectoryParserToWSSoapAdapter alloc] init];
        [self setAdapter:tempAdapter];
        [tempAdapter release];
        
        [[self adapter] setDelegate:self];   
        
        
        NSData * imageDataToUpload = [NSData data];
        
        if (!isEmpty(self.capturedImage)) {
            imageDataToUpload = UIImageJPEGRepresentation(self.capturedImage, 1.0);
        }
        
        if(emailPromptText.text == nil) {
            [emailPromptText setText:@""];
        }
        
        NSLog(@"Business ID: %i", [(NSDecimalNumber *)[NSDecimalNumber numberWithInt:self.businessID] intValue] );        
        
        
        NSString * twitterKeyStr = [NSString string];
        NSString * twitterSecretKeyStr = [NSString string];      
        
        SA_OAuthTwitterEngine * _engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
        _engine.consumerKey    = [setm twitterApiKey];
        _engine.consumerSecret = [setm twitterApiSecret];
        
        if([_engine isAuthorized]) {
            if(self.twitterSwitch.on) {
                
                NSString * twitterData = [self cachedTwitterOAuthDataForUsername:@""];
                
                NSArray * arrayS = [twitterData componentsSeparatedByString:@"&"];                  
                
                for (NSString * strObj in arrayS) {
                    NSArray * arrayM = [strObj componentsSeparatedByString:@"="];
                    
                    if ( [(NSString*)[arrayM objectAtIndex:0] isEqualToString:@"oauth_token"] ) {
                        twitterKeyStr = [arrayM objectAtIndex:1];
                    }
                    
                    if ( [(NSString*)[arrayM objectAtIndex:0] isEqualToString:@"oauth_token_secret"] ) {
                        twitterSecretKeyStr = [arrayM objectAtIndex:1];
                    }
                    
                }
            }
        }
        
        [[self adapter] postReview:[self moduleName] itemID:(NSDecimalNumber *)[NSDecimalNumber numberWithInt:self.businessID]  userName:username rateValue:(NSDecimalNumber *)[NSDecimalNumber numberWithInt:self.reviewNote]  shareInFacebook:self.facebookSwitch.on shareInTwitter:self.twitterSwitch.on twitter_oauth_token:twitterKeyStr twitter_oauth_secret:twitterSecretKeyStr shareInEmail:self.emailPromptText.text reviewText:self.reviewTextView.text reviewImage:imageDataToUpload imagetype:@"jpg" foursquare_id:@""];
        
        [loginData release];
        [_engine release];
        
    } 
}

#pragma mark -
#pragma mark EdirectoryXMLParserDelegate Methods
-(void) parserEndWithError:(BOOL)hasErrors {
    
    //WS-SOAP access bridge    
    
    NSLog(@"There's an error while post the review: %@", [[self adapter] errorMessage]);
    
    [CoreUtility showAnAlertMessage:[[self adapter] errorMessage] withTitle:NSLocalizedString(@"postReviewProblemTitle", @"")];
    
    [self finalUpdate];
    
}

- (void) parserDidReceiveSearchResultsPosition:(double)latitude withLongitude:(double)longitude {
}

//Called by the parser when the results array was created
- (void)parserDidCreatedResultsArray:(NSArray *)objectResults{
	//receives a reference to Array from the Parser
}

//Called by the parser when the numbers for paging navigation is received
- (void)parserDidReceivePagingNumbers:(int)totalNumberOfPages wichPage:(int)actualPage{
}

//Called by the parser everytime that listingResults is updated with a batch of data
- (void)parserDidUpdateData:(NSArray *)objectResults{
	//Just reloads the data beacuse the listingResults is already referenced by this class
	//[self.tableView reloadData];
}


// Called by the parser when parsing is finished.
- (void)parserDidEndParsingData:(NSArray *)objectResults{
	//unblocks the screen
	[self finalUpdate];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didFinishPostReview)]) {
        [self.delegate didFinishPostReview];
    }
    //call method on parent view controller to update data from server
    [self.parentDetailViewController performSelector:@selector(updateDataFromServer)];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


// Called by the parser when no listingResults were found
- (void)noResultsWereFound{
    
	//return to the previous view
    //[self.navigationController popViewControllerAnimated:YES];
    
}

-(IBAction)handleFacebookSwitch:(id)sender{
    if (facebookSwitch.on) {
        /*self.imageTestView.image = self.capturedImage;
        CGRect tam = CGRectMake(0, 0, self.view.window.bounds.size.width, self.view.window.bounds.size.height);
        
        [self.imageTestView setFrame:tam];
        
        [self.view addSubview:self.imageTestView];
        [self.view bringSubviewToFront:self.imageTestView];*/
        
        //verifies if is obrigatory facebook login to review
        
    }/*else{
        [imageTestView removeFromSuperview];
    }*/
}


-(IBAction)handleReviewTextPress:(id)sender{
    
    ReviewTextViewController * controller = [[ReviewTextViewController alloc] initWithNibName:@"ReviewTextViewController" bundle:nil];
    [controller setParentReviewViewController:self];
    [self presentModalViewController:controller animated:YES];
    
    [controller release];
    
    
}

- (void)OAuthTwitterController:(SA_OAuthTwitterController *)controller authenticatedWithUsername:(NSString *)username {
    
}

- (void)OAuthTwitterControllerCanceled:(SA_OAuthTwitterController *)controller {
    [self.twitterSwitch setOn:NO];
}

@end
