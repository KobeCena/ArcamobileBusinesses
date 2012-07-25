//
//  ReviewsPosted.h
//  ArcaMobileBusinesses
//
//  Created by Ricardo Silva on 9/8/11.
//  Copyright 2011 Arca Solutions Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ReviewsPosted :  NSManagedObject {
    
}

@property (nonatomic, retain) NSNumber * ReviewPostID;
@property (nonatomic, retain) NSNumber * BusinessID;
@property (nonatomic, retain) NSNumber * ReviewNote;
@property (nonatomic, retain) NSDate * DateRecorded;



@end
