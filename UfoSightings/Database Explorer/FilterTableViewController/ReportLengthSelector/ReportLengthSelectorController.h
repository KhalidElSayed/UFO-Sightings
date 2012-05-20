//
//  ReportLengthSelectorController.h
//  UfoSightings
//
//  Created by Richard Kirk on 5/16/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterViewController.h"

@interface ReportLengthSelectorController : UIViewController <PredicateCreation>
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *tileBackgroundImageViews;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *checkmarkButtons;
@property (strong, nonatomic) NSString* predicateKey;


- (IBAction)checkmarkButtonSelected:(UIButton *)sender;
-(NSPredicate*)createPredicate;
@end
