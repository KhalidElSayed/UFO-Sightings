//
//  UFOCoreData.h
//  UfoSightings
//
//  Created by Richard Kirk on 5/16/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UFOCoreData : NSObject{
    NSManagedObjectContext * _managedObjectContext;
    NSManagedObjectModel * _managedObjectModel;
    NSPersistentStoreCoordinator * _persistentStoreCoordinator;
}

@property ( nonatomic, strong, readonly ) NSManagedObjectModel *managedObjectModel;
@property ( nonatomic, strong, readonly ) NSManagedObjectContext *managedObjectContext;
@property ( nonatomic, strong, readonly ) NSPersistentStoreCoordinator *persistentStoreCoordinator;


+ ( UFOCoreData * ) sharedInstance;
- (void)saveContext;
- (NSManagedObjectContext*)createManagedObjectContext;

@end
