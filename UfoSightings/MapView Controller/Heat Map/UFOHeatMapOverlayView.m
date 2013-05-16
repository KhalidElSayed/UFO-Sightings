//
//  HeatMapOverlayView.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/3/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import "UFOHeatMapOverlayView.h"
#import "UFOHeatMap.h"


@implementation UFOHeatMapOverlayView

#pragma mark MKOverlayView methods
- (id)initWithOverlay:(id <MKOverlay>)overlay
{
    if((self = [super initWithOverlay:overlay]))
    {
    }
    return self;
}


/**
 * Called by MapKit when a tile is on the visible space of the map.
 * This method tests the cache to see if a tile is available to be drawn.
 * If not, an asynchronous HTTP request is performed.
 *
 * Returns YES if a tile can be draw immediately. MapKit will then call
 * drawMapRect:zoomScale:context:.
 *
 * Returns NO if significant processing (HTTP requests, etc.) must be performed
 * before a tile can be drawn. MapKit will skip over this tile and only
 * attempt to reload this if the tile leaves and re-enters the view. (A reload
 * can be forced by calling setNeedsDisplayInMapRect:zoomScale:)
*/
- (BOOL)canDrawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale {
    NSURL* fileURL = [(UFOHeatMap*)self.overlay localUrlForStyle:@"alien" withMapRect:mapRect andZoomScale:zoomScale];
    if([[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]])
        return YES;
    
    [(UFOHeatMap*)self.overlay fetchFileForStyle:@"alien" withMapRect:mapRect zoomScale:zoomScale completion:^{
        [self setNeedsDisplayInMapRect:mapRect zoomScale:zoomScale];
    }];
    
    return NO;
   
    
}

/**
 * If the above method returns YES, this method performs the actual screen render
 * of a particular tile.
 *
 * You should never perform long processing (HTTP requests, etc.) from this method
 * or else your application UI will become blocked. You should make sure that
 * canDrawMapRect ONLY EVER returns YES if you are positive the tile is ready
 * to be rendered.
 */
- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {
    
    NSURL* fileURL = [(UFOHeatMap*)self.overlay localUrlForStyle:@"alien" withMapRect:mapRect andZoomScale:zoomScale];
    NSData *imageData = [NSData dataWithContentsOfURL:fileURL ];
    if (imageData != nil) {
        UIImage *img = [UIImage imageWithData:imageData];
        
        // Perform the image render on the current UI context
        UIGraphicsPushContext(context);
        
        [img drawInRect:[self rectForMapRect:mapRect]];
        UIGraphicsPopContext();
        
    }

    
}


@end
