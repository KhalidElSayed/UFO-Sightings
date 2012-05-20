//
//  ViewController.m
//  LocationFun
//
//  Created by Richard Kirk on 12/19/11.
//  Copyright (c) 2011 Home. All rights reserved.
//

#import "MapViewController.h"
#import "Sighting.h"
#import "HeatMap.h"
#import "MapModalView.h"


#define DEGREES_TO_RADIANS(angle) (angle / 180.0 * M_PI)


@interface MapViewController()
{
    MKMapView *_backMap;
    NSArray* _allSightings;
    MapModalView*   _modalView;
    dispatch_queue_t annotationsQ;
    bool            _mapSelectionOpen;
    bool            _annotationsShowing;
    bool            _heatMapShowing;
}
- (void)updateVisibleAnnotations;
- (id<MKAnnotation>)annotationInGrid:(MKMapRect)gridMapRect usingAnnotations:(NSSet*)annotations;
@end

@implementation MapViewController
@synthesize managedObjectContext;
@synthesize myMap;
@synthesize tvOverlay;
@synthesize debugLabel;
@synthesize modalPlaceholderView;
@synthesize compassButton;
@synthesize sightingAnnotationsButton;
@synthesize mapLayerButton;
@synthesize mapTypeSegmentController;
@synthesize levelLabel;





#pragma mark - View lifecycle

-(id)init
{
    if((self = [super init]))
    {
        annotationsQ = dispatch_queue_create("annotationsQueue", DISPATCH_QUEUE_SERIAL);
        _heatMapOverlay = [[HeatMap alloc]init];
        _backMap = [[MKMapView alloc]initWithFrame:CGRectZero];
        _mapSelectionOpen = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if([CLLocationManager locationServicesEnabled])
    {
        locationManager = [[CLLocationManager alloc]init];
        locationManager.delegate = self;
        
        [locationManager setDistanceFilter:1000];
        [locationManager setDesiredAccuracy:kCLLocationAccuracyKilometer];
        
        [locationManager startUpdatingLocation];
    }
    else
    {
        NSLog(@"User does not allow location services");
    }
    
    MKCoordinateRegion region = {{ 36.102376, -119.091797}, {32.451446, 28.125000}};
   // region.center = CLLocationCoordinate2DMake(38.8402805, -97.6114237);
   // region.span = MKCoordinateSpanMake(50,50);
  //  MKCoordinateRegion region;
   // region.center = CLLocationCoordinate2DMake(38.214446, -97.514648);
   // region.span = MKCoordinateSpanMake(0.807087,1.406250);
    
    [myMap setRegion:region];   
    //[myMap setUserTrackingMode:MKUserTrackingModeFollow];
    
    [myMap setShowsUserLocation:YES];
        _heatMapOverlay.managedObjectContext = self.managedObjectContext;    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        
        _allSightings = [SightingLocation allSightings];
        for (SightingLocation* location in _allSightings) {
            location.coordinate = [location actualCoordinate];
        }
        [_backMap addAnnotations:_allSightings];        
    });

    

    NSInteger mapType = [[NSUserDefaults standardUserDefaults] integerForKey:@"mapType"];
    [myMap setMapType:mapType];
    [self.mapTypeSegmentController setSelectedSegmentIndex:mapType];
    
    _annotationsShowing = [[NSUserDefaults standardUserDefaults] boolForKey:@"annotationsOn"];
    [self.sightingAnnotationsButton setSelected:_annotationsShowing];
    if(_annotationsShowing)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            [self updateVisibleAnnotations];   
        });    
    }
    
    _heatMapShowing = [[NSUserDefaults standardUserDefaults] boolForKey:@"heatMapOverlayOn"]; 

    [self.mapLayerButton setSelected:_heatMapShowing];
    if(_heatMapShowing)
    {
        [myMap addOverlay:_heatMapOverlay];
    }
    
    


    //[myMap addOverlay:_heatMapOverlay];
    
//********************************************************    
    
    
       
/*
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        
            [self updateVisibleAnnotations];   
    });    
*/
//********************************************************        
    
}

-(void)viewWillUnload
{
    [super viewWillUnload];
    [[NSUserDefaults standardUserDefaults] setBool:self.mapLayerButton.isSelected forKey:@"heatMapOverlayOn"];
    [[NSUserDefaults standardUserDefaults] setBool:self.sightingAnnotationsButton.isSelected forKey:@"annotationsOn"];
    [[NSUserDefaults standardUserDefaults] setInteger:self.mapTypeSegmentController.selectedSegmentIndex forKey:@"mapType"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



- (void)viewDidUnload
{
    dispatch_release(annotationsQ);
    [self setMyMap:nil];
    [self setLevelLabel:nil];
    _heatMapOverlay = nil;
    _backMap = nil;
    [self setDebugLabel:nil];
    [self setTvOverlay:nil];
    [self setModalPlaceholderView:nil];
    [self setCompassButton:nil];
    [self setMapLayerButton:nil];
    [self setSightingAnnotationsButton:nil];
    [self setMapTypeSegmentController:nil];
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (_modalView) {
        _modalView.view.frame = modalPlaceholderView.frame;
    }
    
    UIDeviceOrientation deviceOrientation = [[UIApplication sharedApplication]statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(deviceOrientation )) {
        self.tvOverlay.image = [UIImage imageNamed:@"tvOverlayPortrait.png"];   
    }
    else {
        self.tvOverlay.image = [UIImage imageNamed:@"TVOverlay.png"];
    }
    
    
}


#pragma mark - Core Location Delegate Functions


- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"%@",newLocation);
    
}


- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region
{
    
}

- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region 
{
    
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;
{
    NSLog(@"%@", error);
}

#pragma mark - MapKit Delegate Functions


-(MKOverlayView*) mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
   return [[HeatMapOverlayView alloc] initWithOverlay:overlay];
}




- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    //NSLog(@"regionWillChangeAnimated:%@", animated ? @"YES" : @"NO");
   // MKZoomScale currentZoomScale = mapView.bounds.size.width / mapView.visibleMapRect.size.width;
    //NSLog(@"%f",currentZoomScale);

}


- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    
    NSUInteger zoomLevel = [HeatMap zoomLevelForRegion:mapView.region];
    [self.levelLabel setText:[NSString stringWithFormat:@"%d",zoomLevel]];

    if(_annotationsShowing)
    {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        
        [self updateVisibleAnnotations];   
    });    
    }
}   

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    
    SightingLocation* location = view.annotation;
    _modalView = [[MapModalView alloc]initWithSightingLocation:location];
    
    [_modalView.view setFrame:CGRectMake(79, 124, 855, 560)];    
    [self.view insertSubview:_modalView.view aboveSubview:self.myMap];
    [self addChildViewController:_modalView];
    
    
    
}


-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    
    
    for (MKAnnotationView* annotationView in views) {
        if(![annotationView.annotation isKindOfClass:[SightingLocation class]])
            continue;
        
        SightingLocation* annotation = (SightingLocation*)annotationView.annotation;
        
        if(annotation.clusterAnnotation != nil){
            CLLocationCoordinate2D containerCoordinate = annotation.clusterAnnotation.coordinate;
            annotation.clusterAnnotation = nil;
            annotation.coordinate = containerCoordinate;
            
            [UIView animateWithDuration:0.3f animations:^{
                annotation.coordinate = [annotation actualCoordinate];
            }];
            
        }
        
    }
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation;
{
    
    
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
     
    // try to dequeue an existing pin view first
    static NSString* UFOAnnotationIdentifier = @"UFOAnnotationIdentifier";
    MKPinAnnotationView* pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:UFOAnnotationIdentifier];
    if (!pinView)
    {
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:UFOAnnotationIdentifier];
        annotationView.canShowCallout = YES;
        
        UIImage *UFOPin = [UIImage imageNamed:@"ufoPin.png"];
        annotationView.image = UFOPin;
        annotationView.opaque = NO;
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        
        return annotationView;
    }
    else
    {
        pinView.annotation = annotation;
    }
    return pinView;
    
    
}


-(void)updateVisibleAnnotations
{
    static float marginFactor = 1.2f;
    static float bucketSize = 80.0f;
    
    MKMapRect visibleMaprect = [self.myMap visibleMapRect];
    MKMapRect adjustedVisibleMapRect = MKMapRectInset(visibleMaprect, -marginFactor * visibleMaprect.size.width, -marginFactor * visibleMaprect.size.height);

    CLLocationCoordinate2D leftCoordinate =  [self.myMap convertPoint:CGPointZero toCoordinateFromView:self.view];
    CLLocationCoordinate2D rightCoordinate = [self.myMap convertPoint:CGPointMake(bucketSize, 0) toCoordinateFromView:self.view];

    double gridSize = MKMapPointForCoordinate(rightCoordinate).x - MKMapPointForCoordinate(leftCoordinate).x ;
    MKMapRect gridMapRect = MKMapRectMake(0, 0, gridSize, gridSize);
    
    double startX = floor(MKMapRectGetMinX(adjustedVisibleMapRect) / gridSize) * gridSize;
    double startY = floor(MKMapRectGetMinY(adjustedVisibleMapRect) / gridSize) * gridSize;    
    double endX = floor(MKMapRectGetMaxX(adjustedVisibleMapRect) / gridSize) * gridSize;    
    double endY = floor(MKMapRectGetMaxY(adjustedVisibleMapRect)  / gridSize) * gridSize;

    gridMapRect.origin.y = startY;
    while (MKMapRectGetMinY(gridMapRect) <= endY) {
        gridMapRect.origin.x = startX;

        while (MKMapRectGetMinX(gridMapRect) <= endX) {
                  

            //********************************************************
           // NSSet* allAnnotationsInBucket = [NSSet setWithArray:[SightingLocation SightingLocationsInMapRect:gridMapRect]];
            NSSet* allAnnotationsInBucket = [_backMap annotationsInMapRect:gridMapRect];
           
            //********************************************************
            NSSet* visibleAnnotationsInBucket = [self.myMap annotationsInMapRect:gridMapRect];
           
            NSMutableSet * filteredAnnotationsInBucket = [[allAnnotationsInBucket objectsPassingTest:^BOOL(id obj, BOOL* stop) {
                return ([obj isKindOfClass:[SightingLocation class]]); 
            }] mutableCopy];
            
            if(filteredAnnotationsInBucket.count > 0) {
                SightingLocation* annotationForGrid = (SightingLocation*)[self annotationInGrid:gridMapRect usingAnnotations:filteredAnnotationsInBucket];
                
                [filteredAnnotationsInBucket removeObject: annotationForGrid];
                
                annotationForGrid.containedAnnotations = [filteredAnnotationsInBucket allObjects];
                
                [self.myMap addAnnotation:annotationForGrid];
            
                for (SightingLocation *annotation in filteredAnnotationsInBucket) {
                    annotation.clusterAnnotation = annotationForGrid;
                    annotation.containedAnnotations = nil;

                    if([visibleAnnotationsInBucket containsObject:annotation]) {

                        [UIView animateWithDuration:0.3f animations:^{
                            annotation.coordinate = annotation.clusterAnnotation.coordinate;
                            
                        } completion:^(BOOL finished){
                            annotation.coordinate = [annotation actualCoordinate];
                            [self.myMap removeAnnotation:annotation];
                        }];
                        
                    }
                }
            
            }
            
            gridMapRect.origin.x += gridSize;
        }
        
        gridMapRect.origin.y += gridSize;
    }
    
    NSLog(@"DONE");
}


- (id<MKAnnotation>)annotationInGrid:(MKMapRect)gridMapRect usingAnnotations:(NSSet*)annotations
{
    NSSet* visibleAnnotationsInBucket = [self.myMap annotationsInMapRect:gridMapRect];
    NSSet* annotationsForGridSet = [annotations objectsPassingTest:^BOOL(id obj, BOOL* stop){
        BOOL returnValue = ([visibleAnnotationsInBucket containsObject:obj]);
        if(returnValue)
            *stop = YES;
        return returnValue;
    }];
    
    if(annotationsForGridSet.count != 0){
        return  [annotationsForGridSet anyObject];
    }
    
    MKMapPoint centerMapPoint = MKMapPointMake(MKMapRectGetMidX(gridMapRect), MKMapRectGetMidY(gridMapRect));
    NSArray* sortedAnnotations = [[annotations allObjects] sortedArrayUsingComparator:^(id obj1, id obj2){
        MKMapPoint mapPoint1 = MKMapPointForCoordinate(((id<MKAnnotation>)obj1).coordinate);
        MKMapPoint mapPoint2 = MKMapPointForCoordinate(((id<MKAnnotation>)obj2).coordinate);        
        
        CLLocationDistance distance1 = MKMetersBetweenMapPoints(mapPoint1, centerMapPoint);
        CLLocationDistance distance2 = MKMetersBetweenMapPoints(mapPoint2, centerMapPoint);
        
        if (distance1 < distance2) {
            return NSOrderedAscending;
        }
        else if (distance1 > distance2) {
            return NSOrderedDescending;
        }
        
        return NSOrderedSame;
    }];

   // int num = rand() % [sortedAnnotations count];
    return [sortedAnnotations objectAtIndex:0];
    
}



-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{

    return YES;
}






#pragma mark - IBActions


- (IBAction)compassButtonSelected:(UIButton *)sender {
    
    CGAffineTransform rotate;
    CGFloat newAlpha;
    if (_mapSelectionOpen) {
        rotate = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-45));
        newAlpha = 0.0f;
    }
    else {
        rotate = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(45));
        newAlpha = 1.0f;
    }
    
    [UIView animateWithDuration:0.3 delay:0.0f options:UIViewAnimationCurveEaseInOut animations:^{
        self.mapTypeSegmentController.alpha = newAlpha;
        self.compassButton.transform = rotate;
    } completion:^(BOOL finished){
        _mapSelectionOpen = !_mapSelectionOpen;}
     
     ];
    
    
    
    
}

- (IBAction)sightingsAnnotationsButtonSelected:(UIButton *)sender {
    
    if(_annotationsShowing)
    {
        [myMap removeAnnotations:[myMap annotations]];
    }
    else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            
            [self updateVisibleAnnotations];   
        });       
    }
    
    _annotationsShowing = !_annotationsShowing;
    [sender setSelected:_annotationsShowing];
    
}

- (IBAction)mapLayerButtonSelected:(UIButton *)sender {
    
    if(_heatMapShowing)
    {
        if([[myMap overlays] containsObject:_heatMapOverlay])
            [myMap removeOverlay:_heatMapOverlay];
    }
    else {
        if(![[myMap overlays] containsObject:_heatMapOverlay])
            [myMap addOverlay:_heatMapOverlay];
    }
    
    
    _heatMapShowing = !_heatMapShowing;
    [sender setSelected:_heatMapShowing];    
}

- (IBAction)mapTypeSegmentChanged:(UISegmentedControl *)sender 
{

    [myMap setMapType:[sender selectedSegmentIndex]];
/*
    switch ([sender selectedSegmentIndex]) {
        case 0:
            [myMap setMapType:MKMapTypeStandard];
            break;
        case 1:
            [myMap setMapType:MKMapTypeSatellite];
            break;
        case 2:
            [myMap setMapType:MKMapTypeHybrid];
            break;
        case 3:
            
            break;
            
        default:
            break;
    }
    
  */  
    
    
}
@end
