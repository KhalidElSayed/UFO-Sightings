//
//  ShapeSelectorViewController.h
//  UfoSightings
//
//  Created by Richard Kirk on 5/16/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterViewController.h"

@interface ShapeSelectorViewController : UIViewController <UIScrollViewDelegate, PredicateCreation> 

@property (strong, nonatomic) NSArray* shapes;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSString* predicateKey;
-(NSPredicate*)createPredicate;

@end
