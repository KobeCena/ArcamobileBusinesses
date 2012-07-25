//
//  UserAuthenticationController.h
//  eDirectory
//
//  Created by Ricardo Silva on 3/25/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProfileContact.h"

@interface UserAuthenticationController : NSObject <NSXMLParserDelegate>{

    ProfileContact             *profile;
    NSString                   *userPassword;
	NSURLConnection            *eDirectoryConnection;
    NSMutableData              *eDirectoryData;    
	BOOL                        authenticateAccount;
 	NSString                   *currentItem;
	NSString                   *authMessage;
}

-(void)startAuthenticationPhaseWithCredentials:(ProfileContact *)profileData usingPassword:(NSString *) password;

@property(nonatomic, retain) NSString           *userPassword;
@property(nonatomic, retain) ProfileContact     *profile;
@property(nonatomic, retain) NSURLConnection    *eDirectoryConnection;
@property(nonatomic, retain) NSMutableData      *eDirectoryData;
@property(nonatomic, retain) NSString           *currentItem;
@property(nonatomic, retain) NSString           *authMessage;
@end
