//
//  ReportLengthSelectorController.h
//  UfoSightings
//
//  Created by Richard Kirk on 5/16/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UFOFilterViewController.h"
#import "UFOBaseViewController.h"

@interface ReportLengthSelectorController : UFOBaseViewController <UFOPredicateCreation>

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *tileBackgroundImageViews;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *checkmarkButtons;

- (IBAction)checkmarkButtonSelected:(UIButton *)sender;

- (NSPredicate*)createPredicate;
- (BOOL)canReset;
- (void)reset;
- (void)saveState;

@end
