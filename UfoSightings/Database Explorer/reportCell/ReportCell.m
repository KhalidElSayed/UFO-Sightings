//
//  ReportCell.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/14/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import "ReportCell.h"

@implementation ReportCell
@synthesize sightedLabel;
@synthesize reportedLabel;
@synthesize reportTextView;
@synthesize shapeImageView;
@synthesize locationLabel;

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


- (CGFloat)mySize
{
   return reportTextView.frame.origin.y + reportTextView.contentSize.height + 5.0f;
}


@end
