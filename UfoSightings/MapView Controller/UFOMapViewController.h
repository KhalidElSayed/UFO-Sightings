//
//  UFOMapViewController.h
//  UFO Sightings
//
//  Created by Richard Kirk on 12/19/11.
//  Copyright (c) 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/Mapkit.h>

@class UFORootController;
@class UFOHeatMap;

@protocol UFOMapViewControllerDelegate;

@interface UFOMapViewController : UIViewController <CLLocationManagerDelegate,MKMapViewDelegate>
{
    CLLocationManager *locationManager;
    CLLocationCoordinate2D *userLocation;
}
@property (weak, nonatomic) id <UFOMapViewControllerDelegate> delegate;
@property (strong, nonatomic) NSManagedObjectContext* backgroundContext;
@property (strong, nonatomic) UFOHeatMap* heatMapOverlay;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIImageView *tvOverlay;
@property (weak, nonatomic) IBOutlet UIView *modalPlaceholderView;
@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet UIButton *compassButton;
@property (weak, nonatomic) IBOutlet UIButton *sightingAnnotationsButton;
@property (weak, nonatomic) IBOutlet UIButton *mapLayerButton;
@property (weak, nonatomic) IBOutlet UIButton *filterButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapTypeSegmentController;

- (IBAction)compassButtonSelected:(UIButton *)sender;
- (IBAction)sightingsAnnotationsButtonSelected:(UIButton *)sender;
- (IBAction)mapLayerButtonSelected:(UIButton *)sender;
- (IBAction)filterButtonSelected:(UIButton *)sender;
- (IBAction)xButtonSelected:(UIButton *)sender;
- (IBAction)stopFilteringSelected:(UIButton *)sender;
- (IBAction)mapTypeSegmentChanged:(UISegmentedControl *)sender;

- (void)modalWantsToDismiss;

@end

@protocol UFOMapViewControllerDelegate <NSObject>
- (void)UFOMapViewControllerWantsToExit:(UFOMapViewController*)mapController;
@end