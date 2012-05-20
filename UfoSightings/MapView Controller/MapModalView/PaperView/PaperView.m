//
//  PaperView.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/8/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import "PaperView.h"

#define MAX_RAND 3

@implementation PaperView
@synthesize topImageView;
@synthesize leftImageView;
@synthesize rightImageView;
@synthesize BottomImageView;
@synthesize sightedLabel;
@synthesize ReportedLabel;
@synthesize durationLabel;
@synthesize reportTextView;

- (id)initWithFrame:(CGRect)frame
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"PaperView" owner:self options:nil] lastObject];
    if (self) {
        // Initialization code
        self.frame = frame;
    }
    return self;
}


- (id)init
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"PaperView" owner:self options:nil] lastObject];
    if (self) {
        // Initialization code

    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
       // [[[NSBundle mainBundle] loadNibNamed:@"PaperView" owner:self options:nil] lastObject];
    }
    return self;

    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/



-(void)randomize
{
    topImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"top%i.png", rand()% MAX_RAND]];
    leftImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"left%i.png", rand()% MAX_RAND]];
    rightImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"right%i.png", rand()% MAX_RAND]];
    BottomImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"bottom%i.png", rand()% MAX_RAND]];
    [self setNeedsLayout];
}

@end
