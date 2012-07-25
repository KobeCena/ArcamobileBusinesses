//
//  Review.h
//  eDirectory
//
//  Created by Rafael Gustavo Gali on 19/10/10.
//  Copyright 2010 Arca Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CheckIn: NSObject {
	int		  checkInID;
	int       item_id;
	int       member_id;
	NSDate   *added;
	NSString *ip;
	NSString *quickTip;
	NSString *checkInName;
	NSString *profileImage;
}

@property (nonatomic, assign) int       checkInID;
@property (nonatomic, assign) int       item_id;
@property (nonatomic, assign) int       member_id;
@property (nonatomic, retain) NSDate   *added;
@property (nonatomic, retain) NSString *ip;
@property (nonatomic, retain) NSString *quickTip;
@property (nonatomic, retain) NSString *checkInName;
@property (nonatomic, retain) NSString *profileImage;

@end
