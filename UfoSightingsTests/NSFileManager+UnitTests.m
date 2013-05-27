//
//  NSFileManager+UnitTests.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/26/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "NSFileManager+UnitTests.h"

@implementation NSFileManager (UnitTests)
- (NSString*)filterDictonaryPath
{
    return [[[NSBundle mainBundle] pathForResource:@"filters" ofType:@"plist"];
}
- (void)moveEmptyTilesIntoApplicationDirectory{}
- (void)movePopulatedDatabaseIntoProject{}
- (void)moveDatabaseFiltersPlistIntoProjectShouldOverwrite:(BOOL)overwrite{}
@end
