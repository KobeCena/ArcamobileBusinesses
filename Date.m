//
//  Date.m
//  eDirectory
//
//  Created by Rafael Gustavo Gali on 07/12/10.
//  Copyright 2010 Arca Solutions. All rights reserved.
//

#import "Date.h"


@implementation Date

+ (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate
{
    if ([date compare:beginDate] == NSOrderedAscending)
        return NO;
	
    if ([date compare:endDate] == NSOrderedDescending) 
        return NO;
	
    return YES;
}

+ (int) minutesSinceMidnight:(NSDate *)date
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned unitFlags =  NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSDateComponents *components = [gregorian components:unitFlags fromDate:date];
	[gregorian release];
    return 60 * [components hour] + [components minute];    
}


@end
