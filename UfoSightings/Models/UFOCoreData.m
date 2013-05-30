//
//  UFOCoreData.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/16/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "UFOCoreData.h"
#import "NSFileManager+Extras.h"
#define LOG_FETCH_ERRORS YES

static dispatch_queue_t coredata_background_queue;
dispatch_queue_t CDbackground_queue()
{
    if (coredata_background_queue == NULL) {
        coredata_background_queue = dispatch_queue_create("com.richardKirk.coredata.backgroundfetches", DISPATCH_QUEUE_SERIAL);
    }
    return coredata_background_queue;
}

@implementation UFOCoreData

+ ( UFOCoreData * ) sharedInstance {
    
    static UFOCoreData * privateInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        privateInstance = [ [ UFOCoreData alloc ] init ];
        
        NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
        [ dnc addObserver: privateInstance
                 selector: @selector( mergeContexts: )
                     name: NSManagedObjectContextDidSaveNotification
                   object: nil ];
    });
    return privateInstance;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)resetContext
{
    _managedObjectContext = nil;
    _persistentStoreCoordinator = nil;
    [self managedObjectContext];
}


// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- ( NSManagedObjectContext * ) managedObjectContext
{
    @synchronized(self) {
        if(_managedObjectContext != nil) {
            return _managedObjectContext;
        }
        _managedObjectContext = [self createManagedObjectContext];
    }
    
    return _managedObjectContext;
}


- (NSManagedObjectContext*)backgroundContext
{
    @synchronized(self){
        if(_backgroundContext != nil) {
            return _backgroundContext;
        }
        _backgroundContext = [self createManagedObjectContext];
    }
    return _backgroundContext;
}


// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- ( NSManagedObjectModel * ) managedObjectModel {
    @synchronized( self ) {
        if ( _managedObjectModel != nil ) {
            return _managedObjectModel;
        }
        
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"UfoSightings" withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _managedObjectModel;
}


// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (!_persistentStoreCoordinator) {
        NSURL *storeURL = [[[NSFileManager defaultManager] applicationDocumentsDirectory] URLByAppendingPathComponent:@"UfoSightings.sqlite"];
        
        NSError *error = nil;
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext*)createManagedObjectContext
{
    NSManagedObjectContext* context = nil;
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:coordinator];
    }
    return context;
}


- (void)executeFetchRequest:(NSFetchRequest*)request onBackgroundContextWithFinised:(UFOCoreDataSuccessBlock)success andFailed:(UFOCoreDataFailedBlock)failed
{
    dispatch_async(CDbackground_queue(), ^{
        NSError* error = nil;
        [request setResultType:NSManagedObjectIDResultType];
        
        NSArray* results = [self.backgroundContext executeFetchRequest:request error:&error];
        if (error && failed) {
            if(LOG_FETCH_ERRORS) { NSLog(@"%@",error); }
            dispatch_sync(dispatch_get_main_queue(), ^{
                failed(error);
            });
        }
        else if(results && success) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                success(results);
            });
        }
    });
}


- (NSDate*)highestReportedAtDate
{
    NSFetchRequest* req = [NSFetchRequest fetchRequestWithEntityName:@"Sighting"];
    [req setResultType:NSDictionaryResultType];
    NSExpression* expression = [NSExpression expressionForKeyPath:@"reportedAt"];
    NSExpression *maxSalaryExpression = [NSExpression expressionForFunction:@"max:"
                                                                  arguments:[NSArray arrayWithObject:expression]];
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName:@"maxReportedAt"];
    [expressionDescription setExpression:maxSalaryExpression];
    [expressionDescription setExpressionResultType:NSDateAttributeType];
    [req setPropertiesToFetch:@[expressionDescription]];
    
    NSDictionary* dict = (NSDictionary*)[self.managedObjectContext executeFetchRequest:req error:nil];
    
    return [[dict valueForKey:@"maxReportedAt"] lastObject];
}


- (NSDate*)lowestReportedDate
{
    NSFetchRequest* req = [NSFetchRequest fetchRequestWithEntityName:@"Sighting"];
    [req setResultType:NSDictionaryResultType];
    NSExpression* expression = [NSExpression expressionForKeyPath:@"reportedAt"];
    NSExpression *maxSalaryExpression = [NSExpression expressionForFunction:@"min:"
                                                                  arguments:[NSArray arrayWithObject:expression]];
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName:@"minReportedAt"];
    [expressionDescription setExpression:maxSalaryExpression];
    [expressionDescription setExpressionResultType:NSDateAttributeType];
    [req setPropertiesToFetch:@[expressionDescription]];
    
    NSDictionary* dict = (NSDictionary*)[self.managedObjectContext executeFetchRequest:req error:nil];
    
    return [[dict valueForKey:@"minReportedAt"] lastObject];
}


- (NSDate*)highestSightedAtDate
{
    NSFetchRequest* req = [NSFetchRequest fetchRequestWithEntityName:@"Sighting"];
    [req setResultType:NSDictionaryResultType];
    NSExpression* expression = [NSExpression expressionForKeyPath:@"sightedAt"];
    NSExpression *maxSalaryExpression = [NSExpression expressionForFunction:@"max:"
                                                                  arguments:[NSArray arrayWithObject:expression]];
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName:@"maxSightedAt"];
    [expressionDescription setExpression:maxSalaryExpression];
    [expressionDescription setExpressionResultType:NSDateAttributeType];
    [req setPropertiesToFetch:@[expressionDescription]];
    
    NSDictionary* dict = (NSDictionary*)[self.managedObjectContext executeFetchRequest:req error:nil];
    
    return [[dict valueForKey:@"maxSightedAt"] lastObject];
}



- (NSDate*)lowestSightedAtDate
{
    NSFetchRequest* req = [NSFetchRequest fetchRequestWithEntityName:@"Sighting"];
    [req setResultType:NSDictionaryResultType];
    NSExpression* expression = [NSExpression expressionForKeyPath:@"sightedAt"];
    NSExpression *maxSalaryExpression = [NSExpression expressionForFunction:@"min:"
                                                                  arguments:[NSArray arrayWithObject:expression]];
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName:@"minSightedAt"];
    [expressionDescription setExpression:maxSalaryExpression];
    [expressionDescription setExpressionResultType:NSDateAttributeType];
    [req setPropertiesToFetch:@[expressionDescription]];
    
    NSDictionary* dict = (NSDictionary*)[self.managedObjectContext executeFetchRequest:req error:nil];
    
    return [[dict valueForKey:@"minSightedAt"] lastObject];
}

@end
