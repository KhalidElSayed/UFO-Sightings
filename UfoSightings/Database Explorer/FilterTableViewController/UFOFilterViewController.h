//
//  FilterViewController.h
//  UfoSightings
//
//  Created by Richard Kirk on 5/15/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UFODatabaseExplorerViewController.h"
#import "UIColor+RKColor.h"
#import "UFOBaseViewController.h"

@interface UFOFilterViewController : UFOBaseTableViewController <UINavigationControllerDelegate, UFOPredicateCreation>

@property (strong, nonatomic, readonly) NSArray* filterCells;

@end


