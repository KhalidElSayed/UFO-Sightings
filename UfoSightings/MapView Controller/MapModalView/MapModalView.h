//
//  MapModalView.h
//  UfoSightings
//
//  Created by Richard Kirk on 5/9/12.
//  Copyright (c) 2012 Home. All rights reserved.
//
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "SliderPageControl.h"

@class PaperView;
@class SightingLocation;

@interface MapModalView : UIViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, SliderPageControlDelegate>
@property (strong, nonatomic) SightingLocation* location;
@property (strong, nonatomic) SliderPageControl* sliderPageControl;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *headerLabel;
@property (strong, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) IBOutlet UILabel *loadingLabel;
@property (strong, nonatomic) NSPredicate* predicate;

- (IBAction)exitSelected:(id)sender;

- (id)initWithSightingLocation:(SightingLocation*)location andPredicate:(NSPredicate*)pred;

@end
