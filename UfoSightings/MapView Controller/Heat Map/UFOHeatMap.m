//
//  HeatMap.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/3/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import "UFOHeatMap.h"
@interface UFOHeatMap()

- (NSUInteger)worldTileWidthForZoomLevel:(NSUInteger)zoomLevel;
- (CGPoint)mercatorTileOriginForMapRect:(MKMapRect)mapRect;
@end

@implementation UFOHeatMap
@synthesize boundingMapRect, coordinate;


- (id)init
{
    if((self = [super init])) {
        _tileServerQueue = [[NSOperationQueue alloc]init];
        [_tileServerQueue setName:@"TileServerQueue"];
    }
    return self;
}


- (void)fetchFileForStyle:(NSString *)style withMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale completion:(void (^)())completion
{
    NSUInteger zoomLevel = [UFOHeatMap zoomLevelForZoomScale:zoomScale];
    CGPoint mercatorPoint = [self mercatorTileOriginForMapRect:mapRect];
    NSUInteger tilex = floor(mercatorPoint.x * [self worldTileWidthForZoomLevel:zoomLevel]);
    NSUInteger tiley = floor(mercatorPoint.y * [self worldTileWidthForZoomLevel:zoomLevel]);

    [self fetchFileForStyle:style zoomLevel:zoomLevel withX:tilex andY:tiley completion:completion];
}


- (void)fetchFileForStyle:(NSString *)style zoomLevel:(NSUInteger)zoom withX:(NSUInteger)x andY:(NSUInteger)y completion:(void (^)())completion
{  
    NSURLRequest * req = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://richardbkirk.com/u/gheat/%@/%d/%d,%d.png", style, zoom, x, y]]];

    [NSURLConnection sendAsynchronousRequest:req queue:_tileServerQueue completionHandler:^(NSURLResponse *response, NSData* data, NSError* error){
        
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        

        
        NSURL* orginalRequest = req.URL;
       // NSLog(@"%@", httpResponse.suggestedFilename);
       // NSLog(@"%i", httpResponse.statusCode);
       // NSLog(@"%i", httpResponse.allHeaderFields.count);
        
       //    NSLog(@"*********************");
      //  for (NSString* key in [httpResponse.allHeaderFields allKeys]) {
    
       //    NSLog(@"%@ = %@",key, [httpResponse.allHeaderFields objectForKey:key]);
       // }
       //    NSLog(@"%i *********************", [httpResponse.allHeaderFields allKeys].count);        

        NSArray* pathComponets = [orginalRequest pathComponents];        
        NSString* fileName = [[pathComponets objectAtIndex:5] stringByDeletingPathExtension];
        NSArray* fileNameComponents = [fileName componentsSeparatedByString:@","];
        
        NSString* style = [pathComponets objectAtIndex:3];
        NSString* zoom = [pathComponets objectAtIndex:4];
        NSString* x = [fileNameComponents objectAtIndex:0];
        NSString* y = [fileNameComponents objectAtIndex:1];
        
        
        NSURL* documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSString* pathToFile = [[documentsDirectory path] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@/%@,%@.png",style,zoom,x,y]];
   
        if(![[NSFileManager defaultManager] fileExistsAtPath:[pathToFile stringByDeletingLastPathComponent]])
            [[NSFileManager defaultManager] createDirectoryAtPath:[pathToFile stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
        
        
        
        if(httpResponse.statusCode == 400)
        {
           NSURL* URLToEmptyFolder = [[documentsDirectory URLByAppendingPathComponent:@"alien" isDirectory:YES] URLByAppendingPathComponent:@"empties" isDirectory:YES];
            NSString* pathToEmpty = [[URLToEmptyFolder URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.png", style, zoom] isDirectory:NO] path];
//            [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@%@", style, zoom] ofType:@"png"];
                    
            NSError* er;
            [[NSFileManager defaultManager ] linkItemAtPath:pathToEmpty toPath:pathToFile error:&er];
            if (er) 
                NSLog(@"%@",er);
            
            completion();
        }
        else if (httpResponse.statusCode == 200)
        {
            UIImage* newPNG = [UIImage imageWithData:data];
            NSData* pngData = [NSData dataWithData:UIImagePNGRepresentation(newPNG)]; 
            
            [pngData writeToFile:pathToFile options:NSDataWritingFileProtectionNone error:nil];
            
            
            //[[NSFileManager defaultManager] createFileAtPath:pathToFile contents:pngData attributes:nil];
            completion();
        }
    
    }];
}


- (NSURL*)remoteUrlForStyle:(NSString*)style zoomLevel:(NSUInteger)zoom withX:(NSUInteger)x andY:(NSUInteger)y
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://richardbkirk.com/u/gheat/%@/%d/%d,%d.png", style, zoom, x,y]];
}


- (NSURL*)localUrlForStyle:(NSString*)style zoomLevel:(NSUInteger)zoom withX:(NSUInteger)x andY:(NSUInteger)y
{
    NSURL* documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    return [documentsDirectory URLByAppendingPathComponent:[NSString stringWithFormat:@"%@/%d/%d,%d.png", style,zoom, x, y] isDirectory:NO];
}


- (NSURL*)localUrlForStyle:(NSString *)style withMapRect:(MKMapRect)mapRect andZoomScale:(MKZoomScale)zoomScale
{
    NSUInteger zoomLevel = [UFOHeatMap zoomLevelForZoomScale:zoomScale];
    CGPoint mercatorPoint = [self mercatorTileOriginForMapRect:mapRect];
    NSUInteger tilex = floor(mercatorPoint.x * [self worldTileWidthForZoomLevel:zoomLevel]);
    NSUInteger tiley = floor(mercatorPoint.y * [self worldTileWidthForZoomLevel:zoomLevel]);

    return [self localUrlForStyle:style zoomLevel:zoomLevel withX:tilex andY:tiley];
}


- (NSURL*)remoteUrlForStyle:(NSString *)style withMapRect:(MKMapRect)mapRect andZoomScale:(MKZoomScale)zoomScale
{    
    NSUInteger zoomLevel = [UFOHeatMap zoomLevelForZoomScale:zoomScale];
    CGPoint mercatorPoint = [self mercatorTileOriginForMapRect:mapRect];
    NSUInteger tilex = floor(mercatorPoint.x * [self worldTileWidthForZoomLevel:zoomLevel]);
    NSUInteger tiley = floor(mercatorPoint.y * [self worldTileWidthForZoomLevel:zoomLevel]);
    
    return [self remoteUrlForStyle:style zoomLevel:zoomLevel withX:tilex andY:tiley];
}


#pragma mark MKOverlay Protocols
// The Heat map of UFO sightings spans the globe 
// The center coordinate will where the prime meridian meets
// the equator.   
- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake(0.0, 0.0);
}


- (MKMapRect)boundingMapRect
{
    MKMapRect mr = MKMapRectWorld;
    mr.size.width += 1;
    if (MKMapRectSpans180thMeridian(mr)) {
        return mr;
    }
    else {
        NSLog(@"HEATMAP.M:BoundingMapRect Does not span meridian");
        return MKMapRectNull;
    }
}

- (NSURLRequest *)connection:(NSURLConnection *)connection
            willSendRequest:(NSURLRequest *)request
           redirectResponse:(NSURLResponse *)redirectResponse
{

    return nil;
}



/*  The private utility methods were provided by Matt Tigas
 in the project https://github.com/mtigas/iOS-MapLayerDemo
 
 Thank you Matt Tigas. :)
 */

#pragma mark Private utility methods
/**
 * Given a MKMapRect, this returns the zoomLevel based on
 * the longitude width of the box.
 *
 * This is because the Mercator projection, when tiled,
 * normally operates with 2^zoomLevel tiles (1 big tile for
 * world at zoom 0, 2 tiles at 1, 4 tiles at 2, etc.)
 * and the ratio of the longitude width (out of 360º)
 * can be used to reverse this.
 *
 * This method factors in screen scaling for the iPhone 4:
 * the tile layer will use the *next* zoomLevel. (We are given
 * a screen that is twice as large and zoomed in once more
 * so that the "effective" region shown is the same, but
 * of higher resolution.)
 */
+ (NSUInteger)zoomLevelForMapRect:(MKMapRect)mapRect {
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
    CGFloat lon_ratio = region.span.longitudeDelta/360.0;
    NSUInteger z = (NSUInteger)(log(1/lon_ratio)/log(2.0)-1.0);
    
    z += ([[UIScreen mainScreen] scale] - 1.0);
    return z;
}
/**
 * Similar to above, but uses a MKZoomScale to determine the
 * Mercator zoomLevel. (MKZoomScale is a ratio of screen points to
 * map points.)
 */
+ (NSUInteger)zoomLevelForZoomScale:(MKZoomScale)zoomScale {
    CGFloat realScale = zoomScale / [[UIScreen mainScreen] scale];
    NSUInteger z = (NSUInteger)(log(realScale)/log(2.0)+20.0);
    
    z += ([[UIScreen mainScreen] scale] - 1.0);
    return z;
}

+ (NSUInteger)zoomLevelForRegion:(MKCoordinateRegion)region
{
    CGFloat lon_ratio = region.span.longitudeDelta/360.0;
    NSUInteger z = (NSUInteger)(log(1/lon_ratio)/log(2.0)-1.0);
    
    z += ([[UIScreen mainScreen] scale] - 1.0);
    return z;
}
/**
 * Shortcut to determine the number of tiles wide *or tall* the
 * world is, at the given zoomLevel. (In the Spherical Mercator
 * projection, the poles are cut off so that the resulting 2D
 * map is "square".)
 */
- (NSUInteger)worldTileWidthForZoomLevel:(NSUInteger)zoomLevel {
    return (NSUInteger)(pow(2,zoomLevel));
}

/**
 * Given a MKMapRect, this reprojects the center of the mapRect
 * into the Mercator projection and calculates the rect's top-left point
 * (so that we can later figure out the tile coordinate).
 *
 * See http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#Derivation_of_tile_names
 */
- (CGPoint)mercatorTileOriginForMapRect:(MKMapRect)mapRect {
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
    
    // Convert lat/lon to radians
    CGFloat x = (region.center.longitude) * (M_PI/180.0); // Convert lon to radians
    CGFloat y = (region.center.latitude) * (M_PI/180.0); // Convert lat to radians
    y = log(tan(y)+1.0/cos(y));
    
    // X and Y should actually be the top-left of the rect (the values above represent
    // the center of the rect)
    x = (1.0 + (x/M_PI)) / 2.0;
    y = (1.0 - (y/M_PI)) / 2.0;
    
    return CGPointMake(x, y);
}
// ******************* End of Matt Tigas' wonderful helpers*******************

@end
