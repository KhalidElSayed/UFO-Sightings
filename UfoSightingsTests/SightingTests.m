//
//  SightingTests.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/7/12.
//  Copyright (c) 2012 Home. All rights reserved.
//


#import "Sighting.h"
#import "SightingLocation.h"
#import "UFOBaseTestCase.h"
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "Sighting.h"

@interface SightingTests : UFOBaseTestCase
{
    
}
@end

@implementation SightingTests

- (void)setUp
{
    [super setUp];
}

- (void)testSightingLocationCoordinate
{
    NSFetchRequest* fetch = [[NSFetchRequest alloc]initWithEntityName:@"SightingLocation"];
    fetch.fetchLimit = 1;
    
    NSError* error;
    NSArray* result = [self.defaultManagedObjectContext  executeFetchRequest:fetch error:&error];
    STAssertNil(error, @"Fetch Request Error");
    
    SightingLocation* location = [result lastObject];
        
    CLLocationCoordinate2D orginalCoordinate = location.coordinate;
    CLLocationCoordinate2D testCoordinate = CLLocationCoordinate2DMake(11.00239, -43.23421);
    
//    STAssertTrue((orginalCoordinate.latitude == testCoordinate.latitude && orginalCoordinate.longitude == testCoordinate.longitude), @"orignial doesn't match");
    
    CLLocationCoordinate2D newCoordinate = CLLocationCoordinate2DMake(43.456, -31.123);
    
    location.coordinate = newCoordinate;
    
//    STAssertTrue((location.coordinate.latitude == newCoordinate.latitude && location.coordinate.longitude == newCoordinate.longitude), @"not saving coordinate correctly");
}



@end
