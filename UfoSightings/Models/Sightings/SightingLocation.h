//
//  SightingLocation.h
//  UfoSightings
//
//  Created by Richard Kirk on 5/1/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/Mapkit.h>

@class Sighting;

@interface SightingLocation : NSManagedObject <MKAnnotation>

@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lng;
@property (nonatomic, retain) NSString * formattedAddress;
@property (nonatomic, retain) NSSet *sighting;

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (strong, nonatomic) NSString* aggregateTitle; 

@property (strong, nonatomic)NSArray* containedAnnotations;
@property (strong, nonatomic)SightingLocation* clusterAnnotation;


-(CLLocationCoordinate2D)actualCoordinate;



-(BOOL)compare:(SightingLocation*)aSighting;

@end

@interface SightingLocation (CoreDataGeneratedAccessors)

- (void)addSightingObject:(Sighting *)value;
- (void)removeSightingObject:(Sighting *)value;
- (void)addSighting:(NSSet *)values;
- (void)removeSighting:(NSSet *)values;

@end
