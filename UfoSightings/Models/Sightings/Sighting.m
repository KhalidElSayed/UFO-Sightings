//
//  Sighting.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/1/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import "Sighting.h"
#import "SightingLocation.h"
#import "AppDelegate.h"

@implementation Sighting

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
    return [Sighting allSightingsWithPredicate:nil];
}


+(NSArray*)allSightingsWithPredicate:(NSPredicate*)predicate
{
    NSManagedObjectContext* context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest* fetch = [[NSFetchRequest alloc]initWithEntityName:@"Sighting"];
    [fetch setPredicate:predicate];
    NSError* error;
    NSArray * arr = [context executeFetchRequest:fetch error:&error];

    if(error)
        NSLog(@"%@",error);
    return arr;
}


+(Sighting*)oldestSightingBasedOn:(NSString*)attr
{
    
    NSManagedObjectContext* context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest* fetch = [[NSFetchRequest alloc]initWithEntityName:@"Sighting"];
    NSSortDescriptor* sort = [NSSortDescriptor sortDescriptorWithKey:attr ascending:YES];
    [fetch setSortDescriptors:[NSArray arrayWithObject:sort ]];
    [fetch setFetchLimit:1];
    NSError* error;
    NSArray * arr = [context executeFetchRequest:fetch error:&error];
    
    if(error)
        NSLog(@"%@",error);
    
    return [arr lastObject];

    
}

+(Sighting*)newestSightingBasedOn:(NSString*)attr
{
    
    NSManagedObjectContext* context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest* fetch = [[NSFetchRequest alloc]initWithEntityName:@"Sighting"];
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
