//
//  ProfileContact.h
//  eDirectory
//
//  Created by Rafael Gustavo Gali on 13/10/10.
//  Copyright 2010 Arca Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ProfileContact : NSObject {
	NSNumber *profileID;
	NSString *userName;
	NSString *name;
	NSString *firstName;
	NSString *lastName;
	NSString *email;
	NSString *location;
	NSString *ip;
}

@property (nonatomic, retain) NSNumber *profileID;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *ip;

@end
