//
//  NSDate+Extras.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/24/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "NSDate+Extras.h"

@implementation NSDate (Extras)

- (BOOL)dateInSameYear:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy"];
    int year = [[dateFormatter stringFromDate:self] intValue];
    int compareYear = [[dateFormatter stringFromDate:date] intValue];
    return year == compareYear;
}

@end
