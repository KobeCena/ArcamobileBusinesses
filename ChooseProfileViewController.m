//
//  ChooseProfileViewController.m
//  eDirectory
//
//  Created by Rafael Gustavo Gali on 30/09/10.
//  Copyright 2010 Arca Solutions. All rights reserved.
//

#import "ChooseProfileViewController.h"
#import "AddProfileDelegateSupport.h"
#import "CoreUtility.h"

#import "ForgotPasswordViewController.h"


#define kOFFSET_FOR_KEYBOARD 150.0;

@implementation ChooseProfileViewController
@synthesize lblFormEmail;
@synthesize lblFormPassword;
@synthesize lblFormFullName;
@synthesize lblFormVerifyPassword;
@synthesize lblFormEmail2;
@synthesize lblFormPassword2;
@synthesize btnLoginWithFacebook;
@synthesize placeHolderView;
@synthesize textFieldRetypePassword;
@synthesize textFieldFirstName;
@synthesize textFieldEmail;
@synthesize textFieldPassword;
@synthesize service;


@synthesize list, setm, delegate;
@synthesize eDirectoryConnection, eDirectoryData, currentItem, hideFacebook, facebookButton;
@synthesize signInButton, signUpButton;
@synthesize signInView, signUpView;
@synthesize alertView, alertLabel;

@synthesize delegateSupport;
@synthesize emailLogintextField;
@synthesize passwordLoginTextField;
@synthesize profile;

@synthesize authController;
@synthesize fb;
@synthesize btnSendSignUp;
@synthesize btnSendSignIn;
@synthesize hideProfileView;

#pragma mark - Blocks the screen
-(void)addWaitingAlertOverCurrentView{
    //ALERT MESSAGE
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
}

- (void)dealloc {
    
	[facebookButton             release];
	[eDirectoryData             release];
	[list                       release];
	[currentItem                release];
	[fb                         release];
	[setm                       release];
    [signInButton               release];
    [signUpButton               release];
    [signUpView                 release];
    [signInView                 release];
    
    [facebookView               release];
    [textFieldFirstName         release];
    [textFieldEmail             release];
    [textFieldPassword          release];
    [textFieldRetypePassword    release];
    
    
    [delegateSupport            release];
    [profile                    release];
    
    [alertView                  release];
    [alertLabel                 release];
    [emailLogintextField        release];
    [passwordLoginTextField     release];
    [authController             release];
    
    [btnSendSignUp release];
    [btnSendSignIn release];
    [lblFormEmail release];
    [lblFormPassword release];
    [lblFormFullName release];
    [lblFormVerifyPassword release];
    [lblFormEmail2 release];
    [lblFormPassword2 release];
    [btnLoginWithFacebook release];
    [placeHolderView release];
    
    [service release];
    [super                    dealloc];
}

#pragma - SignIn and SignUp button methods
-(IBAction)handleSignUpButtonPress:(UIButton *)sender{
    
    [self.signUpButton setTitleShadowColor:[UIColor grayColor] forState:UIControlStateSelected];
    self.signUpButton.titleLabel.shadowOffset = CGSizeMake(-1.0f, -1.0f);
    self.signUpButton.selected = TRUE;    
    self.signInButton.selected = FALSE;
    self.signInView.hidden = YES;
    self.signUpView.hidden = NO;
    
}

-(IBAction)handleSignInButtonPress:(UIButton *)sender{
    [self.signInButton setTitleShadowColor:[UIColor grayColor] forState:UIControlStateSelected];
    self.signInButton.titleLabel.shadowOffset = CGSizeMake(-1.0f, -1.0f);
    self.signUpButton.selected = FALSE;
    self.signInButton.selected = TRUE;
    self.signInView.hidden = NO;
    self.signUpView.hidden = YES;
}

-(IBAction)FacebookButtonSelected:(UIButton *)sender
{
    [self addWaitingAlertOverCurrentView];
    
	[facebookButton setEnabled:NO];
	fb = [[FacebookLogin alloc] initWithAuthorize];
	[fb setDelegate:self];
}


-(void)hidesTheBackButton{
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationController.navigationItem setHidesBackButton:YES];
}

#pragma mark - get a dictionary with DomainToken from a plistfile
-(NSDictionary *) getDomainToken{
    NSDictionary * dic = [CoreUtility getDictionaryFromPlistNamed:@"DomainToken"];
    NSMutableDictionary * dicR = [NSMutableDictionary dictionaryWithObject:dic forKey:@"DomainKeyDict"];
    
    NSDictionary * dicL = [NSDictionary dictionaryWithObject:[[NSLocale preferredLanguages] objectAtIndex:0] forKey:@"AppLanguage"];
    
    [dicR setValue:dicL forKey:@"AppLanguageDict"];
    
    return dicR;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    service = [[ARCAserver_businesses alloc] init];
    [service setLogging:YES];
    [service setHeaders: [self getDomainToken]];
    
    [signUpButton setTitle:NSLocalizedString(@"ButtonSignUp", @"") forState:UIControlStateNormal];
    [signInButton setTitle:NSLocalizedString(@"ButtonSignIn", @"") forState:UIControlStateNormal];
    
    [btnSendSignUp setTitle:NSLocalizedString(@"ButtonSignUp", @"") forState:UIControlStateNormal];
    [btnSendSignIn setTitle:NSLocalizedString(@"ButtonSignIn", @"") forState:UIControlStateNormal];
    
    [lblFormEmail setText: NSLocalizedString(@"FormEmail", @"")];
    [lblFormPassword setText: NSLocalizedString(@"FormPassword", @"")];
    [lblFormFullName setText:NSLocalizedString(@"FormFullName", @"")];
    [lblFormVerifyPassword setText:NSLocalizedString(@"FormVerifyPassword", @"")];
    
    [lblFormEmail2 setText: NSLocalizedString(@"FormEmail", @"")];
    [lblFormPassword2 setText: NSLocalizedString(@"FormPassword", @"")];
    
    [btnLoginWithFacebook setTitle:NSLocalizedString(@"LoginWithFacebook", @"") forState:UIControlStateNormal];
    
    authController =  [[UserAuthenticationController alloc] init];
    
    //register this class to listen all notifications comming from the UserAuthenticationController
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(listenFromAuthenticationPhase:)
                                                 name:nil object:self.authController];
    
    
    
	profile = [[ProfileContact alloc] init];    
    
    [self handleSignUpButtonPress:nil];
    
    if ([setm facebookEnabled] && hideFacebook == NO) {
        [facebookView setHidden:NO];
    }else{
        [facebookView setHidden:YES];        
    }
    
    [placeHolderView setHidden:hideProfileView];
    
    //[loginWithProfileButton setTitle:NSLocalizedString(@"LoginWithProfile", @"") forState:UIControlStateNormal];
    //[createNewProfileButton setTitle:NSLocalizedString(@"CreateNewProfile", @"") forState:UIControlStateNormal];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector (keyboardDidShow:)
                                                 name: UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector (keyboardDidHide:)
                                                 name: UIKeyboardDidHideNotification object:nil];    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillDisappear:(BOOL)animated{    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload {
    
    [facebookView release];
    facebookView = nil;
    [textFieldFirstName release];
    textFieldFirstName = nil;
    [textFieldEmail release];
    textFieldEmail = nil;
    [textFieldPassword release];
    textFieldPassword = nil;
    
    [textFieldRetypePassword release];
    textFieldRetypePassword = nil;
    
    [self setTextFieldRetypePassword:nil];
    [alertView release];
    alertView = nil;
    [self setAlertLabel:nil];
    [self setEmailLogintextField:nil];
    [self setPasswordLoginTextField:nil];
    [self setBtnSendSignUp:nil];
    [self setBtnSendSignIn:nil];
    [self setLblFormEmail:nil];
    [self setLblFormPassword:nil];
    [self setLblFormFullName:nil];
    [self setLblFormVerifyPassword:nil];
    [self setLblFormEmail2:nil];
    [self setLblFormPassword2:nil];
    [self setBtnLoginWithFacebook:nil];
    [self setPlaceHolderView:nil];
    [super viewDidUnload];
}


//-(IBAction)LoginButtonSelected:(UIButton *)sender
//{
//	loginViewController  = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
//	[loginViewController setTitle:NSLocalizedString(@"LoginTitle", @"")];
//	[loginViewController setList:list];
//	[loginViewController setDelegate:self];
//	[[self navigationController] pushViewController:loginViewController animated:YES];
//}

-(IBAction)AddProfileSelected:(UIButton *)sender {
    //	addProfileViewController = [[AddProfileViewController alloc] initWithNibName: @"AddProfileViewController" bundle:nil];
    //	[addProfileViewController setTitle:NSLocalizedString(@"CreateProfile", "")];
    //	[addProfileViewController setList:list];
    //	[addProfileViewController setDelegate:self];
    //	[[self navigationController] pushViewController:addProfileViewController animated:YES];
}


#pragma mark FacebookLoginDelegates
-(void)facebookDidLogin
{    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[facebookButton setEnabled:YES];
    
    [self finalUpdate];
    
}

-(void)facebookRequestReturn
{
	if ([fb login] == YES) 
	{
        [self addWaitingAlertOverCurrentView];
        NSLog(@"[facebookRequestReturn ] 002");
		//CREATE NEW PROFILE
        
        [service loginWithFacebook:self action:@selector(eDirectoryDidLogin) uid:[[fb facebookProfile] facebookID] firstName:[[[fb facebookProfile] firstName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] lastName:[[[fb facebookProfile] lastName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] acessToken:[[[fb facebookProfile] accessToken] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
		/*NSString            *path =                 [[NSBundle mainBundle] pathForResource:@"ConnectionStrings" ofType:@"plist"];		
		NSDictionary        *connPlist =            [NSDictionary dictionaryWithContentsOfFile:path];
		NSString            *url =                  [NSString stringWithFormat:[connPlist objectForKey:@"FacebookAuth"], 
													 [[fb facebookProfile] facebookID],
													 [[[fb facebookProfile] firstName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
													 [[[fb facebookProfile] lastName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                                     [[[fb facebookProfile] accessToken] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
													 ];
		
		NSMutableURLRequest *eDirectoryURLRequest = [[[NSMutableURLRequest alloc] init] autorelease];
		[eDirectoryURLRequest setURL: [NSURL URLWithString:url]];
		[eDirectoryURLRequest setValue:@"Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en)" forHTTPHeaderField:@"User-Agent"];
		eDirectoryConnection = [[[NSURLConnection alloc] initWithRequest:eDirectoryURLRequest delegate:self] autorelease];*/
		
	}		
}
-(void)facebookDidNotLogin
{
	[facebookButton setEnabled:YES];
    
	[[self delegate] didNotLogin];
    [self finalUpdate];
}

#pragma mark eDirectoryLoginDelegates
-(void)eDirectoryDidLogin{
    [[NSNotificationCenter defaultCenter] removeObserver:self];    
	[[self delegate] didLogin];
}
-(void)eDirectoryDidNotLogin {
	[[self delegate] didNotLogin];
}

#pragma mark AddProfileDelegateSupport
-(void)addProfileDidLogin {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];    
    //just repass the event
	[[self delegate] didLogin];
    
    //releases the parserDelegateSupport
    //    [delegateSupport release];
}

-(void)addProfileDidNotLogin {
    //unlocks the screen
    [self finalUpdate];
    
    //just repass the event 
	[[self delegate] didNotLogin];
    
    //releases the parserDelegateSupport
    //    [delegateSupport release];
}

//XML
#pragma mark NSURLConnection delegate methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.eDirectoryData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.eDirectoryData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    [self finalUpdate];
    
	
	if ([error code] == kCFURLErrorNotConnectedToInternet) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"No Connection Error", @"Sorry! You need an internet connection to proceed with this action.") forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain code:kCFURLErrorNotConnectedToInternet userInfo:userInfo];
        [self handleError:noConnectionError];
    } else {
        [self handleError:error];
    }
    self.eDirectoryConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData: eDirectoryData];
	[parser setDelegate:self];
	[parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
	[parser release];
	self.eDirectoryData = nil;
	
	
}

- (void)handleError:(NSError *)error {
    NSString *errorMessage = [error localizedDescription];
	
    //	NSLog(@"%@", errorMessage);
    //	NSLog(@"%@", NSLocalizedString(@"Downloading Error", @"Title for alert displayed when download or parse error occurs.") );
	
	
    UIAlertView *alertErrorView = [[UIAlertView alloc] 
								   initWithTitle:NSLocalizedString(@"Downloading Error", @"Title for alert displayed when download or parse error occurs.") 
								   message:errorMessage 
								   delegate:nil
								   cancelButtonTitle:@"OK" 
								   otherButtonTitles:nil
								   ];
	
    [alertErrorView show];
    [alertErrorView release];
	
}

//PARSER DELEGATE
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	currentItem = elementName;
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	currentItem = nil;
	
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if ([currentItem isEqualToString:@"member_id"]) 
	{
		NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
		[f setNumberStyle:NSNumberFormatterDecimalStyle];
		
		LoginData *loginData = [[LoginData alloc] init];
		[[loginData facebookProfile] setProfileID: [f numberFromString:string]];
		[loginData saveFacebookProfileData];
		[f release];
		[loginData release];
	} 
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    [self finalUpdate];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser{
    [self finalUpdate];
	[[self delegate] didLogin];
}

- (void)parserDidEndParsingData:(NSArray *)objectResults{
    [self finalUpdate];
}


#pragma - Hides the keyboard for all textFields
- (IBAction)textFieldFinishedEditing:(id)sender
{
	UITextField *whichTextField = (UITextField *)sender;
	[whichTextField resignFirstResponder];
}

-(BOOL)fieldsValidated:(NSString **)message
{
    
	if ([emailLogintextField.text length] == 0 && signInButton.selected)
	{
		*message = NSLocalizedString(@"EmailRequired", @"");
		return NO;
	}
    
	if ([passwordLoginTextField.text length] == 0 && signInButton.selected)
	{
		*message = NSLocalizedString(@"PasswordRequired", @"");
		return NO;
	}
    
    
	if ([textFieldFirstName.text length] == 0 && signUpButton.selected)
	{
		*message = NSLocalizedString(@"FirstNameRequired", @"");
		return NO;
	}
	if ([textFieldEmail.text length] == 0 && signUpButton.selected) {
		*message = NSLocalizedString(@"EmailRequired", @"");
		return NO;
	}
	if ([textFieldPassword.text length] == 0 && signUpButton.selected) {
		*message = NSLocalizedString(@"PasswordRequired", @"");
		return NO;
	}
	if ([textFieldPassword.text length] <4 && signUpButton.selected) {
		*message = NSLocalizedString(@"Minimun4Char", @"");
		return NO;
	}
	if ([textFieldRetypePassword.text length] == 0 && signUpButton.selected) {
		*message = NSLocalizedString(@"RetypePassword", @"");
		return NO;
	}
	if (![[textFieldPassword text] isEqualToString:[textFieldRetypePassword text]] && signUpButton.selected) {
		*message = NSLocalizedString(@"PasswordNotMatch", @"");
		return NO;
	}	
	return YES;
}



#pragma mark - Signup button press Method
-(IBAction)signupButtonPressed:(id)sender
{
    //perform the fields validation
	NSString *messageValidate;
	if (![self fieldsValidated:&messageValidate]) {
		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle:nil
							  message:messageValidate
							  delegate:nil 
							  cancelButtonTitle:NSLocalizedString(@"OK", @"")
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
    
    //blocks this screen
    [self addWaitingAlertOverCurrentView];
    
#pragma mark - POST ADD PROFILE
    AddProfileDelegateSupport * tempObject = [[AddProfileDelegateSupport alloc] init];
    
    self.delegateSupport = tempObject;
    [self.delegateSupport setDelegate:self];
    [tempObject release];    
    
    //create a DICT to pass to AddProfileDelegateSupport with all info provided by user
    NSMutableDictionary * userInfoDic = [NSMutableDictionary dictionary];
    
    [userInfoDic setObject:[textFieldEmail text] forKey:@"EMAIL"];
    [userInfoDic setObject:[textFieldPassword text]forKey:@"PASSWORD"];
    [userInfoDic setObject:[textFieldRetypePassword text] forKey:@"RETYPEDPASSWORD"];
    [userInfoDic setObject:[textFieldFirstName text] forKey:@"FIRSTNAME"];
    [userInfoDic setObject:@"en_us" forKey:@"DEFAULTLANGUAGE"];
    [userInfoDic setObject:[textFieldFirstName text] forKey:@"USERNAME"];
    
    [self.delegateSupport createUserProfileWithData:userInfoDic];
    
    /*    
     NSString *path = [[NSBundle mainBundle] pathForResource:@"ConnectionStrings" ofType:@"plist"];		
     NSDictionary *connPlist = [NSDictionary dictionaryWithContentsOfFile:path];
     NSString *url = [connPlist objectForKey:@"AddProfile"];
     
     NSString* userAgent = @"Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en)";
     NSString *params = [NSString stringWithFormat:@"username=%@&password=%@&retype_password=%@&lang=%@&first_name=%@&last_name=%@&company=%@&address=%@&address2=%@&country=%@&state=%@&city=%@&zip=%@&phone=%@&fax=%@&email=%@&url=%@",
     [textFieldEmail text], //@"rafaelgali@gmail.com",//username
     [textFieldPassword text], //@"123456",//password
     [textFieldRetypePassword text],
     @"en_us",//lang
     [textFieldFirstName text],//@"Rafael",//first_name
     @"CORRIGIR_LASTNAME",//last_name
     @"",//company
     @"",//address
     @"",//address2
     @"",//country
     @"",//state
     @"",//city
     @"",//zip
     @"",//phone
     @"",//fax
     [textFieldEmail text],//@"rafaelgali@gmail.com",//email
     @""//url                        
     ];
     
     
     NSData *postData = [params dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
     NSString *postLength = [NSString stringWithFormat: @"%d", [postData length]];
     NSMutableURLRequest *eDirectoryURLRequest = [[[NSMutableURLRequest alloc] init] autorelease];
     [eDirectoryURLRequest setURL: [NSURL URLWithString:url]];
     [eDirectoryURLRequest setHTTPMethod:@"POST"];
     [eDirectoryURLRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
     [eDirectoryURLRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"]; 
     [eDirectoryURLRequest setHTTPBody:postData];  
     [eDirectoryURLRequest setValue:userAgent forHTTPHeaderField:@"User-Agent"];
     eDirectoryConnection = [[[NSURLConnection alloc] initWithRequest:eDirectoryURLRequest delegate:self.delegateSupport] autorelease];	
     */	
}


-(IBAction)signinButtonPressed:(id)sender{
	
	NSString *messageValidate;
	if (![self fieldsValidated:&messageValidate]) {
		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle:NSLocalizedString(@"LoginTitle", @"")
							  message:messageValidate
							  delegate:nil 
							  cancelButtonTitle:NSLocalizedString(@"OK", @"")
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
    
    [self addWaitingAlertOverCurrentView];     
    
    
    NSString * strUser = [NSString stringWithString:[emailLogintextField text]]; 
    [profile setUserName:strUser];
    [profile setName:strUser];
    [profile setProfileID:[NSNumber numberWithInt:1]];
    [profile setFirstName:strUser];    
    [profile setEmail:strUser];
    [profile setLocation:@"LOCATION"];
    
    [self.authController startAuthenticationPhaseWithCredentials:profile usingPassword:[passwordLoginTextField text]];
    
}


- (IBAction)forgotPasswordPressed:(id)sender {
    ForgotPasswordViewController * forgotPasswordController = [[ForgotPasswordViewController alloc] initWithNibName:@"ForgotPasswordViewController" bundle:nil];

    [self.navigationController pushViewController:forgotPasswordController animated:YES];
    
    [forgotPasswordController release];
}

#pragma mark - Listen notifications from UsersAuthenticationController
-(void)listenFromAuthenticationPhase:(NSNotification *) notification{
    
    if ([notification.name isEqualToString:@"AUTHOK"]) {
        
		LoginData *login = [[LoginData alloc] init];
		[login setProfile:profile];
		[login saveProfileData];
		[login release];
		
		[self  eDirectoryDidLogin];
        [self finalUpdate];
    }
    
    if ([notification.name isEqualToString:@"AUTHNOK"]) {      
        
		NSString *message = [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"LoginFail", @"") ,[self.authController authMessage]];
		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle:NSLocalizedString(@"LoginTitle", @"")
							  message:message
							  delegate:nil 
							  cancelButtonTitle:NSLocalizedString(@"OK", @"")
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		[self  eDirectoryDidNotLogin];
        [self finalUpdate];        
    }
    
}

#pragma mark - Handle the keyboard appear disappear
-(void) keyboardDidShow: (NSNotification *)notif 
{
    // If keyboard is visible, return
    if (keyboardIsVisible) 
    {
        NSLog(@"Keyboard is already visible. Ignoring notification.");
        return;
    }
    
    //only move the view for two specific textFields
    if ([self.textFieldPassword isFirstResponder] || [self.textFieldRetypePassword isFirstResponder]) {
        //begin animations
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        
        //get a reference to view's rect
        CGRect rect = self.view.frame;
        
        //do some changes in the view's rect
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
        
        //aply the new rect
        self.view.frame = rect;
        
        //commit the animations
        [UIView commitAnimations];
        
        calledFromSpecificTextField = YES;
    }    
    
    
    // Keyboard is now visible
    keyboardIsVisible = YES;
}

-(void) keyboardDidHide: (NSNotification *)notif 
{
    // Is the keyboard already shown
    if (!keyboardIsVisible) 
    {
        NSLog(@"Keyboard is already hidden. Ignoring notification.");
        return;
    }

    if (calledFromSpecificTextField) {

        //begin animations
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        
        //get a reference to view's rect
        CGRect rect = self.view.frame;
        
        //do some changes in the view's rect
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
        
        //aply the new rect
        self.view.frame = rect;
        
        //commit the animations
        [UIView commitAnimations];
        
        calledFromSpecificTextField = NO;
    }    
    
    // Keyboard is no longer visible
    keyboardIsVisible = NO;	
}

@end