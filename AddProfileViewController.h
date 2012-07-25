//
//  AddProfileViewController.h
//  eDirectory
//
//  Created by Rafael Gustavo Gali on 29/09/10.
//  Copyright 2010 Arca Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Listing.h"
#import "ProfileContact.h"
#import "LoginData.h"

@protocol addProfileDelegate;

@interface AddProfileViewController : UIViewController  {
	id<addProfileDelegate>    delegate;
	IBOutlet UITableViewCell *tableViewCellFirstName;
	IBOutlet UITextField     *textFieldFirstName;
	IBOutlet UITableViewCell *tableViewCellLastName;
	IBOutlet UITextField     *textFieldLastName;
	IBOutlet UITableViewCell *tableViewCellEmail;
	IBOutlet UITextField     *textFieldEmail;
	IBOutlet UITableViewCell *tableViewCellPassword;
	IBOutlet UITextField     *textFieldPassword;
	IBOutlet UITableViewCell *tableViewCellRetypePassword;
	IBOutlet UITextField     *textFieldRetypePassword;
	IBOutlet UITableViewCell *tableViewCellLanguage;
	IBOutlet UIButton        *buttonLanguage;
	UIView					 *viewPicker;
	UIPickerView			 *pickerLocation;
	ProfileContact			 *profile;
	Listing					 *list;
	NSString				 *currentItem;
	NSString				 *authMessage;
	BOOL					  validate;
	NSURLConnection			 *eDirectoryConnection;
    NSMutableData			 *eDirectoryData;
	NSMutableDictionary		 *dic;
	UIView                   *alertView;
    UILabel                  *alertLabel;
	BOOL	                  isLanguageParser;
	NSString                 *languageID;
	NSString                 *languageName;
    
    
    IBOutlet UILabel *privacyPolicyLabel;
    IBOutlet UIButton *signUpButton;
    
    
}


@property (nonatomic, retain) NSString *languageID;
@property (nonatomic, retain) NSString *languageName;

@property (nonatomic, assign) id<addProfileDelegate> delegate;

@property (nonatomic, retain) ProfileContact        *profile;

@property (nonatomic, retain) IBOutlet UIView       *alertView;
@property (nonatomic, retain) IBOutlet UILabel      *alertLabel;

@property (nonatomic, retain) Listing *list;
@property (nonatomic, retain) IBOutlet UIPickerView *pickerLocation;
@property (nonatomic, retain) IBOutlet UIView       *viewPicker;

@property (nonatomic, retain) NSURLConnection       *eDirectoryConnection;
@property (nonatomic, retain) NSMutableData         *eDirectoryData;

@property (nonatomic, retain) UITableViewCell       *tableViewCellFirstName;
@property (nonatomic, retain) UITextField           *textFieldFirstName;

@property (nonatomic, retain) UITableViewCell       *tableViewCellLastName;
@property (nonatomic, retain) UITextField           *textFieldLastName;

@property (nonatomic, retain) UITableViewCell       *tableViewCellEmail;
@property (nonatomic, retain) UITextField           *textFieldEmail;

@property (nonatomic, retain) UITableViewCell       *tableViewCellPassword;
@property (nonatomic, retain) UITextField           *textFieldPassword;

@property (nonatomic, retain) UITableViewCell       *tableViewCellRetypePassword;
@property (nonatomic, retain) UITextField           *textFieldRetypePassword;

@property (nonatomic, retain) UITableViewCell       *tableViewCellLanguage;
@property (nonatomic, retain) UIButton              *buttonLanguage;

@property (nonatomic, retain) NSString              *currentItem;
@property (nonatomic, retain) NSString              *authMessage;

-(IBAction)hideKeyboard:(UIButton *)sender;
-(IBAction)languageButtonPressed:(UIButton *)sender;

-(void) didSelectLocation:(id)sender;
-(void) addBarButtonDone;
-(void) locationSelected:(id)sender;
-(IBAction)signupButtonPressed:(id)sender;

- (void)updateText:(NSString *)newText;
- (void)finalUpdate;
- (void)removeAlert;

- (void)handleError:(NSError *)error;

@end

@protocol addProfileDelegate<NSObject>
	-(void)addProfileDidLogin;
	-(void)addProfileDidNotLogin;
@end

