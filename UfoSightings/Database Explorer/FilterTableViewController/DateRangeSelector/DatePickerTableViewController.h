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
@property (strong, nonatomic) RangeSlider* slider;
@property (strong, nonatomic) NSString* predicateKey;

- (id)initWithType:(UFODatePickerType)type;

- (NSPredicate*)createPredicate;

- (BOOL)canReset;
- (void)reset;
- (void)saveState;

@end
