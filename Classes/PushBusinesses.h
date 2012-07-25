//
//  FavoriteBusiness.h
//  ArcaMobileDeals
//
//  Created by Ricardo Silva on 6/14/11.
//  Copyright (c) 2011 Arca Solutions Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PushBusinesses : NSManagedObject 

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSDate   * dateRecorded;
@property (nonatomic, retain) NSNumber * businessId;
@property (nonatomic, retain) NSString * title;


@end
