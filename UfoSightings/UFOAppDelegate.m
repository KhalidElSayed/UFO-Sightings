//
//  AppDelegate.m
//  UfoSightings
//
//  Created by Richard Kirk on 4/28/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#define GENERATE_SEED_DB YES
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#import "UFOAppDelegate.h"
#import <dispatch/dispatch.h>
#import <Crashlytics/Crashlytics.h>
#import "SightingsParser.h"
#import "UFOCoreData.h"
#import "NSFileManager+Extras.h"
#import "UFOFilterManager.h"

@implementation UFOAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Crashlytics startWithAPIKey:@"1066067e79707a9e0ab5ec2269d06f421b2c5460"];

    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"firstRun"]) {
        [self setupDefaults];
        [[NSFileManager defaultManager] movePopulatedDatabaseIntoProject];
        [[NSFileManager defaultManager] moveEmptyTilesIntoApplicationDirectory];
        [[NSFileManager defaultManager] moveDatabaseFiltersPlistIntoProjectShouldOverwrite:NO];
    }
    
    self.rootViewController = [[UFORootController alloc]init];
    
    // I like this method of window creation more than relying on a .xib to create one.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
    self.window.rootViewController = self.rootViewController;

    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [[UFOFilterManager sharedManager] saveFilters];
    [[UFOCoreData sharedInstance ] saveContext];
}


#pragma mark - Core Data stack

- (void)setupDefaults
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"firstRun"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"mapType"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"heatMapOverlayOn"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"annotationsOn"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
