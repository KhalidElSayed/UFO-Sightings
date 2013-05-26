//
//  UFOCoreData+UnitTests.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/26/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "UFOCoreData+UnitTests.h"

@implementation UFOCoreData (UnitTests)


// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (!_persistentStoreCoordinator) {
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    }
    return _persistentStoreCoordinator;
}



@end
