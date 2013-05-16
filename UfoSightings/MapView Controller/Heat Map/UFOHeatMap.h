//
//  HeatMap.h
//  UfoSightings
//
//  Created by Richard Kirk on 5/3/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>
#import "UFOHeatMapOverlayView.h"



@interface UFOHeatMap : NSObject <MKOverlay, NSURLConnectionDataDelegate>
{
    NSOperationQueue*   _tileServerQueue;
}




// *********** MKOverlay Protocols **************
// From MKAnnotation, for areas this should return the centroid of the area.
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

// boundingMapRect should be the smallest rectangle that completely contains the overlay.
// For overlays that span the 180th meridian, boundingMapRect should have either a negative MinX 
// or a MaxX that is greater than MKMapSizeWorld.width.
@property (nonatomic, readonly) MKMapRect boundingMapRect;
// **********************************************

+ (NSUInteger)zoomLevelForMapRect:(MKMapRect)mapRect;
+ (NSUInteger)zoomLevelForZoomScale:(MKZoomScale)zoomScale;
+ (NSUInteger)zoomLevelForRegion:(MKCoordinateRegion)region;
-(NSURL*)remoteUrlForStyle:(NSString*)style zoomLevel:(NSUInteger)zoom withX:(NSUInteger)x andY:(NSUInteger)y;
-(NSURL*)localUrlForStyle:(NSString*)style zoomLevel:(NSUInteger)zoom withX:(NSUInteger)x andY:(NSUInteger)y;
-(NSURL*)localUrlForStyle:(NSString *)style withMapRect:(MKMapRect)mapRect andZoomScale:(MKZoomScale)zoomScale;
-(NSURL*)remoteUrlForStyle:(NSString *)style withMapRect:(MKMapRect)mapRect andZoomScale:(MKZoomScale)zoomScale;

-(void)fetchFileForStyle:(NSString*)style zoomLevel:(NSUInteger)zoom withX:(NSUInteger)x andY:(NSUInteger)y completion:(void (^)())completion;
-(void)fetchFileForStyle:(NSString*)style withMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale completion:(void (^)())completion;


@end

