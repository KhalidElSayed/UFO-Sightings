//
//  RootViewController.h
//  UfoSightings
//
//  Created by Richard Kirk on 5/23/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import "UFOBaseViewController.h"
#import "UFOMapViewController.h"
#import "UFODatabaseExplorerViewController.h"

@interface UFORootController : UFOBaseViewController <UFOMapViewControllerDelegate, UFODatabaseExplorerDelegate>

@property ( strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) UFOMapViewController* mapViewController;
@property (strong, nonatomic) UFODatabaseExplorerViewController* databaseViewController;

- (void)switchViewController;

@end
