//
//  MapModalCell.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/9/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import "MapModalCell.h"

@implementation MapModalCell
@synthesize label;
@synthesize arrowImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
        [self.arrowImage setAlpha:1.0f];
    }
    else {
        [self.arrowImage setAlpha:0.0f];
    }

    
    // Configure the view for the selected state
}

@end
