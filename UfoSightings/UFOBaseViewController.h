//
//  UFOBaseViewController.h
//  UfoSightings
//
//  Created by Richard Kirk on 5/16/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UFOCoreData.h"

@interface UFOBaseViewController : UIViewController

- (NSManagedObjectContext*)managedObjectContext;

@end
