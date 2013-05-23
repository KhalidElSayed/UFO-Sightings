//
//  NSManagedObjectContext+Extras.h
//  UfoSightings
//
//  Created by Richard Kirk on 5/22/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (Extras)

- (NSArray*)objectsWithIDs:(NSArray*)IDs;

@end
