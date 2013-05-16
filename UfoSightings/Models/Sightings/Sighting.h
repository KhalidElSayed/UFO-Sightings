//
//  Sighting.h
//  UfoSightings
//
//  Created by Richard Kirk on 5/1/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SightingLocation.h"

@interface Sighting : NSManagedObject

@property (nonatomic, retain) NSString * duration;
@property (nonatomic, retain) NSString * report;
@property (nonatomic, retain) NSDate * reportedAt;
@property (nonatomic, retain) NSString * shape;
@property (nonatomic, retain) NSDate * sightedAt;
@property (nonatomic, retain) NSNumber * sightingId;
@property (nonatomic, retain) NSNumber * reportLength;
@property (nonatomic, retain) SightingLocation *location;

+(NSArray*)allSightings;
+(NSArray*)allSightingsWithPredicate:(NSPredicate*)predicate;
+(Sighting*)oldestSightingBasedOn:(NSString*)attr;
+(Sighting*)newestSightingBasedOn:(NSString*)attr;
@end
