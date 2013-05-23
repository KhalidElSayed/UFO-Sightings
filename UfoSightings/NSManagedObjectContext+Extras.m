//
//  NSManagedObjectContext+Extras.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/22/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "NSManagedObjectContext+Extras.h"

@implementation NSManagedObjectContext (Extras)


- (NSArray*)objectsWithIDs:(NSArray*)IDs
{
    NSMutableArray* objects = [[NSMutableArray alloc]initWithCapacity:IDs.count];
    
    for (NSManagedObjectID* objId in IDs) {
        NSManagedObject* obj = [self objectWithID:objId];
        if(obj) {
            [objects addObject:obj];
        }
    }
    return objects;
}

@end
