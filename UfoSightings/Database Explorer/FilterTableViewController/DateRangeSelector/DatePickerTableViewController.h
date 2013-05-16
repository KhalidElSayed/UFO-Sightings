//
//  DatePickerTableViewController.h
//  UfoSightings
//
//  Created by Richard Kirk on 5/15/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RangeSlider.h"
#import "FilterViewController.h"

@interface DatePickerTableViewController : UITableViewController <PredicateCreation>

@property (strong, nonatomic) RangeSlider* slider;
@property (strong, nonatomic) NSString* predicateKey;
@property (weak, atomic) NSMutableDictionary* filterDict;


- (NSPredicate*)createPredicate;

- (BOOL)canReset;
- (void)reset;
- (void)saveState;

@end
