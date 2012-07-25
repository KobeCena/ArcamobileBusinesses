//
//  FacebookLogin.h
//  eDirectory
//
//  Created by Rafael Gustavo Gali on 04/10/10.
//  Copyright 2010 Arca Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"
#import "FBLoginDialog.h"
#import "FacebookProfileContact.h"
#import "LoginData.h"

@protocol FacebookLoginDelegate;

@interface FacebookLogin : NSObject <FBRequestDelegate, FBDialogDelegate, FBSessionDelegate>{
	Facebook                   *_facebook;
	NSArray					   *_permissions;
	id<FacebookLoginDelegate>   delegate;
	FacebookProfileContact     *facebookProfile;
	BOOL                        login;
}

@property (nonatomic, assign)    id<FacebookLoginDelegate> delegate;
@property (nonatomic, retain)    FacebookProfileContact *facebookProfile;
@property (nonatomic, readwrite) BOOL login;

-(void)logout;

-(id)initWithAuthorize;

@end


@protocol FacebookLoginDelegate <NSObject>
	-(void)facebookDidLogin;
	-(void)facebookDidNotLogin;
	-(void)facebookRequestReturn;
@end
