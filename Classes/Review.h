//
//  Review.h
//  eDirectory
//
//  Created by Rafael Gustavo Gali on 19/10/10.
//  Copyright 2010 Arca Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Review : NSObject {
	int		  reviewID;
	int       item_id;
	int       member_id;
	NSDate   *added;
	NSString *ip;
	NSString *title;
	NSString *review;
	NSString *reviewerName;
	NSString *reviewerEmail;
	NSString *reviewerLocation;
	int       rate;

}

@property (nonatomic, assign) int       reviewID;
@property (nonatomic, assign) int       item_id;
@property (nonatomic, assign) int       member_id;
@property (nonatomic, retain) NSDate   *added;
@property (nonatomic, retain) NSString *ip;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *review;
@property (nonatomic, retain) NSString *reviewerName;
@property (nonatomic, retain) NSString *reviewerEmail;
@property (nonatomic, retain) NSString *reviewerLocation;
@property (nonatomic, assign) int       rate;

@end
