//
//  RootViewController.h
//  UfoSightings
//
//  Created by Richard Kirk on 5/23/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UFOMapViewController.h"
#import "UFODatabaseExplorerViewController.h"

@interface UFORootController : UIViewController
{
    UFOMapViewController*                  _mapViewController;
    UFODatabaseExplorerViewController*     _databaseViewController;
}
@property ( strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
-(id)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator*)persistentStoreCor;
-(void)switchViewController;

@end
