//
//  State.h
//  Gayborhood
//
//  Created by Roberto on 05/08/10.
//  Copyright 2010 Arca Solutions. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Country;

@interface State :  NSManagedObject  
{
	
}

@property (nonatomic, retain) NSString * abbreviation;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * state_id;
@property (nonatomic, retain) Country * country;

@end



