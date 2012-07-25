/*
 ######################################################################
 #                                                                    #
 # Copyright 2005 Arca Solutions, Inc. All Rights Reserved.           #
 #                                                                    #
 # This file may not be redistributed in whole or part.               #
 # eDirectory is licensed on a per-domain basis.                      #
 #                                                                    #
 # ---------------- eDirectory IS NOT FREE SOFTWARE ----------------- #
 #                                                                    #
 # http://www.edirectory.com | http://www.edirectory.com/license.html #
 ######################################################################
 
 ClassDescription:
 Author:
 Since:
 */

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol ListingObjectDelegate <NSObject>

@required
-(UIImage *) listingIcon;
-(UIImage *) listingIconDetail;
-(NSString *) imageURLString;

-(void) setListingIcon:(UIImage  *) image;
-(void) setListingIconDetail:(UIImage  *) image;
-(void) setImageURLString:(NSString *) string;


@end

@interface Listing : NSObject <MKAnnotation>{
	NSString               *listingTitle;
	NSString               *rawAddress;
	NSString               *address;
	double                  latitude;
	double                  longitude;
	NSInteger               listingID;
	int                     level;
	BOOL                    hasDetail;
	NSInteger               regionID;	
	NSString               *regionName;
	double                  rateAvg;
	double                  reviewAmount;
	NSString               *zipCode;
	NSString               *phone;
	NSString               *email;
	NSString               *url;
	NSString               *mapTunning;
	NSString               *description;
	UIImage                *listingIcon;
	UIImage                *listingIconDetail;
	NSString               *imageURLString;
	NSString               *category;
	BOOL                    allowReview;
	CLLocationCoordinate2D  coordinate;
	
}

@property (nonatomic, retain) NSString *listingTitle;
@property (nonatomic, retain) NSString *rawAddress;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

@property (nonatomic, assign) NSInteger listingID;
@property (nonatomic, assign) NSInteger regionID;
@property (nonatomic, assign) int level;
@property (nonatomic, retain) NSString *regionName;
@property (nonatomic, assign) double rateAvg;
@property (nonatomic, assign) double reviewAmount;
@property (nonatomic, retain) NSString *zipCode;
@property (nonatomic, retain) NSString *phone;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *mapTunning;
@property (nonatomic, retain) NSString *description;

@property (nonatomic, retain) UIImage *listingIcon;
@property (nonatomic, retain) UIImage *listingIconDetail;
@property (nonatomic, retain) NSString *imageURLString;
@property (nonatomic, retain) NSString *category;

@property (nonatomic, assign) BOOL hasDetail;

@property (nonatomic, assign) BOOL allowReview;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (BOOL)isShowCase;

@end
