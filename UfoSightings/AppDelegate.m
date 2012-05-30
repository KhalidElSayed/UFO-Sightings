//
//  AppDelegate.m
//  UfoSightings
//
//  Created by Richard Kirk on 4/28/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#define GENERATE_SEED_DB YES
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#import "AppDelegate.h"
#import <dispatch/dispatch.h>
#import "SightingsParser.h"


@implementation AppDelegate

@synthesize window = _window;
@synthesize rootViewController = _rootViewController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
/*
    SightingsParser* parser = [[SightingsParser alloc] init];
    parser.managedObjectContext = __managedObjectContext;
    [parser createDatabase];
    
 */
    
    
      if(![[NSUserDefaults standardUserDefaults] objectForKey:@"firstRun"])
    {
        [self setupDefaults];
    }
    //[self setupDefaults];
    
   
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.rootViewController = [[RootController alloc]initWithManagedObjectContext:self.managedObjectContext];

   
    //self.rootViewController = [[RootViewController alloc] init];
    //self.rootViewController.managedObjectContext = self.managedObjectContext;
    self.window.rootViewController = self.rootViewController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}






- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
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

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"UfoSightings" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"UfoSightings.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(void)setupDefaults
{
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"firstRun"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"mapType"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"heatMapOverlayOn"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"annotationsOn"];
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"CurrentControllerShowing"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    NSFileManager* fm = [NSFileManager defaultManager];
    
    
    NSURL* documentsDirURL = [self applicationDocumentsDirectory];
    NSURL* alienEmptiesDirURL = [[documentsDirURL URLByAppendingPathComponent:@"alien" isDirectory:YES] URLByAppendingPathComponent:@"empties" isDirectory:YES];
    NSURL* classicEmptiesURL = [[documentsDirURL URLByAppendingPathComponent:@"classic" isDirectory:YES] URLByAppendingPathComponent:@"empties" isDirectory:YES];
    
    
    [fm createDirectoryAtURL:alienEmptiesDirURL withIntermediateDirectories:YES attributes:nil error:nil];
    [fm createDirectoryAtURL:classicEmptiesURL withIntermediateDirectories:YES attributes:nil error:nil];
    
    
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"UfoSightings.sqlite"];
        NSString* dbInBundlePath = [[NSBundle mainBundle] pathForResource:@"UfoSightings" ofType:@"sqlite"];
        NSString* newDbPath = [storeURL path];
   
        NSURL *filterPlistURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"filters.plist"];
        NSString* filterPlistInBundlePath = [[NSBundle mainBundle] pathForResource:@"filters" ofType:@"plist"];
        NSString* newFilterPlistPath = [filterPlistURL path];
        
    for (int i = 0; i <= 31; i++) 
    {
        
        NSString* bundlePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"alien%i",i] ofType:@"png"];
        NSString* cBundlePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"classic%i",i] ofType:@"png"];
        NSError* copyError = nil;
        [fm copyItemAtPath:bundlePath toPath:[[alienEmptiesDirURL URLByAppendingPathComponent:[NSString stringWithFormat:@"alien%i.png",i]] path] error:&copyError];
        [fm copyItemAtPath:cBundlePath toPath:[[classicEmptiesURL URLByAppendingPathComponent:[NSString stringWithFormat:@"classic%i.png",i]] path] error:nil];
        
        if(copyError)
            NSLog(@"%@",copyError);
        
        NSDictionary* noProtectDict = [NSDictionary dictionaryWithObject:NSFileProtectionNone forKey:NSFileProtectionKey];
        
        [fm setAttributes:noProtectDict ofItemAtPath:[[alienEmptiesDirURL URLByAppendingPathComponent:[NSString stringWithFormat:@"alien%i.png",i]] path] error:nil];
        [fm setAttributes:noProtectDict ofItemAtPath:[[alienEmptiesDirURL URLByAppendingPathComponent:[NSString stringWithFormat:@"classic%i.png",i]] path] error:nil];        
    }
    

    
        if( ![fm fileExistsAtPath:[storeURL path]] && [fm fileExistsAtPath:dbInBundlePath] )
        {
            NSError* error = nil;
            [fm copyItemAtPath:dbInBundlePath toPath:newDbPath error:&error];
            NSLog(@"Copying Database intoDocuments Dir");
            if (error) {
                NSLog(@"ERROR - COPYING SQLITE DB TO DOCUMENTS DIRECTORY");
            }
        }
        
        
        
        
        if( ![fm fileExistsAtPath:[filterPlistURL path]] && [fm fileExistsAtPath:filterPlistInBundlePath] )
        {
            NSError* error = nil;
            [fm copyItemAtPath:filterPlistInBundlePath toPath:newFilterPlistPath error:&error];
            NSLog(@"Copying FilterPlist intoDocuments Dir");
            if (error) {
                NSLog(@"ERROR - COPYING PLIST TO DOCUMENTS DIRECTORY");
            }
        }
    
     

        
}


@end
