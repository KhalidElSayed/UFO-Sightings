//
//  UIColor+RKColor.m
//  Major grid
//
//  Created by Richard Kirk on 1/14/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import "UIColor+RKColor.h"

@implementation UIColor (RKColor)

+(UIColor *)randomColor
{
    CGFloat red =  (CGFloat)random()/(CGFloat)RAND_MAX;
    CGFloat blue = (CGFloat)random()/(CGFloat)RAND_MAX;
    CGFloat green = (CGFloat)random()/(CGFloat)RAND_MAX;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

+(UIColor *)rgbColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:(red / 255.0f) green:(green / 255.0f) blue:(blue / 255.0f) alpha:alpha];
}


@end


