//
//  ShapeButton.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/16/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import "ShapeButton.h"

@implementation ShapeButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.minimumFontSize = 6;
        self.titleLabel.textAlignment = UITextAlignmentCenter;
        [self.imageView setContentMode:UIViewContentModeCenter];
        [self setAdjustsImageWhenHighlighted:NO];

    }
    return self;
}


- (void)layoutSubviews
{
	[super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(2, 61, 75, 16);
    self.imageView.frame = self.bounds;
        [self.imageView setContentMode:UIViewContentModeCenter];
}

- (void)setShape:(NSString*)shape
{


UIImage* backgroundImage = [[UIImage imageNamed:@"greyBoxStrechable.png"] stretchableImageWithLeftCapWidth:3 topCapHeight:3];

UIImage* shapeImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",shape]];
UIImage* shapeImageSelected = [UIImage imageNamed:[NSString stringWithFormat:@"%@Selected.png",shape]];

    [self setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [self setBackgroundImage:backgroundImage forState:UIControlStateSelected];
    [self setImage:shapeImage forState:UIControlStateNormal];
    [self setImage:shapeImage forState:UIControlStateHighlighted];
    [self setImage:shapeImageSelected forState:UIControlStateSelected];

[self setTitle:[shape capitalizedString] forState:UIControlStateNormal];
[self setTitle:[shape capitalizedString] forState:UIControlStateSelected];


}
@end
