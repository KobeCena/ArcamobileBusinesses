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

#import "Listing.h"


@implementation Listing


@synthesize latitude;
@synthesize longitude;
@synthesize listingTitle;
@synthesize rawAddress;
@synthesize address;

@synthesize listingID;
@synthesize level;
@synthesize regionID;	
@synthesize regionName;
@synthesize rateAvg;
@synthesize reviewAmount;
@synthesize zipCode;
@synthesize phone;
@synthesize email;
@synthesize url;
@synthesize mapTunning;
@synthesize description;
@synthesize listingIcon;
@synthesize listingIconDetail;
@synthesize imageURLString;
@synthesize category;
@synthesize hasDetail;
@synthesize allowReview;




-(void)dealloc{
	[listingTitle         release];
	[rawAddress           release];
	[address              release];
	[regionName           release];
	[zipCode              release];
	[phone                release];
	[email                release];
	[url                  release];
	[mapTunning           release];
	[description          release];
	[listingIcon          release];
	[listingIconDetail    release];
	[imageURLString       release];
	[category             release];	
	[super                dealloc];
}


- (CLLocationCoordinate2D)coordinate;
{
	
    BOOL emptyMaptuning = FALSE;
	
	if([[self mapTunning] length]>0){
		
		
		
		NSArray *listingMapTunnig = [self.mapTunning componentsSeparatedByString: @","];
		
        if ([listingMapTunnig count]>1) {
            double maptunningLatitude = [(NSString *)[listingMapTunnig objectAtIndex:0] doubleValue];
            double maptunningLongitude = [(NSString *)[listingMapTunnig objectAtIndex:1] doubleValue];;
            
            self.latitude = maptunningLatitude;
            self.longitude = maptunningLongitude;
        }else{
            emptyMaptuning = TRUE;
        }

	}

	if (emptyMaptuning) {
        coordinate.latitude = 0.0f;
        coordinate.longitude = 0.0f;
    }else{
        coordinate.latitude = self.latitude;
        coordinate.longitude = self.longitude;
    }
    
	
    return coordinate;
}

// required if you set the MKPinAnnotationView's "canShowCallout" property to YES
- (NSString *)title
{
    return [self listingTitle];
}

-(BOOL)isShowCase {
	return (level == 70); 
}

@end
