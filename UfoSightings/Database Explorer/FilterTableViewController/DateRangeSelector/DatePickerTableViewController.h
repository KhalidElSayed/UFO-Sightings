//
//  DatePickerTableViewController.h
//  UfoSightings
//
//  Created by Richard Kirk on 5/15/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RangeSlider.h"
#import "UFOFilterViewController.h"
#import "UFOBaseViewController.h"

typedef enum {
    UFODatePickerTypeSightedAt,
    UFODatePickerTypeReportedAt
} UFODatePickerType;

@interface DatePickerTableViewController : UFOBaseTableViewController <UFOPredicateCreation>
@property (assign, nonatomic) UFODatePickerType pickerType;
@property (strong, nonatomic) NSDateFormatter* dateFormatter;
@property (strong, nonatomic) UILabel* rangeLabel;
@property (weak, nonatomic) RangeSlider* cellSlider;

- (id)initWithType:(UFODatePickerType)type;

@end
