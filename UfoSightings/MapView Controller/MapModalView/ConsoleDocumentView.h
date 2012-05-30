//
//  ConsoleDocumentView.h
//  UfoSightings
//
//  Created by Richard Kirk on 5/27/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Sighting;
@interface ConsoleDocumentView : UIView <UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *sightedAtLabel;
@property (strong, nonatomic) IBOutlet UILabel *reportedAtLabel;
@property (strong, nonatomic) IBOutlet UILabel *durationLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UITextView *reportTextView;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *staticLabels;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) NSString* report;

-(id)initWithSighting:(Sighting*)sighting;

@end
