//
//  RootViewController.h
//  UfoSightings
//
//  Created by Richard Kirk on 5/23/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"
#import "DatabaseExplorerViewController.h"

@interface RootController : UIViewController
{
    MapViewController*                  _mapViewController;
    DatabaseExplorerViewController*     _databaseViewController;
}
@property (strong,nonatomic) NSManagedObjectContext* managedObjectContext;

-(id)initWithManagedObjectContext:(NSManagedObjectContext*)context;
-(void)switchViewController;

@end
