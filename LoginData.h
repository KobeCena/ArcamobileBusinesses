//
//  LoginData.h
//  eDirectory
//
//  Created by Rafael Gustavo Gali on 20/10/10.
//  Copyright 2010 Arca Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProfileContact.h"
#import "FacebookProfileContact.h"

#define kFilename         @"login.plist"
#define kFilenameFacebook @"facebookLogin.plist"

@interface LoginData : NSObject {
	ProfileContact         *profile;
	FacebookProfileContact *facebookProfile;
	BOOL			        profileExist;
	BOOL			        facebookProfileExist;
}

@property (nonatomic, retain) ProfileContact         *profile;
@property (nonatomic, retain) FacebookProfileContact *facebookProfile;
@property (nonatomic, assign) BOOL                    profileExist;
@property (nonatomic, assign) BOOL                    facebookProfileExist;

- (NSString *)dataFilePath:(NSString *)fileName;

- (void)saveProfileData;
- (void)saveFacebookProfileData;
- (void)logoutProfile;
- (void)logoutFacebookProfile;

@end
