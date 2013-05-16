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

@interface FilterViewController : UITableViewController <UINavigationControllerDelegate, PredicateCreation>

@property (weak, atomic) NSMutableDictionary* filterDict;
@property (strong, nonatomic)NSString* predicateKey;
- (BOOL)canReset;
- (void)reset;

@end


