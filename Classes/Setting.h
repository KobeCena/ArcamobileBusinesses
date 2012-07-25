//
//  Setting.h
//  Gayborhood
//
//  Created by Roberto on 05/08/10.
//  Copyright 2010 Arca Solutions. All rights reserved.
//

#import <CoreData/CoreData.h>

@class City;

@interface Setting : NSManagedObject  
{
	
}

@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSNumber * isNearMe;
@property (nonatomic, retain) NSNumber * isOnlyDeals;
@property (nonatomic, retain) NSString * zipCode;
@property (nonatomic, retain) City * city;

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;

@end



