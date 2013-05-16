//
//  SightingLocation.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/1/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import "SightingLocation.h"
#import "Sighting.h"
#import "UFOAppDelegate.h"

@implementation SightingLocation

@dynamic lat;
@dynamic lng;
@dynamic formattedAddress;
@dynamic sighting;
@synthesize coordinate = _coordinate;
@synthesize containedAnnotations, clusterAnnotation;
@synthesize title, aggregateTitle;


-(BOOL)compare:(SightingLocation*)aSighting
{
    return [self.lat compare:aSighting.lat] && [self.lng compare:aSighting.lng] && [self.formattedAddress compare:aSighting.formattedAddress];    
}

-(NSString*)title
{
    return @" ";
}

-(CLLocationCoordinate2D)actualCoordinate
{
   return CLLocationCoordinate2DMake([self.lat doubleValue], [self.lng doubleValue]);
}


@end
