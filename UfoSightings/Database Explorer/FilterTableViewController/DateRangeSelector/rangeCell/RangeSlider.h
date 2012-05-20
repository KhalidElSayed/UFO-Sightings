//
//  RangeSlider.h
//  RangeSlider
//
//  Created by Mal Curtis on 5/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SliderValueViewController.h"
@interface RangeSlider : UIControl{
    float minimumValue;
    float maximumValue;
    float minimumRange;
    float selectedMinimumValue;
    float selectedMaximumValue;
    float distanceFromCenter;

    float _padding;
    
    BOOL _maxThumbOn;
    BOOL _minThumbOn;
    
   SliderValueViewController *leftSliderValueController;
   SliderValueViewController *rightSliderValueController;
    UIPopoverController*    leftPopOver;
    UIPopoverController*    rightPopOver;
    
    UIImageView * _minThumb;
    UIImageView * _maxThumb;
    UIImageView * _track;
    UIImageView * _trackBackground;
}

@property(nonatomic) float minimumValue;
@property(nonatomic) float maximumValue;
@property(nonatomic) float minimumRange;
@property(nonatomic) float selectedMinimumValue;
@property(nonatomic) float selectedMaximumValue;
@property(strong, nonatomic) UIImageView* minThumb;
@property(strong, nonatomic) UIImageView* maxThumb;

@end
