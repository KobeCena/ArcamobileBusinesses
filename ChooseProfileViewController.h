//
//  ChooseProfileViewController.h
//  eDirectory
//
//  Created by Rafael Gustavo Gali on 30/09/10.
//  Copyright 2010 Arca Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookLogin.h"
#import "SettingsManager.h"
#import "ChooseProfileViewController.h"
#import "LoginViewController.h"
#import "ProfileContact.h"
#import "FacebookProfileContact.h"
#import "Listing.h"
#import "LoginData.h"
#import <CFNetwork/CFNetwork.h>
#import "AddProfileDelegateSupport.h"
#import "UserAuthenticationController.h"
#import "ARCAserver_businesses.h"

@protocol eAuthDelegate;

@interface ChooseProfileViewController : UIViewController <FacebookLoginDelegate, eDirectoryLoginDelegate, addProfileDelegateSupport, NSXMLParserDelegate, UITextFieldDelegate> {
	id<eAuthDelegate>         delegate;
	
	UIButton                 *facebookButton;
	SettingsManager          *setm;
	FacebookLogin            *fb;
    UIButton *btnSendSignUp;
    UIButton *btnSendSignIn;
	Listing                  *list;
    //	LoginViewController      *loginViewController;
	
	NSURLConnection			 *eDirectoryConnection;
    NSMutableData			 *eDirectoryData;
	
	NSString				 *currentItem;
	
	BOOL                      hideFacebook;
	BOOL                      hideProfileView;
    
    //    IBOutlet UIButton *loginWithProfileButton;
    //    IBOutlet UIButton *createNewProfileButton;
    
    //simulate the Segmented Control
    IBOutlet UIButton *signUpButton;
    IBOutlet UIButton *signInButton;
    IBOutlet UIView   *signUpView;
    IBOutlet UIView   *signInView;
    
    //to show the facebook option
    IBOutlet UIView *facebookView;
    
    UITextField *textFieldFirstName;
    UITextField *textFieldEmail;
    UITextField *textFieldPassword;
    UITextField *textFieldRetypePassword;
    
    //AlertView
    IBOutlet UIView *alertView;
    IBOutlet UILabel *alertLabel;
    
    //Delegate support for XML Parsing
    AddProfileDelegateSupport * delegateSupport;
    UITextField *emailLogintextField;
    UITextField *passwordLoginTextField;
    
    //profile
    ProfileContact             *profile;
    
    //Authentication Controller
    UserAuthenticationController *authController;
    
    UILabel *lblFormEmail;
    UILabel *lblFormPassword;
    UILabel *lblFormFullName;
    UILabel *lblFormVerifyPassword;
    UILabel *lblFormEmail2;
    UILabel *lblFormPassword2;
    UIButton *btnLoginWithFacebook;
    
    //Handles the keyboard visual status
    BOOL           keyboardIsVisible;  
    BOOL           calledFromSpecificTextField;
    CGPoint        offset;    
    
    ARCAserver_businesses *service;
}

@property (nonatomic, retain) IBOutlet UITextField *textFieldFirstName;
@property (nonatomic, retain) IBOutlet UITextField *textFieldEmail;
@property (nonatomic, retain) IBOutlet UITextField *textFieldPassword;
@property (nonatomic, retain) IBOutlet UITextField *textFieldRetypePassword;
@property (nonatomic, retain) IBOutlet UILabel     *alertLabel;


@property (nonatomic, retain) IBOutlet UIButton *facebookButton;
@property (nonatomic, retain) NSURLConnection   *eDirectoryConnection;
@property (nonatomic, retain) NSMutableData     *eDirectoryData;

@property (nonatomic, assign) id<eAuthDelegate>  delegate;
@property (nonatomic, retain) Listing           *list;
@property (nonatomic, retain) SettingsManager   *setm;

@property (nonatomic, retain) NSString          *currentItem;

@property (nonatomic, assign) BOOL               hideFacebook;
@property (nonatomic, assign) BOOL               hideProfileView;

@property (nonatomic, retain) IBOutlet UIButton *signUpButton;
@property (nonatomic, retain) IBOutlet UIButton *signInButton;
@property (nonatomic, retain) IBOutlet UIView   *signUpView;
@property (nonatomic, retain) IBOutlet UIView   *signInView;

@property (nonatomic, retain) IBOutlet UIView *alertView;

@property (nonatomic, retain) AddProfileDelegateSupport * delegateSupport;

@property (nonatomic, retain) IBOutlet UITextField *emailLogintextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordLoginTextField;

@property (nonatomic, retain) ProfileContact             *profile;
@property (nonatomic, retain) UserAuthenticationController *authController;

@property (nonatomic, retain) FacebookLogin            *fb;

@property (nonatomic, retain) IBOutlet UIButton *btnSendSignUp;
@property (nonatomic, retain) IBOutlet UIButton *btnSendSignIn;
@property (nonatomic, retain) IBOutlet UILabel *lblFormEmail;
@property (nonatomic, retain) IBOutlet UILabel *lblFormPassword;
@property (nonatomic, retain) IBOutlet UILabel *lblFormFullName;
@property (nonatomic, retain) IBOutlet UILabel *lblFormVerifyPassword;
@property (nonatomic, retain) IBOutlet UILabel *lblFormEmail2;
@property (nonatomic, retain) IBOutlet UILabel *lblFormPassword2;
@property (nonatomic, retain) IBOutlet UIButton *btnLoginWithFacebook;
@property (retain, nonatomic) IBOutlet UIView *placeHolderView;

@property (retain, nonatomic) ARCAserver_businesses *service;

-(void)handleError:(NSError *)error;
-(IBAction)AddProfileSelected:(UIButton *)sender;
//-(IBAction)LoginButtonSelected:(UIButton *)sender;
-(IBAction)FacebookButtonSelected:(UIButton *)sender;

-(IBAction)handleSignUpButtonPress:(UIButton *)sender;
-(IBAction)handleSignInButtonPress:(UIButton *)sender;
-(IBAction)signupButtonPressed:(id)sender;
-(IBAction)signinButtonPressed:(id)sender;
- (IBAction)forgotPasswordPressed:(id)sender;


-(void)hidesTheBackButton;


#pragma mark eDirectoryLoginDelegates
-(void)eDirectoryDidLogin;
-(void)eDirectoryDidNotLogin;


@end

@protocol eAuthDelegate<NSObject>
-(void)didLogin;
-(void)didNotLogin;
@end
