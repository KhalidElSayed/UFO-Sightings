//
//  NSFileManager+Extras.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/16/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "NSFileManager+Extras.h"

@implementation NSFileManager (Extras)

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[self URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)moveEmptyTilesIntoApplicationDirectory {
    
    NSURL* documentsDirURL = [self applicationDocumentsDirectory];
    NSURL* alienEmptiesDirURL = [[documentsDirURL URLByAppendingPathComponent:@"alien" isDirectory:YES] URLByAppendingPathComponent:@"empties" isDirectory:YES];
    NSURL* classicEmptiesURL = [[documentsDirURL URLByAppendingPathComponent:@"classic" isDirectory:YES] URLByAppendingPathComponent:@"empties" isDirectory:YES];
    NSDictionary* noProtectDict = [NSDictionary dictionaryWithObject:NSFileProtectionNone forKey:NSFileProtectionKey];
    
    NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"alien"];
    NSString *destPath = [[documentsDirURL path] stringByAppendingPathComponent:@"alien"];
    
    NSArray* resContents = [self contentsOfDirectoryAtPath:sourcePath error:NULL];
    
    for (NSString* obj in resContents){
        NSError* error;
        [self createDirectoryAtPath:obj withIntermediateDirectories:YES attributes:nil error:nil];
        [self createDirectoryAtURL:alienEmptiesDirURL withIntermediateDirectories:YES attributes:nil error:nil];
        if (![self copyItemAtPath:[sourcePath stringByAppendingPathComponent:obj] toPath:[destPath stringByAppendingPathComponent:obj]
                                                      error:&error])
            NSLog(@"Error: %@", error);
    }
    
    if(![self fileExistsAtPath:[alienEmptiesDirURL path]])
    {
        [self createDirectoryAtURL:alienEmptiesDirURL withIntermediateDirectories:YES attributes:nil error:nil];
        for (int i = 0; i <= 31; i++)
        {
            NSString* bundlePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"alien%i",i] ofType:@"png"];
            NSError* copyError = nil;
            [self copyItemAtPath:bundlePath toPath:[[alienEmptiesDirURL URLByAppendingPathComponent:[NSString stringWithFormat:@"alien%i.png",i]] path] error:&copyError];
            if(copyError)
                NSLog(@"%@",copyError);
            
            [self setAttributes:noProtectDict ofItemAtPath:[[alienEmptiesDirURL URLByAppendingPathComponent:[NSString stringWithFormat:@"alien%i.png",i]] path] error:nil];
        }
    }
    
    if(![self fileExistsAtPath:[classicEmptiesURL path]])
    {
        [self createDirectoryAtURL:classicEmptiesURL withIntermediateDirectories:YES attributes:nil error:nil];
        for (int i = 0; i <= 31; i++)
        {
            NSString* cBundlePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"classic%i",i] ofType:@"png"];
            NSError* copyError = nil;
            [self copyItemAtPath:cBundlePath toPath:[[classicEmptiesURL URLByAppendingPathComponent:[NSString stringWithFormat:@"classic%i.png",i]] path] error:nil];
            if(copyError)
                NSLog(@"%@",copyError);
            
            [self setAttributes:noProtectDict ofItemAtPath:[[classicEmptiesURL URLByAppendingPathComponent:[NSString stringWithFormat:@"classic%i.png",i]] path] error:nil];
        }
    }
}


- (void)movePopulatedDatabaseIntoProject
{
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"UfoSightings.sqlite"];
    NSString* dbInBundlePath = [[NSBundle mainBundle] pathForResource:@"UfoSightings" ofType:@"sqlite"];
    NSString* newDbPath = [storeURL path];
    
    if( ![self fileExistsAtPath:[storeURL path]] && [self fileExistsAtPath:dbInBundlePath] )
    {
        NSError* error = nil;
        [self copyItemAtPath:dbInBundlePath toPath:newDbPath error:&error];
        NSLog(@"Copying Database intoDocuments Dir");
        if (error) {
            NSLog(@"ERROR - COPYING SQLITE DB TO DOCUMENTS DIRECTORY");
        }
    }
}


- (void)moveDatabaseFiltersPlistIntoProjectShouldOverwrite:(BOOL)overwrite
{
    NSURL *filterPlistURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"filters.plist"];
    NSString* filterPlistInBundlePath = [[NSBundle mainBundle] pathForResource:@"filters" ofType:@"plist"];
    NSString* newFilterPlistPath = [filterPlistURL path];
    
    if( (![self fileExistsAtPath:[filterPlistURL path]] || overwrite) && [self fileExistsAtPath:filterPlistInBundlePath] ) {
        NSError* error = nil;
        [self copyItemAtPath:filterPlistInBundlePath toPath:newFilterPlistPath error:&error];
        NSLog(@"Copying FilterPlist intoDocuments Dir");
        if (error) {
            NSLog(@"ERROR - COPYING PLIST TO DOCUMENTS DIRECTORY");
        }
    }
}


- (NSString*)shapesDictionaryPath
{
    return [[[self applicationDocumentsDirectory] path] stringByAppendingPathComponent:@"shapes.plist"];
}


- (NSString*)filterDictonaryPath
{
    return [[[self applicationDocumentsDirectory] path] stringByAppendingPathComponent:@"filters.plist"];
}


- (NSDictionary*)shapeNameMappingDictionary
{
    NSDictionary* shapesDict = [NSDictionary dictionaryWithContentsOfFile:[self shapesDictionaryPath]];
    return [shapesDict objectForKey:@"badShapeMatching"];
}

@end
