//
//  UFOFilterManager.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/26/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "UFOFilterManager.h"
#import <SenTestingKit/SenTestingKit.h>
#import "NSFileManager+Extras.h"

@interface UFOFilterManager ()
@property (strong, nonatomic) NSMutableDictionary* filterDictionary;
@end

@interface UFOFilterManagerTest : SenTestCase
{
    UFOFilterManager* filterManager;
    NSDictionary* filterDictionary;
}
@end

@implementation UFOFilterManagerTest

-(void)setUp
{
    filterManager = [[UFOFilterManager alloc]init];

    filterDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"filters" ofType:@"plist"]];
    filterManager.filterDictionary = [filterDictionary mutableCopy];
    
}


- (void)testDefaultReportedAtMinimumDate
{
    NSDate* defaultValue = [filterManager defaultReportedAtMinimumDate];
    NSDate* correctValue = [filterDictionary objectForKey:@"reportedAtMinimumDate"];
    STAssertEqualObjects(defaultValue, correctValue, @"The default reported at minimum doesnt match output");
}


- (void)testDefaultReportedAtMaximumDate
{
    NSDate* defaultValue = [filterManager defaultReportedAtMaximumDate];
    NSDate* correctValue = [filterDictionary objectForKey:@"reportedAtMaximumDate"];
    STAssertEqualObjects(defaultValue, correctValue, @"The default reported at maximum doesnt match output");
}


- (void)testDefaultSightedAtMinimumDate
{
    NSDate* defaultValue = [filterManager defaultSightedAtMinimumDate];
    NSDate* correctValue = [filterDictionary objectForKey:@"sightedAtMinimumDate"];
    STAssertEqualObjects(defaultValue, correctValue, @"The default sighted at minimum doesnt match output");
}


- (void)testDefaultSightedAtMaximumDate
{
    NSDate* defaultValue = [filterManager defaultSightedAtMaximumDate];
    NSDate* correctValue = [filterDictionary objectForKey:@"sightedAtMaximumDate"];
    STAssertEqualObjects(defaultValue, correctValue, @"The default sighted at maximum doesnt match output");
}



@end
