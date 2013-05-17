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

- (id)init
{
    return [[[NSBundle mainBundle] loadNibNamed:@"PaperView" owner:self options:nil] lastObject];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [self init];
    if (self) {
        self.frame = frame;
    }
    return self;
}


- (void)randomize
{
    self.topImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"top%i.png", rand()% MAX_RAND]];
    self.leftImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"left%i.png", rand()% MAX_RAND]];
    self.rightImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"right%i.png", rand()% MAX_RAND]];
    self.BottomImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"bottom%i.png", rand()% MAX_RAND]];
    [self setNeedsLayout];
}

@end
