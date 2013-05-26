//
//  NSFileManager+UnitTests.h
//  UfoSightings
//
//  Created by Richard Kirk on 5/26/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (UnitTests)
- (NSString*)filterDictonaryPath;
- (void)moveEmptyTilesIntoApplicationDirectory;
- (void)movePopulatedDatabaseIntoProject;
- (void)moveDatabaseFiltersPlistIntoProjectShouldOverwrite:(BOOL)overwrite;
@end
