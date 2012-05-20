//
//  MapModalView.h
//  UfoSightings
//
//  Created by Richard Kirk on 5/9/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SliderPageControl.h"

@class PaperView;
@class SightingLocation;
@interface MapModalView : UIViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, SliderPageControlDelegate>
{
    SliderPageControl* sliderPageControl;
}
@property (strong, nonatomic) SightingLocation* location;
@property (strong, nonatomic) NSDateFormatter* df;

@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) PaperView *documentView;
@property (strong, nonatomic) IBOutlet UIView *paperViewPlaceholder;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) SliderPageControl *sliderPageControl;

- (IBAction)exitSelected:(id)sender;


-(id)initWithSightingLocation:(SightingLocation*)location;

@end
