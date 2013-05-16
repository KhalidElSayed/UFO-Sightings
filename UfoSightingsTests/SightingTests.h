//
//  SightingTests.h
//  UfoSightings
//
//  Created by Richard Kirk on 5/7/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "UFOSighting.h"

@interface SightingTests : SenTestCase
{
    NSManagedObjectModel*           model;
    NSPersistentStoreCoordinator*   coord;
    NSPersistentStore*              store;
    NSManagedObjectContext*         context;
    
}
@end
