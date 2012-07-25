//
//  LoginViewController.m
//  eDirectory
//
//  Created by Rafael Gustavo Gali on 30/09/10.
//  Copyright 2010 Arca Solutions. All rights reserved.
//

#import "LoginViewController.h"
#import <CFNetwork/CFNetwork.h>
#import "UserAuthenticationController.h"

@implementation LoginViewController

@synthesize tableViewCellEmail, tableViewCellPassword, textFieldEmail, textFieldPassword, eDirectoryConnection, eDirectoryData, currentItem, authMessage, list, profile, delegate, authController;
@synthesize alertView, alertLabel;

- (void)dealloc {
	//[delegate release];
	[authMessage           release];
	[profile               release];
	[tableViewCellEmail    release];
	[tableViewCellPassword release];
	[textFieldEmail        release];
	[textFieldPassword     release];
	[eDirectoryData        release];
	[currentItem           release];
	[list                  release];
    [authController        release];
    [alertView             release];
    [alertLabel            release];
    [super                 dealloc];
}

#pragma mark -
#pragma mark Methods for show and hide an alert view for block the screen
- (void) addWaitingAlertOverCurrentView{
	
	[self.view setUserInteractionEnabled:NO];
	//ALERT MESSAGE
	[self.view addSubview: alertView];	
	
    alertView.backgroundColor = [UIColor clearColor];
	
	//alertView.center = super.view.center;
	[alertView setCenter:self.view.center];
    CALayer *viewLayer = alertView.layer;
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.duration = 0.35555555;
	animation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.6],[NSNumber numberWithFloat:1.1],[NSNumber numberWithFloat:.9],[NSNumber numberWithFloat:1],nil];
    animation.keyTimes = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:0.6],[NSNumber numberWithFloat:0.8],[NSNumber numberWithFloat:1.0],nil];    
    [viewLayer addAnimation:animation forKey:@"transform.scale"];
	[self performSelector:@selector(updateText:) withObject:NSLocalizedString(@"Wait", @"") afterDelay:0.0];
	
}

- (void)updateText:(NSString *)newText
{
    alertLabel.text = newText;
}

- (void)finalUpdate
{
    [UIView beginAnimations:@"" context:nil];
    alertView.alpha = 0.0;
    [UIView commitAnimations];
    [UIView setAnimationDuration:0.35];
    [self performSelector:@selector(removeWaitingAlertFromoCurrentView) withObject:nil afterDelay:0.5];
}

- (void) removeWaitingAlertFromoCurrentView{
	[self.view setUserInteractionEnabled:YES];
    [alertView removeFromSuperview];
    alertView.alpha = 1.0;	
}



-(IBAction)hideKeyboard:(id)sender
{
	[self resignFirstResponder];
    [textFieldPassword resignFirstResponder];
    [textFieldEmail resignFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
	[textFieldEmail becomeFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    loginButton.frame = CGRectMake(240, 140, 72, 37);
    [loginButton addTarget:self action:@selector(loginButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [loginButton setTitle:NSLocalizedString(@"LoginButton", @"") forState:UIControlStateNormal];
    [self.view addSubview:loginButton];
	
	profile = [[ProfileContact alloc] init];
    

    authController =  [[UserAuthenticationController alloc] init];

    //register this class to listen all notifications comming from the UserAuthenticationController
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(listenFromAuthenticationPhase:)
                                                 name:nil object:self.authController];
    
    
    [textFieldEmail setPlaceholder:NSLocalizedString(@"Email", @"")];
    [textFieldPassword setPlaceholder:NSLocalizedString(@"Password", @"")];
    
}

-(BOOL)fieldsValidated:(NSString **)message {
	if ([textFieldEmail.text length] == 0) {
		*message = NSLocalizedString(@"EmailRequired", @"");
		return NO;
	}
	if ([textFieldPassword.text length] == 0) {
		*message = NSLocalizedString(@"PasswordRequired", @"");
		return NO;
	}
	return YES;
}

-(void)listenFromAuthenticationPhase:(NSNotification *) notification{
    
    if ([notification.name isEqualToString:@"AUTHOK"]) {

		LoginData *login = [[LoginData alloc] init];
		[login setProfile:profile];
		[login saveProfileData];
		[login release];
		
		[[self delegate] eDirectoryDidLogin];
        
    }

    if ([notification.name isEqualToString:@"AUTHNOK"]) {
        NSLog(@"Autenticação falhou:");        
        
		NSString *message = [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"LoginFail", @"") ,[self.authController authMessage]];
		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle:NSLocalizedString(@"LoginTitle", @"")
							  message:message
							  delegate:nil 
							  cancelButtonTitle:NSLocalizedString(@"OK", @"")
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		[[self delegate] eDirectoryDidNotLogin];
        
    }
    
    [self removeWaitingAlertFromoCurrentView];
    
}

-(void)loginButtonClicked
{
	

    [self addWaitingAlertOverCurrentView];
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
    
	[self hideKeyboard:nil];
    
    [profile setUserName:[textFieldEmail text]];
    

    [self.authController startAuthenticationPhaseWithCredentials:profile usingPassword:[textFieldPassword text]];

    
    
    /*
	NSString *path = [[NSBundle mainBundle] pathForResource:@"ConnectionStrings" ofType:@"plist"];		
	NSDictionary *connPlist = [NSDictionary dictionaryWithContentsOfFile:path];
	NSString *url = [connPlist objectForKey:@"Login"];
	
	NSString* userAgent = @"Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en)";
	NSString *post = [NSString stringWithFormat:@"username=%@&password=%@", [textFieldEmail text], [textFieldPassword text]];
	NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat: @"%d", [postData length]];
	NSMutableURLRequest *eDirectoryURLRequest = [[[NSMutableURLRequest alloc] init] autorelease];
	[eDirectoryURLRequest setURL: [NSURL URLWithString:url]];
	[eDirectoryURLRequest setHTTPMethod:@"POST"];
	[eDirectoryURLRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[eDirectoryURLRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"]; 
	[eDirectoryURLRequest setHTTPBody:postData];  
	[eDirectoryURLRequest setValue:userAgent forHTTPHeaderField:@"User-Agent"];
	eDirectoryConnection = [[[NSURLConnection alloc] initWithRequest:eDirectoryURLRequest delegate:self] autorelease];
    */
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
	return 35;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	// create the parent view that will hold header Label
	UIView* customView = [[[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)] autorelease];
	
	// create the button object
	UILabel * headerLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.opaque = NO;
	headerLabel.textColor = [UIColor darkGrayColor];
	headerLabel.font = [UIFont systemFontOfSize:12];
	headerLabel.numberOfLines = 2;
	headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 44.0);
	
	headerLabel.text = NSLocalizedString(@"LoginHeaderMessage", @""); 
	[customView addSubview:headerLabel];
	
	return customView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	if (indexPath.section == 0) {
		switch (indexPath.row) {
			case 0:
				cell = tableViewCellEmail;
				break;
			case 1:
				cell = tableViewCellPassword;
				break;
			default:
				break;
		}
	}	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


/*
//XML
#pragma mark NSURLConnection delegate methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.eDirectoryData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.eDirectoryData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
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
	if (authenticateAccount == YES)
	{	
		
		LoginData *login = [[LoginData alloc] init];
		[login setProfile:profile];
		[login saveProfileData];
		[login release];
		
		[[self delegate] eDirectoryDidLogin];
		
	} else {
		NSString *message = [NSString stringWithFormat:@"Login fail!\n%@",[self authMessage]];
		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle:@"Login" 
							  message:message
							  delegate:nil 
							  cancelButtonTitle:@"OK" 
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		[[self delegate] eDirectoryDidNotLogin];

	}				  
}

- (void)handleError:(NSError *)error {
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Downloading Error", @"Title for alert displayed when download or parse error occurs.") message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

//PARSER DELEGATE
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	currentItem = elementName;
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	currentItem = nil;
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if ([currentItem isEqualToString:@"authenticateAccount"]) 
	{
		//if ([string isEqualToString:@"yes"]) {
		if ([string boolValue]) {
			authenticateAccount = YES;
		} else {
			authenticateAccount = NO;
		}
	} else if ([currentItem isEqualToString:@"authmessage"]) {
		//authMessage = string;
		[self setAuthMessage:string];
	} else if ([currentItem isEqualToString:@"id"]) {
		[profile setProfileID:[NSNumber numberWithInt:[string intValue]]] ;
	} else if ([currentItem isEqualToString:@"username"]) {
		[profile setUserName:string];
	} else if ([currentItem isEqualToString:@"name"]) {
		[profile setName:string];
	} else if ([currentItem isEqualToString:@"first_name"]) {
		[profile setFirstName:string];
	} else if ([currentItem isEqualToString:@"last_name"]) {
		[profile setLastName:string];
	} else if ([currentItem isEqualToString:@"email"]) {
		[profile setEmail:string];
	} else if ([currentItem isEqualToString:@"location"]) {
		[profile setLocation:string];
	} else if ([currentItem isEqualToString:@"ip"]) {
		[profile setIp:string];
	}
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
}

- (void)parserDidEndDocument:(NSXMLParser *)parser{
}

- (void)parserDidEndParsingData:(NSArray *)objectResults{
}
*/

@end