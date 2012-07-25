//
//  LoginViewController.h
//  eDirectory
//
//  Created by Rafael Gustavo Gali on 30/09/10.
//  Copyright 2010 Arca Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Listing.h"
#import "ProfileContact.h"
#import "LoginData.h"
#import "UserAuthenticationController.h"

@protocol eDirectoryLoginDelegate;

@interface LoginViewController : UIViewController   {
	id<eDirectoryLoginDelegate> delegate;

	IBOutlet UITableViewCell   *tableViewCellEmail;
	IBOutlet UITableViewCell   *tableViewCellPassword;
	IBOutlet UITextField       *textFieldEmail;
	IBOutlet UITextField	   *textFieldPassword;
	NSURLConnection            *eDirectoryConnection;
    NSMutableData              *eDirectoryData;
	NSString                   *currentItem;
	NSString                   *authMessage;
	BOOL                        authenticateAccount;
	ProfileContact             *profile;
	Listing                    *list;
    UserAuthenticationController *authController;
    
	UIView                   *alertView;
    UILabel                  *alertLabel;
    
    
    
    
}

@property (nonatomic, assign) id<eDirectoryLoginDelegate> delegate;
@property (nonatomic, retain) Listing         *list;
@property (nonatomic, retain) ProfileContact  *profile;
@property (nonatomic, retain) UITableViewCell *tableViewCellEmail;
@property (nonatomic, retain) UITableViewCell *tableViewCellPassword;
@property (nonatomic, retain) UITextField     *textFieldEmail;
@property (nonatomic, retain) UITextField     *textFieldPassword;
@property (nonatomic, retain) NSURLConnection *eDirectoryConnection;
@property (nonatomic, retain) NSMutableData   *eDirectoryData;
@property (nonatomic, retain) NSString        *currentItem;
@property (nonatomic, retain) NSString        *authMessage;
@property (nonatomic, retain) UserAuthenticationController *authController;

@property (nonatomic, retain) IBOutlet UIView                   *alertView;
@property (nonatomic, retain) IBOutlet UILabel                  *alertLabel;


- (IBAction)hideKeyboard:(id)sender;
- (void)handleError:(NSError *)error;

@end

@protocol eDirectoryLoginDelegate <NSObject>
	//@optional
	-(void)eDirectoryDidLogin;
	-(void)eDirectoryDidNotLogin;
@end