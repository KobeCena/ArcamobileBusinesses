//
//  FavoriteBusiness.h
//  ArcaMobileDeals
//
//  Created by Ricardo Silva on 6/14/11.
//  Copyright (c) 2011 Arca Solutions Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FavoriteBusiness : NSManagedObject {
@private
}

@property (nonatomic, retain) NSDate   * DateRecorded;
@property (nonatomic, retain) NSNumber * BusinessId;
@property (nonatomic, retain) NSString * Title;


@end
