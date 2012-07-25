//
//  City.h
//  Gayborhood
//
//  Created by Roberto on 05/08/10.
//  Copyright 2010 Arca Solutions. All rights reserved.
//

#import <CoreData/CoreData.h>

@class State;

@interface City :  NSManagedObject  
{
	
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * city_id;
@property (nonatomic, retain) State * state;

@end



