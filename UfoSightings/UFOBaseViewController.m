//
//  UFOBaseViewController.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/16/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "UFOBaseViewController.h"


@implementation UFOBaseViewController

- (NSManagedObjectContext*)managedObjectContext
{
    return [[UFOCoreData sharedInstance] managedObjectContext];
}


- (UFOFilterManager*)filterManager
{
    return [UFOFilterManager sharedManager];
}

@end


@implementation UFOBaseTableViewController

- (NSManagedObjectContext*)managedObjectContext
{
    return [[UFOCoreData sharedInstance] managedObjectContext];
}


- (UFOFilterManager*)filterManager
{
    return [UFOFilterManager sharedManager];
}

@end