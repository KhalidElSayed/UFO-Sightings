//
//  SightingAnnotation.h
//  UfoSightings
//
//  Created by Richard Kirk on 6/6/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/Mapkit.h>

@interface SightingAnnotation : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (strong, nonatomic) NSArray* containedAnnotations;

-(NSString*)buildTitle;


@end
