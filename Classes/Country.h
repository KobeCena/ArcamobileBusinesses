//
//  Country.h
//  Gayborhood
//
//  Created by Roberto on 05/08/10.
//  Copyright 2010 Arca Solutions. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Country :  NSManagedObject  
{
	
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * country_id;

@end



