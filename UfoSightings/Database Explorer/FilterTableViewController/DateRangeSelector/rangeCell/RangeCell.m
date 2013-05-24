//
//  RangeCell.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/15/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import "RangeCell.h"

@implementation RangeCell
@synthesize minLabel;
@synthesize maxLabel;

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.slider.minimumRange = 1;
    self.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"greyCellBackground.png"]];
    
    [self.slider removeFromSuperview];
    self.slider.center = self.center;
    [self addSubview:self.slider];
    
}

@end
