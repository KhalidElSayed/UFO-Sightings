//
//  UFOBaseTestCase.h
//  UfoSightings
//
//  Created by Richard Kirk on 5/26/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "UFOCoreData.h"
#import "UFOCoreData+UnitTests.h"

@interface UFOBaseTestCase : SenTestCase

- (NSManagedObjectContext*)defaultManagedObjectContext;

@end
