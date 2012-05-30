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
-(void)setup;
@end

@implementation ConsoleDocumentView
@synthesize sightedAtLabel = _sightedAtLabel;
@synthesize reportedAtLabel = _reportedAtLabel;
@synthesize durationLabel = _durationLabel;
@synthesize locationLabel = _locationLabel;
@synthesize reportTextView = _reportTextView;
@synthesize staticLabels = _staticLabels;
@synthesize scrollView = _scrollView;
@synthesize report = _report;

- (id)initWithFrame:(CGRect)frame
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"ConsoleDocumentView" owner:self options:nil] lastObject];
    if (self) {
        self.frame = frame;
    }
    return self;
}

-(id)init
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"ConsoleDocumentView" owner:self options:nil] lastObject];
    if (self) {

    }
    return self;

}

-(id)initWithSighting:(Sighting*)sighting
{
    if((self = [[[NSBundle mainBundle] loadNibNamed:@"ConsoleDocumentView" owner:self options:nil] lastObject]))
    {
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
-(void)setup
{
    
    UIFont* andale = [UIFont fontWithName:@"AndaleMono" size:18.0f];
    
    for (UILabel* staticLabel in _staticLabels) {
        [staticLabel setFont:andale];
    }
    [_sightedAtLabel setFont:andale];
    [_reportedAtLabel setFont:andale];
    [_durationLabel setFont:andale];
    [_reportTextView setFont:andale];

    [_locationLabel setFont:[UIFont fontWithName:@"AndaleMono" size:22.0f]];

        
    
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize constraint = CGSizeMake(_reportTextView.bounds.size.width, 99999999.0f);
    CGSize size = [_report sizeWithFont:[UIFont fontWithName:@"AndaleMono" size:18] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    CGRect frame =  _reportTextView.frame;
    frame.size.height = size.height + 50;
    _reportTextView.frame = frame;
    _scrollView.contentSize = CGSizeMake(1, _reportTextView.frame.origin.y + size.height + 90);
    
    _reportTextView.text = _report;
    
    
    self.scrollView.contentOffset = CGPointZero;
    
}



-(void)setReport:(NSString *)report
{
         _report = report;
}


@end
