//
//  MapModalCell.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/9/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import "MapModalCell.h"

@implementation MapModalCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
        [self.arrowImage setAlpha:1.0f];
    }
    else {
        [self.arrowImage setAlpha:0.0f];
    }
}

@end
