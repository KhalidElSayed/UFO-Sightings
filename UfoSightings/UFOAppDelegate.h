//
//  AppDelegate.h
//  UfoSightings
//
//  Created by Richard Kirk on 4/28/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UFORootController.h"

@interface UFOAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UFORootController* rootViewController;

- (void)setupDefaults;

@end
