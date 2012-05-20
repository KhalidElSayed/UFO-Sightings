//
//  MasterCell.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/14/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import "MasterCell.h"

@implementation MasterCell
@synthesize mainLabel;

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

    // Configure the view for the selected state
}

@end
