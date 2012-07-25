//
//  AddProfileViewController.m
//  eDirectory
//
//  Created by Rafael Gustavo Gali on 29/09/10.
//  Copyright 2010 Arca Solutions. All rights reserved.
//

#import "AddProfileViewController.h"
#import <CFNetwork/CFNetwork.h>
#import <QuartzCore/QuartzCore.h>

#define kViewPickerOffScreen CGRectMake(0, 425, 320, 216)
#define kViewPickerOnScreen  CGRectMake(0, 151, 320, 216)

@implementation AddProfileViewController

@synthesize tableViewCellFirstName, tableViewCellLastName, tableViewCellEmail, tableViewCellPassword, tableViewCellRetypePassword, tableViewCellLanguage;
@synthesize textFieldFirstName, textFieldLastName, textFieldEmail, textFieldPassword, textFieldRetypePassword, buttonLanguage;
@synthesize pickerLocation, viewPicker, list, eDirectoryConnection, eDirectoryData, currentItem, authMessage, alertView, alertLabel, profile, delegate;
@synthesize languageID, languageName;

- (void)dealloc {
	[languageID             release];
	[languageName           release];
	[profile                release];
	[alertView              release], alertView = nil;
    [alertLabel             release], alertLabel = nil;
	[currentItem            release];
	[authMessage            release];
	[tableViewCellFirstName release];
	[textFieldFirstName     release];
	[list                   release];
	[eDirectoryData         release];
	[tableViewCellLastName  release];
	[textFieldLastName      release];
	[tableViewCellEmail     release];
	[textFieldEmail         release];
	[tableViewCellPassword  release];
	[textFieldPassword      release];
	[tableViewCellLanguage  release];
	[buttonLanguage         release];
    [privacyPolicyLabel release];
    [signUpButton release];
    [super                  dealloc];
}

/*
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event  {
	if (event.type == UIEventSubtypeMotionShake) {
		[textFieldFirstName setText:@"Rafael"];
		[textFieldLastName setText:@"Gali"];
		[textFieldEmail setText:@"rafaelgali@gmail.com"];
		[textFieldPassword setText:@"123456"];
	}
}
*/

-(BOOL)fieldsValidated:(NSString **)message
{
	if ([textFieldFirstName.text length] == 0)
	{
		*message = NSLocalizedString(@"FirstNameRequired", @"");
		return NO;
	}
	if ([textFieldLastName.text length] == 0)
	{
		*message = NSLocalizedString(@"LastNameRequired", @"");
		return NO;
	}
	if ([textFieldEmail.text length] == 0) {
		*message = NSLocalizedString(@"EmailRequired", @"");
		return NO;
	}
	if ([textFieldPassword.text length] == 0) {
		*message = NSLocalizedString(@"PasswordRequired", @"");
		return NO;
	}
	if ([textFieldPassword.text length] <4) {
		*message = NSLocalizedString(@"Minimun4Char", @"");
		return NO;
	}
	if ([textFieldRetypePassword.text length] == 0) {
		*message = NSLocalizedString(@"RetypePassword", @"");
		return NO;
	}
	if (![[textFieldPassword text] isEqualToString:[textFieldRetypePassword text]]) {
		*message = NSLocalizedString(@"PasswordNotMatch", @"");
		return NO;
	}
	
	return YES;
}


-(IBAction)signupButtonPressed:(id)sender
{
	
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
	//

#pragma mark POST ADD PROFILE

	NSString *path = [[NSBundle mainBundle] pathForResource:@"ConnectionStrings" ofType:@"plist"];		
	NSDictionary *connPlist = [NSDictionary dictionaryWithContentsOfFile:path];
	NSString *url = [connPlist objectForKey:@"AddProfile"];
	
	NSString* userAgent = @"Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en)";
	NSString *params = [NSString stringWithFormat:@"username=%@&password=%@&retype_password=%@&lang=%@&first_name=%@&last_name=%@&company=%@&address=%@&address2=%@&country=%@&state=%@&city=%@&zip=%@&phone=%@&fax=%@&email=%@&url=%@",
							[textFieldEmail text], //@"rafaelgali@gmail.com",//username
							[textFieldPassword text], //@"123456",//password
							[textFieldRetypePassword text],
							[[dic allKeys] objectAtIndex:[pickerLocation  selectedRowInComponent:0]],//@"en_us",//lang
							[textFieldFirstName text],//@"Rafael",//first_name
							[textFieldLastName text],//@"Gali",//last_name
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
	eDirectoryConnection = [[[NSURLConnection alloc] initWithRequest:eDirectoryURLRequest delegate:self] autorelease];	
	
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
#pragma mark -

- (void)removeAlert
{
    [self.alertView removeFromSuperview];
    self.alertView.alpha = 1.0;
}

-(void)didSelectLocation:(id)sender 
{
	[UIView beginAnimations:@"PickerTransition" context:nil];
	[UIView setAnimationDuration:0.3];
	
	if (sender == nil) {
		self.pickerLocation.frame = CGRectMake(0, 0, 320, 216);
		self.viewPicker.frame = kViewPickerOnScreen;
		[self addBarButtonDone];
	} else {
		self.pickerLocation.frame = CGRectMake(0, 0, 320, 216);
		self.viewPicker.frame = kViewPickerOffScreen;
	}

	[UIView commitAnimations];
}

-(void) addBarButtonDone
{
	UIBarButtonItem *buttonRight = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DoneButton", @"") style:UIBarButtonItemStyleDone target:self action:@selector(locationSelected:)];      \
	self.navigationItem.rightBarButtonItem = buttonRight;                                                                                                               \
	[buttonRight release];
}


- (void) locationSelected:(id)sender {

	[buttonLanguage setTitle:[dic objectForKey:[[dic allKeys] objectAtIndex:[pickerLocation  selectedRowInComponent:0]]]  forState:UIControlStateNormal];
	[buttonLanguage setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	self.navigationItem.rightBarButtonItem = nil;
	[self didSelectLocation:sender];
	
}

-(IBAction)hideKeyboard:(UIButton *)sender {
	[self resignFirstResponder];
}

-(IBAction)languageButtonPressed:(UIButton *)sender
{
	[self didSelectLocation:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
	return 30;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return NSLocalizedString(@"AddProfileHeader", @"");
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	UITableViewCell *cell = nil;
	
	switch (indexPath.row) {
		case 0:
			cell = tableViewCellFirstName;
			break;
		case 1:
			cell = tableViewCellLastName;
			break;
		case 2:
			cell = tableViewCellEmail;
			break;
		case 3:
			cell = tableViewCellPassword;
			break;
		case 4:
			cell = tableViewCellRetypePassword;
			break;
		case 5:
			cell = tableViewCellLanguage;
			break;
		default:
			break;
	}
	return cell;
}

#pragma mark -
#pragma mark UIPickerViewDataSource

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{	
	//return [pickerViewArray objectAtIndex:row];
	if (dic != nil)
		return [dic objectForKey:[[dic allKeys] objectAtIndex:row]];
	else 
		return @"";

}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	//return [pickerViewArray count];
	return [dic count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	profile = [[ProfileContact alloc] init];
	dic = [[NSMutableDictionary alloc] init];
	
	//[dic setObject:@"English"   forKey:@"en_us"];
	//[dic setObject:@"Português" forKey:@"pt_br"];
	//[dic setObject:@"Español"   forKey:@"es_es"];
	//[dic setObject:@"Français"	forKey:@"fr_fr"];
	//[dic setObject:@"Italiano"  forKey:@"it_it"];
	//[dic setObject:@"Deutsch"   forKey:@"ge_ge"];
	
	isLanguageParser = YES;
	
	//LANGUAGES
	NSString            *path =                 [[NSBundle mainBundle] pathForResource:@"ConnectionStrings" ofType:@"plist"];		
	NSDictionary        *connPlist =            [NSDictionary dictionaryWithContentsOfFile:path];
	NSString            *url =                  [connPlist objectForKey:@"Languages"];
	NSString            *userAgent =            @"Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en)";
	NSMutableURLRequest *eDirectoryURLRequest = [[[NSMutableURLRequest alloc] init] autorelease];
	
	[eDirectoryURLRequest setURL: [NSURL URLWithString:url]];
	[eDirectoryURLRequest setValue:userAgent forHTTPHeaderField:@"User-Agent"];
	eDirectoryConnection = [[[NSURLConnection alloc] initWithRequest:eDirectoryURLRequest delegate:self] autorelease];
	
	
	[privacyPolicyLabel setText:NSLocalizedString(@"PrivacyPolicy", @"")];
    [signUpButton setTitle:NSLocalizedString(@"SignUpButton", @"") forState:UIControlStateNormal];
    
 
    [textFieldFirstName setPlaceholder:NSLocalizedString(@"FirstName", @"")];
    [textFieldLastName setPlaceholder:NSLocalizedString(@"LastName", @"")];
    [textFieldPassword setPlaceholder:NSLocalizedString(@"Password", @"")];
    [textFieldRetypePassword setPlaceholder:NSLocalizedString(@"RetypePassword", @"")];
    [textFieldEmail setPlaceholder:NSLocalizedString(@"Email", @"")];
    [buttonLanguage setTitle:NSLocalizedString(@"SelectLanguage", @"") forState:UIControlStateNormal] ;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	self.alertView = nil;
    self.alertLabel = nil;
    [privacyPolicyLabel release];
    privacyPolicyLabel = nil;
    [signUpButton release];
    signUpButton = nil;
	[super viewDidUnload];
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

	
	if (isLanguageParser == YES) 
	{
		isLanguageParser = NO;
		return;
	}
	
	if (validate == NO)
	{
		[self performSelector:@selector(finalUpdate) withObject:nil afterDelay:0.0];

		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle:nil
							  message: [self authMessage]
							  delegate:nil 
							  cancelButtonTitle:NSLocalizedString(@"OK", @"")
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
		[[self delegate] addProfileDidNotLogin];
	
	} else {
		
		LoginData *login = [[LoginData alloc] init];
		[login setProfile:profile];
		[login saveProfileData];
		[login release];
		
		[self performSelector:@selector(finalUpdate) withObject:nil afterDelay:0.0];
		
		[[self delegate] addProfileDidLogin];
		
	}

}

- (void)handleError:(NSError *)error {
    NSString *errorMessage = [error localizedDescription];
	
//	NSLog(@"%@", errorMessage);
//	NSLog(@"%@", NSLocalizedString(@"Downloading Error", @"Title for alert displayed when download or parse error occurs.") );
	
	
    UIAlertView *alertErrorView = [[UIAlertView alloc] 
								   initWithTitle:NSLocalizedString(@"Downloading Error", @"Title for alert displayed when download or parse error occurs.") 
								   message:errorMessage 
								   delegate:nil
								   cancelButtonTitle:NSLocalizedString(@"OK", @"")
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
	if (isLanguageParser && [elementName isEqualToString:@"entry_language"]) 
	{
		[dic setObject:languageName forKey:languageID];
	}
	
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	
	
	if ([currentItem isEqualToString:@"message"]) 
	{
		//authMessage = string;
		[self setAuthMessage:string];
	} else if ([currentItem isEqualToString:@"validate"]) {
        validate = [string boolValue] ? YES : NO ;
	} else if ([currentItem isEqualToString:@"authmessage"]) {
		[self setAuthMessage:string];
		//authMessage = string;
	} else if ([currentItem isEqualToString:@"id"]) {
		[profile setProfileID:[NSNumber numberWithInt:[string intValue]]];
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
	} else if ([currentItem isEqualToString:@"language_id"]) {
		[self setLanguageID:string];
	} else if ([currentItem isEqualToString:@"language_name"]) {
		[self setLanguageName:string];
	}
	
}
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
}

- (void)parserDidEndDocument:(NSXMLParser *)parser{
	
	//NSLog(@"didEndDocument: isLanguageParser: %@", isLanguageParser);
	
	if (isLanguageParser == YES) {
		[pickerLocation reloadComponent:0];
	}
	
}

- (void)parserDidEndParsingData:(NSArray *)objectResults{
}


@end