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

@interface UFORootController : UFOBaseViewController
{
    UFOMapViewController*                  _mapViewController;
    UFODatabaseExplorerViewController*     _databaseViewController;
}
@property ( strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

-(void)switchViewController;

@end
