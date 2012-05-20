//
//  SightingLocation.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/1/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import "SightingLocation.h"
#import "Sighting.h"
#import "AppDelegate.h"

@implementation SightingLocation

@dynamic lat;
@dynamic lng;
@dynamic formattedAddress;
@dynamic sighting;
@synthesize coordinate = _coordinate;
@synthesize actualCoordinate;
@synthesize containedAnnotations, clusterAnnotation;



-(BOOL)compare:(SightingLocation*)aSighting
{
    return [self.lat compare:aSighting.lat] && [self.lng compare:aSighting.lng] && [self.formattedAddress compare:aSighting.formattedAddress];    
}
/*
-(CLLocationCoordinate2D)coordinate
{
    if(CLLocationCoordinate2DIsValid(_coordinate))
        return _coordinate;
    else
        return actualCoordinate;
    
}

-(void)setCoordinate:(CLLocationCoordinate2D)coordinate
{
    _coordinate = coordinate;
}
*/
-(CLLocationCoordinate2D)actualCoordinate
{
    return CLLocationCoordinate2DMake([self.lat doubleValue], [self.lng doubleValue]);
}

-(NSString*)title
{

    if (self.containedAnnotations && [self.containedAnnotations count] > 0) {
        NSUInteger sightingsCount = [self.sighting count];
        
        for (SightingLocation* location in self.containedAnnotations) {
            sightingsCount += location.sighting.count;
        }
        
        return [NSString stringWithFormat:@"%d sightings in %d cities",sightingsCount, [self.containedAnnotations count] + 1];
    }
    
    return [NSString stringWithFormat:@"%d sightings in %@", [self.sighting count], self.formattedAddress];
}




+(NSArray*)allSightings
{
    
    NSManagedObjectContext* context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest* fetch = [[NSFetchRequest alloc]initWithEntityName:@"SightingLocation"];
    
    NSError* error;
    NSArray * arr = [context executeFetchRequest:fetch error:&error];
    
    if(error)
        NSLog(@"%@",error);

    
        NSLog(@"%d sightingLocations Fetched",[arr count]);
    return arr;

}


+(NSArray*)SightingLocationsInMapRect:(MKMapRect)mapRect
{
    MKCoordinateRegion coordinateRegion = MKCoordinateRegionForMapRect(mapRect);    
    return [SightingLocation SightingLocationsInRegion:coordinateRegion];
}

+(NSArray*)SightingLocationsInMapRect:(MKMapRect)mapRect withLimit:(NSUInteger)limit
{
    
    NSManagedObjectContext* context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest* fetch = [[NSFetchRequest alloc]initWithEntityName:@"SightingLocation"];
    [fetch setFetchLimit:limit];
    
    
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);    
    CLLocationCoordinate2D center = region.center;
    MKCoordinateSpan span = region.span;
    double halfLatDelta = span.latitudeDelta / 2;
    double halfLngDelta = span.longitudeDelta / 2;
    
    CLLocationDegrees minLat = center.latitude - halfLatDelta;
    CLLocationDegrees maxLat = center.latitude + halfLatDelta;
    CLLocationDegrees minLng = center.longitude - halfLngDelta;
    CLLocationDegrees maxLng = center.longitude + halfLngDelta;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"lng <= %@ AND lng >= %@ AND  lat <= %@ AND lat >= %@ ",[NSNumber numberWithDouble:maxLng ], [NSNumber numberWithDouble:minLng], [NSNumber numberWithDouble:maxLat] , [NSNumber numberWithDouble:minLat]];
    
    [fetch setPredicate:predicate];
    
    NSError* error;
    NSArray * arr = [context executeFetchRequest:fetch error:&error];
    
    if(error)
        NSLog(@"%@",error);
    

    return arr;
}

+(NSArray*)SightingLocationsInRegion:(MKCoordinateRegion)region
{
    NSManagedObjectContext* context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest* fetch = [[NSFetchRequest alloc]initWithEntityName:@"SightingLocation"];
    
    
    CLLocationCoordinate2D center = region.center;
    MKCoordinateSpan span = region.span;
    double halfLatDelta = span.latitudeDelta / 2;
    double halfLngDelta = span.longitudeDelta / 2;
    
    CLLocationDegrees minLat = center.latitude - halfLatDelta;
    CLLocationDegrees maxLat = center.latitude + halfLatDelta;
    CLLocationDegrees minLng = center.longitude - halfLngDelta;
    CLLocationDegrees maxLng = center.longitude + halfLngDelta;

    NSPredicate *predicate = [NSPredicate predicateWithFormat: @" lng <= %@ AND lng >= %@ AND  lat <= %@ AND lat >= %@ ",[NSNumber numberWithDouble:maxLng ], [NSNumber numberWithDouble:minLng], [NSNumber numberWithDouble:maxLat] , [NSNumber numberWithDouble:minLat]];
    
    [fetch setPredicate:predicate];
    
    NSError* error;
    NSArray * arr = [context executeFetchRequest:fetch error:&error];
    
    if(error)
        NSLog(@"%@",error);
    
 //  NSLog(@"%d",[arr count]);
    
    return arr;
}

@end
