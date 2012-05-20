//
//  ViewController.h
//  LocationFun
//
//  Created by Richard Kirk on 12/19/11.
//  Copyright (c) 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/Mapkit.h>

@class HeatMap;

@interface MapViewController : UIViewController <CLLocationManagerDelegate,MKMapViewDelegate>
{
    CLLocationManager *locationManager;
    CLLocationCoordinate2D *userLocation;
    HeatMap*    _heatMapOverlay;
    

}
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) IBOutlet MKMapView *myMap;
@property (strong, nonatomic) IBOutlet UIImageView *tvOverlay;
@property (strong, nonatomic) IBOutlet UILabel *debugLabel;
@property (strong, nonatomic) IBOutlet UIView *modalPlaceholderView;
@property (strong, nonatomic) IBOutlet UILabel *levelLabel;

@property (strong, nonatomic) IBOutlet UIButton *compassButton;
@property (strong, nonatomic) IBOutlet UIButton *sightingAnnotationsButton;
@property (strong, nonatomic) IBOutlet UIButton *mapLayerButton;

@property (strong, nonatomic) IBOutlet UISegmentedControl *mapTypeSegmentController;



- (IBAction)compassButtonSelected:(UIButton *)sender;
- (IBAction)sightingsAnnotationsButtonSelected:(UIButton *)sender;
- (IBAction)mapLayerButtonSelected:(UIButton *)sender;

- (IBAction)mapTypeSegmentChanged:(UISegmentedControl *)sender;

@end	