//
//  UFOBaseTestCase.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/26/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "UFOBaseTestCase.h"
#import "UFOCoreData.h"

@implementation UFOBaseTestCase

- (NSManagedObjectContext*)defaultManagedObjectContext
{
    return [[UFOCoreData sharedInstance] managedObjectContext];
}

- (void)setUp
{
    [super setUp];
    [[UFOCoreData sharedInstance] resetContext];
}

@end
