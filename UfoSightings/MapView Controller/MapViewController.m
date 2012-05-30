//
//  ViewController.m
//  LocationFun
//
//  Created by Richard Kirk on 12/19/11.
//  Copyright (c) 2011 Home. All rights reserved.
//

#import "MapViewController.h"
#import "RootController.h"
#import "Sighting.h"
#import "HeatMap.h"
#import "MapModalView.h"


#define DEGREES_TO_RADIANS(angle) (angle / 180.0 * M_PI)
static dispatch_queue_t annons_background_queue;
dispatch_queue_t annotations_background_queue()
{
    if (annons_background_queue == NULL)
    {
        annons_background_queue = dispatch_queue_create("com.richardKirk.annotations.backgroundfetches", DISPATCH_QUEUE_SERIAL);
    }
    return annons_background_queue;
}


@interface MapViewController()
{
    MKMapView *_backMap;
    NSArray* _allSightings;
    MapModalView*   _modalView;
    bool            _mapSelectionOpen;
    bool            _annotationsShowing;
    bool            _heatMapShowing;
    MKAnnotationView*   _selectedAnnotationView;

}
- (void)updateVisibleAnnotations;
- (id<MKAnnotation>)annotationInGrid:(MKMapRect)gridMapRect usingAnnotations:(NSSet*)annotations;
-(void)reloadSightingLocationsWithPredicate:(NSPredicate*)pred;
-(void)showAlert;
-(void)hideAlert;
@end

@implementation MapViewController
@synthesize managedObjectContext;
@synthesize rootController;
@synthesize predicate = _predicate;
@synthesize myMap = _myMap;
@synthesize tvOverlay;
@synthesize modalPlaceholderView = _modalPlaceholderView;
@synthesize compassButton, sightingAnnotationsButton, mapLayerButton, filterButton, mapTypeSegmentController;;
@synthesize loadingIndicator = _loadingIndicator;
@synthesize levelLabel;
@synthesize alertView;


//***************************************************************************************************
#pragma mark - View lifecycle
//***************************************************************************************************
-(id)init
{
    if((self = [super init]))
    {
        _heatMapOverlay = [[HeatMap alloc]init];
        _backMap = [[MKMapView alloc]initWithFrame:CGRectZero];
        _mapSelectionOpen = NO;
    }
    return self;
}


-(void)viewWillAppear:(BOOL)animated
{
    if(_predicate)
    {
        [self showAlert];
    } 
    [self reloadSightingLocationsWithPredicate:_predicate];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    MKCoordinateRegion region = {{ 36.102376, -119.091797}, {32.451446, 28.125000}};
    [_myMap setRegion:region];       

    NSInteger mapType = [[NSUserDefaults standardUserDefaults] integerForKey:@"mapType"];
    [_myMap setMapType:mapType];
    [self.mapTypeSegmentController setSelectedSegmentIndex:mapType];
    
    _annotationsShowing = [[NSUserDefaults standardUserDefaults] boolForKey:@"annotationsOn"];
    [self.sightingAnnotationsButton setSelected:_annotationsShowing];
 
    _heatMapOverlay.managedObjectContext = self.managedObjectContext;    

    _heatMapShowing = [[NSUserDefaults standardUserDefaults] boolForKey:@"heatMapOverlayOn"]; 
    [self.mapLayerButton setSelected:_heatMapShowing];
    if(_heatMapShowing)
    {
        [_myMap addOverlay:_heatMapOverlay];
    }
       
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
    dispatch_release(annotations_background_queue());
    [self setMyMap:nil];
    [self setLevelLabel:nil];
    _heatMapOverlay = nil;
    _backMap = nil;
    [self setTvOverlay:nil];
    [self setModalPlaceholderView:nil];
    [self setCompassButton:nil];
    [self setMapLayerButton:nil];
    [self setSightingAnnotationsButton:nil];
    [self setMapTypeSegmentController:nil];
    [self setFilterButton:nil];
    [self setAlertView:nil];
    [self setLoadingIndicator:nil];
    [super viewDidUnload];
}


-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (_modalView) {
        _modalView.view.frame = _modalPlaceholderView.frame;
    }
    
    UIDeviceOrientation deviceOrientation = [[UIApplication sharedApplication]statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(deviceOrientation )) {
        self.tvOverlay.image = [UIImage imageNamed:@"tvOverlayPortrait.png"];   
    }
    else {
        self.tvOverlay.image = [UIImage imageNamed:@"TVOverlay.png"];
    }
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{    
    return YES;
}


-(void)modalWantsToDismiss
{
    [_modalView.view removeFromSuperview];
    _modalView = nil;
    [_myMap setUserInteractionEnabled:YES];
    
}
//***************************************************************************************************





//***************************************************************************************************
#pragma mark - IBActions
//***************************************************************************************************
- (IBAction)compassButtonSelected:(UIButton *)sender 
{    
    CGAffineTransform rotate;
    CGFloat newAlpha;
    if (_mapSelectionOpen) 
    {
        rotate = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-45));
        newAlpha = 0.0f;
    }
    else
    {
        rotate = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(45));
        newAlpha = 1.0f;
    }
    
    [UIView animateWithDuration:0.3 delay:0.0f options:UIViewAnimationCurveEaseInOut animations:^{
        self.mapTypeSegmentController.alpha = newAlpha;
        self.compassButton.transform = rotate;
    } completion:^(BOOL finished){
        _mapSelectionOpen = !_mapSelectionOpen;
    }];
}


- (IBAction)sightingsAnnotationsButtonSelected:(UIButton *)sender 
{
    if(_annotationsShowing)
        [_myMap removeAnnotations:[_myMap annotations]];
    else 
        [self updateVisibleAnnotations];   

    _annotationsShowing = !_annotationsShowing;
    [sender setSelected:_annotationsShowing];    
}


- (IBAction)mapLayerButtonSelected:(UIButton *)sender {
    
    if(_heatMapShowing)
    {
        if([[_myMap overlays] containsObject:_heatMapOverlay])
            [_myMap removeOverlay:_heatMapOverlay];
    }
    else 
    {
        if(![[_myMap overlays] containsObject:_heatMapOverlay])
            [_myMap addOverlay:_heatMapOverlay];
    }
    _heatMapShowing = !_heatMapShowing;
    [sender setSelected:_heatMapShowing];    
}


- (IBAction)filterButtonSelected:(UIButton *)sender 
{
    [self.rootController switchViewController];
}


- (IBAction)xButtonSelected:(UIButton *)sender 
{
    [self hideAlert];
}


-(IBAction)userLocationButtonSelected:(UIButton*)sender
{
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
    [_myMap setShowsUserLocation:YES];
}


- (IBAction)stopFilteringSelected:(UIButton *)sender 
{
    _predicate = nil;
    [self reloadSightingLocationsWithPredicate:_predicate];
}


- (IBAction)mapTypeSegmentChanged:(UISegmentedControl *)sender 
{
    [_myMap setMapType:[sender selectedSegmentIndex]];
}


-(void)reloadSightingLocationsWithPredicate:(NSPredicate*)pred
{
    if(pred)
        [self showAlert];
    else
        [self hideAlert];

    
    [_myMap removeAnnotations:[_myMap annotations]];
    [_backMap removeAnnotations:[_backMap annotations]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{

        if(pred)
        {
            NSArray* array = [Sighting allSightingsWithPredicate:pred];
            NSMutableSet* set = [[NSMutableSet alloc]init];
            for (Sighting* sighting in array) {
                [set addObject:sighting.location];
            }
        
        _allSightings = [set allObjects];
        }
        else 
        _allSightings = [SightingLocation allSightings];
        
        NSLog(@"%i",_allSightings.count);
        [_backMap addAnnotations:_allSightings];   

        dispatch_sync(dispatch_get_main_queue(), ^{
            if(_annotationsShowing)
                [self updateVisibleAnnotations];   
            
        });
        
    });

}
//***************************************************************************************************




//***************************************************************************************************
#pragma mark - MapKit Delegate Functions
//***************************************************************************************************
-(MKOverlayView*) mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
   return [[HeatMapOverlayView alloc] initWithOverlay:overlay];
}


- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if(_annotationsShowing)
    {   
        _selectedAnnotationView.selected = NO;
        [self updateVisibleAnnotations];   
        
    }
}   


-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [_myMap setUserInteractionEnabled:YES];
    SightingLocation* location = view.annotation;
    _modalView = [[MapModalView alloc]initWithSightingLocation:location andPredicate:_predicate];
    [_modalView.view setFrame:CGRectMake(79, 124, 855, 560)];    
    [self.view insertSubview:_modalView.view belowSubview:[[self.view subviews] lastObject]];
    [self addChildViewController:_modalView];
    view.selected = NO;
}
    

-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    for (MKAnnotationView* annotationView in views) {
        if(![annotationView.annotation isKindOfClass:[SightingLocation class]])
            continue;
        
        annotationView.alpha = 0.0f;
        [UIView animateWithDuration:0.5 animations:^{
            annotationView.alpha = 1.0f;
        }];
    }
}


-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{   
    _selectedAnnotationView = view;
    UILabel* label;
    UIActivityIndicatorView* loadingView;
    for (UIView* subview in [view.leftCalloutAccessoryView subviews]) {
        if ([subview isKindOfClass:[UILabel class]]) {
            label = (UILabel*)subview;
        }
        else if ([subview isKindOfClass:[UIActivityIndicatorView class]]) {
            loadingView = (UIActivityIndicatorView*)subview;
        }
    }
    [loadingView startAnimating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        SightingLocation* annotation =  view.annotation;
        NSString* newTitle = @"";
        
        NSUInteger sightingsCount = 1; 
        NSUInteger citiesCount = 1;
        if(annotation.sighting)
            sightingsCount = annotation.sighting.count;
        
        if (annotation.containedAnnotations != nil && annotation.containedAnnotations.count > 0) 
        {
            if(_predicate)
            {
                NSMutableSet* sightingsSet = [[NSMutableSet alloc]init];
                NSMutableSet* citiesSet = [[NSMutableSet alloc]init];
                [sightingsSet unionSet:annotation.sighting];
                
                for (SightingLocation* location in annotation.containedAnnotations) {
                    [sightingsSet unionSet:location.sighting];
                }
                [sightingsSet filterUsingPredicate:_predicate];
                
                for (Sighting* sighting in sightingsSet) {
                    [citiesSet addObject:sighting.location];
                }
                
                citiesCount = citiesSet.count;
                sightingsCount = sightingsSet.count;                
                
            }
            else {
             
                citiesCount += annotation.containedAnnotations.count;
                                
                for (SightingLocation* location in annotation.containedAnnotations) {
                    if(location.sighting != nil)
                        sightingsCount += location.sighting.count;
                    else
                        sightingsCount += 1;
                }
            }   

       
        }
        newTitle = [NSString stringWithFormat:@"%i sightings in %i cities", sightingsCount, citiesCount];
        dispatch_sync(dispatch_get_main_queue(), ^{
        [loadingView stopAnimating];
        [label setText:newTitle];
            
        });
        
    });
}


-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    
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
        
        UIView* leftCalloutView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
        
        UIActivityIndicatorView* loadingIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [loadingIndicator setHidesWhenStopped:YES];
        
        [leftCalloutView addSubview:loadingIndicator];
        loadingIndicator.center = leftCalloutView.center;
        
        UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
        [label setTextColor:[UIColor whiteColor]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16.0f]];
        [label setTextAlignment:UITextAlignmentCenter];
        [label setAdjustsFontSizeToFitWidth:YES];
        [label setMinimumFontSize:6.0f];
        [leftCalloutView addSubview:label];
        annotationView.leftCalloutAccessoryView = leftCalloutView;
        return annotationView;
    }
    else
    {
        pinView.annotation = annotation;
    }
    return pinView;
    
    
}
//***************************************************************************************************





//***************************************************************************************************
#pragma mark - MapPin Clustering 
//***************************************************************************************************
-(void)updateVisibleAnnotations
{

    [self.loadingIndicator startAnimating];
    dispatch_async(annotations_background_queue(), ^{        
        
    static float marginFactor = 0;
    static float bucketSize = 80.0f;
    
    MKMapRect visibleMaprect = [_myMap visibleMapRect];
    MKMapRect adjustedVisibleMapRect = MKMapRectInset(visibleMaprect, -marginFactor * visibleMaprect.size.width, -marginFactor * visibleMaprect.size.height);
    
    CLLocationCoordinate2D leftCoordinate =  [_myMap convertPoint:CGPointZero toCoordinateFromView:self.view];
    CLLocationCoordinate2D rightCoordinate = [_myMap convertPoint:CGPointMake(bucketSize, 0) toCoordinateFromView:self.view];
    
    double gridSize = MKMapPointForCoordinate(rightCoordinate).x - MKMapPointForCoordinate(leftCoordinate).x ;
    MKMapRect gridMapRect = MKMapRectMake(0, 0, gridSize, gridSize);
    
    double startX = floor(MKMapRectGetMinX(adjustedVisibleMapRect) / gridSize) * gridSize;
    double startY = floor(MKMapRectGetMinY(adjustedVisibleMapRect) / gridSize) * gridSize;    
    double endX = floor(MKMapRectGetMaxX(adjustedVisibleMapRect) / gridSize) * gridSize;    
    double endY = floor(MKMapRectGetMaxY(adjustedVisibleMapRect)  / gridSize) * gridSize;
    NSMutableSet* setToAdd = [[NSMutableSet alloc]init ];
        NSMutableSet* setToRemove = [[NSMutableSet alloc]init];
    gridMapRect.origin.y = startY;
    while (MKMapRectGetMinY(gridMapRect) <= endY) {
        gridMapRect.origin.x = startX;
        
        while (MKMapRectGetMinX(gridMapRect) <= endX) {
          

            
            //********************************************************
            // NSSet* allAnnotationsInBucket = [NSSet setWithArray:[SightingLocation SightingLocationsInMapRect:gridMapRect]];
            NSSet* allAnnotationsInBucket = [_backMap annotationsInMapRect:gridMapRect];
            
            //********************************************************
            NSSet* visibleAnnotationsInBucket = [_myMap annotationsInMapRect:gridMapRect];
            
          //  NSMutableSet * filteredAnnotationsInBucket = [[allAnnotationsInBucket objectsPassingTest:^BOOL(id obj, BOOL* stop) {
            //    return ([obj isKindOfClass:[SightingLocation class]]); 
           // }] mutableCopy];
          
            NSMutableSet* filteredAnnotationsInBucket = [allAnnotationsInBucket mutableCopy];
            
            if(filteredAnnotationsInBucket.count > 0) {
                
               SightingLocation* annotationForGrid  = (SightingLocation*)[self annotationInGrid:gridMapRect usingAnnotations:filteredAnnotationsInBucket];
                
                
                [filteredAnnotationsInBucket removeObject: annotationForGrid];
                
                annotationForGrid.containedAnnotations = [filteredAnnotationsInBucket allObjects];
                
                //[_myMap addAnnotation:annotationForGrid];
                [setToAdd addObject:annotationForGrid];
    
                    for (SightingLocation *annotation in filteredAnnotationsInBucket) {
                        
    
                        annotation.clusterAnnotation = annotationForGrid;
                        annotation.containedAnnotations = nil;
                        
                        if([visibleAnnotationsInBucket containsObject:annotation]) {
                            
                            [setToRemove addObject:annotation];

                            
                        }
                        
                    }
                
            }
            
            gridMapRect.origin.x += gridSize;
        }
        
        gridMapRect.origin.y += gridSize;
    }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
          
            [_myMap removeAnnotations:[setToRemove allObjects]];
            [_myMap addAnnotations:[setToAdd allObjects]];
          
            [self.loadingIndicator stopAnimating];
            
        });
        
    }); 
}


- (id<MKAnnotation>)annotationInGrid:(MKMapRect)gridMapRect usingAnnotations:(NSSet*)annotations
{
    NSSet* visibleAnnotationsInBucket = [_myMap annotationsInMapRect:gridMapRect];
    NSSet* annotationsForGridSet = [annotations objectsPassingTest:^BOOL(id obj, BOOL* stop){
        BOOL returnValue = ([visibleAnnotationsInBucket containsObject:obj]);
        if(returnValue)
            *stop = YES;
        return returnValue;
    }];
    
    if(annotationsForGridSet.count != 0){
        return  [annotationsForGridSet anyObject];
    }
    
    if(annotations.count < 10)
        return [annotations anyObject];
    
    NSMutableArray* annotationsToOrder = [[annotations allObjects] mutableCopy];
    if (annotationsToOrder.count > 30) {

        [annotationsToOrder removeObjectsInRange:NSMakeRange(29, annotationsToOrder.count - 30)]; 

    }
   
    NSArray* sortedAnnotations;
    MKMapPoint centerMapPoint = MKMapPointMake(MKMapRectGetMidX(gridMapRect), MKMapRectGetMidY(gridMapRect));
        
            sortedAnnotations = [annotationsToOrder sortedArrayUsingComparator:^(id obj1, id obj2){
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
    

    
    
    return [sortedAnnotations objectAtIndex:0];
    
}
//***************************************************************************************************





//***************************************************************************************************
#pragma mark - Alert View
//***************************************************************************************************
-(void)showAlert
{
    if(alertView && alertView.frame.size.height == 0)
    {
        CGRect frame = alertView.frame;
        frame.size.height = 90;
        [UIView animateWithDuration:1.0f animations:^{
            alertView.frame = frame;
        }];
    }
}


-(void)hideAlert
{
    
    if(alertView &&  alertView.frame.size.height == 90)
    {
        CGRect frame = alertView.frame;
        frame.size.height = 0;
        [UIView animateWithDuration:1.0f animations:^{
            alertView.frame = frame;
        }];
    }
}

@end
