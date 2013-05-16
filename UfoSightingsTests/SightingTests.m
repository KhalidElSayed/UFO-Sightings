//
//  SightingTests.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/7/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import "SightingTests.h"
#import "Sighting.h"
#import "SightingLocation.h"
#import "UFOAppDelegate.h"

@implementation SightingTests
- (void)setUp
{
    //NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"UfoSightings" withExtension:@"momd"];
  
   // model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    UFOAppDelegate* ad = [[UFOAppDelegate alloc]init];
    
    model = [ad managedObjectModel];
 
    
    STAssertNotNil(model,nil);
    coord = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: model];
    store = [coord addPersistentStoreWithType: NSInMemoryStoreType
                                configuration: nil
                                          URL: nil
                                      options: nil
                                        error: NULL];
    context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator: coord];

    
    Sighting* sighting = [NSEntityDescription insertNewObjectForEntityForName:@"Sighting" inManagedObjectContext:context];
    sighting.report = @"";
    sighting.duration = @"";
    sighting.reportedAt = [NSDate date];
    sighting.sightedAt = [NSDate date];
    
    
    SightingLocation* location = [NSEntityDescription insertNewObjectForEntityForName:@"SightingLocation" inManagedObjectContext:context];
    location.lat = [NSNumber numberWithDouble:11.00239];
    location.lng = [NSNumber numberWithDouble:-43.23421];
    location.formattedAddress = @"Miami, FL";
    
    sighting.location = location;
    
    NSError* error;
    
    [context save:&error];
    
    STAssertNil(error, @"Core data didn't save properly");

}

- (void)testSightingLocationCoordinate
{
    
    NSFetchRequest* fetch = [[NSFetchRequest alloc]initWithEntityName:@"SightingLocation"];
    fetch.fetchLimit = 1;
    
    NSError* error;
    NSArray* result = [context executeFetchRequest:fetch error:&error];
    STAssertNil(error, @"Fetch Request Error");
    
    SightingLocation* location = [result lastObject];
        
    CLLocationCoordinate2D orginalCoordinate = location.coordinate;
    CLLocationCoordinate2D testCoordinate = CLLocationCoordinate2DMake(11.00239, -43.23421);
        
    
    STAssertTrue((orginalCoordinate.latitude == testCoordinate.latitude && orginalCoordinate.longitude == testCoordinate.longitude), @"orignial doesn't match");
    
    CLLocationCoordinate2D newCoordinate = CLLocationCoordinate2DMake(43.456, -31.123);
    
    location.coordinate = newCoordinate;
    
    STAssertTrue((location.coordinate.latitude == newCoordinate.latitude && location.coordinate.longitude == newCoordinate.longitude), @"not saving coordinate correctly");

    
    
}


- (void)tearDown
{
    
    context = nil;
    NSError *error = nil;
    STAssertTrue([coord removePersistentStore: store error: &error],
                 @"couldn't remove persistent store: %@", error);
    store = nil;
    coord = nil;
    model = nil;
}

@end
