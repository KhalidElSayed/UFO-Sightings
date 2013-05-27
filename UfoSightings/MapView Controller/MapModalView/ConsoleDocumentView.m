//
//  ConsoleDocumentView.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/27/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import "ConsoleDocumentView.h"
#import "Sighting.h"
@interface ConsoleDocumentView()
- (void)setup;
@end

@implementation ConsoleDocumentView

- (id)init
{
    return [[[NSBundle mainBundle] loadNibNamed:@"ConsoleDocumentView" owner:self options:nil] lastObject];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [self init];
    if(self) {
        self.frame = frame;
    }
    return self;
}

- (id)initWithSighting:(Sighting*)sighting
{
    self = [self init];
    if(self) {
        _scrollView.contentOffset = CGPointZero;
        [self setup];
        [self setReport:sighting.report];
        NSDateFormatter* df = [[NSDateFormatter alloc]init];
        [df setDateStyle:NSDateFormatterMediumStyle];
        _sightedAtLabel.text = [df stringFromDate:sighting.sightedAt];
        _reportedAtLabel.text = [df stringFromDate:sighting.reportedAt];
        _durationLabel.text = [sighting.duration compare:@""] == 0 ? @"(empty)" : sighting.duration;
        _locationLabel.text = sighting.location.formattedAddress;
    }
    return self;
}


- (void)setup
{
    UIFont* andale = [UIFont fontWithName:@"AndaleMono" size:18.0f];
    
    for (UILabel* staticLabel in self.staticLabels) {
        [staticLabel setFont:andale];
    }
    [self.sightedAtLabel setFont:andale];
    [self.reportedAtLabel setFont:andale];
    [self.durationLabel setFont:andale];
    [self.reportTextView setFont:andale];

    [self.locationLabel setFont:[UIFont fontWithName:@"AndaleMono" size:22.0f]];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize constraint = CGSizeMake(self.reportTextView.bounds.size.width, 99999999.0f);
    CGSize size = [self.report sizeWithFont:[UIFont fontWithName:@"AndaleMono" size:18] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    
    CGRect frame =  self.reportTextView.frame;
    frame.size.height = size.height + 50;
    self.reportTextView.frame = frame;
    self.scrollView.contentSize = CGSizeMake(1, _reportTextView.frame.origin.y + size.height + 90);
    
    self.reportTextView.text = self.report;
    
    self.scrollView.contentOffset = CGPointZero;
}


@end
