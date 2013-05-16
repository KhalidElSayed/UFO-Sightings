//
//  Sighting.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/1/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import "UFOSighting.h"
#import "SightingLocation.h"
#import "UFOAppDelegate.h"

@implementation UFOSighting

@dynamic duration;
@dynamic report;
@dynamic reportedAt;
@dynamic shape;
@dynamic sightedAt;
@dynamic sightingId;
@dynamic location;
@dynamic reportLength;

+(NSArray*)allSightings
{
    return [UFOSighting allSightingsWithPredicate:nil];
}


+(NSArray*)allSightingsWithPredicate:(NSPredicate*)predicate
{
    NSManagedObjectContext* context = [(UFOAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest* fetch = [[NSFetchRequest alloc]initWithEntityName:@"UFOSighting"];
    [fetch setPredicate:predicate];
    NSError* error;
    NSArray * arr = [context executeFetchRequest:fetch error:&error];

    if(error)
        NSLog(@"%@",error);
    return arr;
}


+(UFOSighting*)oldestSightingBasedOn:(NSString*)attr
{
    
    NSManagedObjectContext* context = [(UFOAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest* fetch = [[NSFetchRequest alloc]initWithEntityName:@"UFOSighting"];
    NSSortDescriptor* sort = [NSSortDescriptor sortDescriptorWithKey:attr ascending:YES];
    [fetch setSortDescriptors:[NSArray arrayWithObject:sort ]];
    [fetch setFetchLimit:1];
    NSError* error;
    NSArray * arr = [context executeFetchRequest:fetch error:&error];
    
    if(error)
        NSLog(@"%@",error);
    
    return [arr lastObject];

    
}

+(UFOSighting*)newestSightingBasedOn:(NSString*)attr
{
    
    NSManagedObjectContext* context = [(UFOAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest* fetch = [[NSFetchRequest alloc]initWithEntityName:@"UFOSighting"];
    NSSortDescriptor* sort = [NSSortDescriptor sortDescriptorWithKey:attr ascending:NO];
    [fetch setSortDescriptors:[NSArray arrayWithObject:sort ]];
    [fetch setFetchLimit:1];
    NSError* error;
    NSArray * arr = [context executeFetchRequest:fetch error:&error];
    
    if(error)
        NSLog(@"%@",error);
    
    return [arr lastObject];
    
    
}


@end
