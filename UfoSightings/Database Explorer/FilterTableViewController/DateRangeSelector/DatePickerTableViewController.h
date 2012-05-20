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
@property (strong, nonatomic) NSString* attribute;
@property (strong, nonatomic) NSString* predicateKey;
-(NSPredicate*)createPredicate;

@end
