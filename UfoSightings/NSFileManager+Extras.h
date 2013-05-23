//
//  NSFileManager+Extras.h
//  UfoSightings
//
//  Created by Richard Kirk on 5/16/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (Extras)

- (NSURL *)applicationDocumentsDirectory;

- (void)moveEmptyTilesIntoApplicationDirectory;

- (void)movePopulatedDatabaseIntoProject;

- (void)moveDatabaseFiltersPlistIntoProjectShouldOverwrite:(BOOL)overwrite;

- (void)shapeNameMappingDictionary;

- (NSString*)shapesDictionaryPath;
- (NSString*)filterDictonaryPath;
@end
