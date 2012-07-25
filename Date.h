//
//  Date.h
//  eDirectory
//
//  Created by Rafael Gustavo Gali on 07/12/10.
//  Copyright 2010 Arca Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Date : NSObject {

}

+ (int) minutesSinceMidnight:(NSDate *)date;
+ (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate;


@end
