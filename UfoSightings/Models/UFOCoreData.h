//
//  UFOCoreData.h
//  UfoSightings
//
//  Created by Richard Kirk on 5/16/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef void ( ^UFOCoreDataSuccessBlock )( NSArray * objectIDs );
typedef void ( ^UFOCoreDataFailedBlock )( NSError * error );

@interface UFOCoreData : NSObject{
    NSManagedObjectContext * _managedObjectContext;
    NSManagedObjectModel * _managedObjectModel;
    NSPersistentStoreCoordinator * _persistentStoreCoordinator;
}

@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSManagedObjectContext* backgroundContext;



+ ( UFOCoreData * ) sharedInstance;
- (void)saveContext;
- (void)resetContext;
- (NSManagedObjectContext*)createManagedObjectContext;

- (void)executeFetchRequest:(NSFetchRequest*)request onBackgroundContextWithFinised:(UFOCoreDataSuccessBlock)success andFailed:(UFOCoreDataFailedBlock)failed;

- (NSDate*)highestReportedAtDate;
- (NSDate*)lowestReportedDate;

- (NSDate*)highestSightedAtDate;
- (NSDate*)lowestSightedAtDate;



@end
