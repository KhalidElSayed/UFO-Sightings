//
//  RootViewController.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/23/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import "UFORootController.h"
#import <CoreData/CoreData.h>

@interface UFORootController ()
{
    UIViewController* _currentViewController;
    NSManagedObjectContext*     _mapContext;
    NSManagedObjectContext*     _databaseContext;
}
@property (strong, nonatomic) NSManagedObjectContext* mapContext;
@property (strong, nonatomic) NSManagedObjectContext* databaseContext;
@property (strong, nonatomic) UFOMapViewController* mapViewController;
@property (strong, nonatomic) UFODatabaseExplorerViewController* databaseViewController;
@end

@implementation UFORootController
@synthesize persistentStoreCoordinator;
@synthesize mapContext = _mapContext, databaseContext = _databaseContext;
@synthesize mapViewController = _mapViewController, databaseViewController = _databaseViewController;

-(id)init
{
    if ((self = [super init]))
    {
        self.persistentStoreCoordinator = [[UFOCoreData sharedInstance] persistentStoreCoordinator];
        
        self.mapContext = [[NSManagedObjectContext alloc]init];
        [self.mapContext setPersistentStoreCoordinator:self.persistentStoreCoordinator ];
        self.databaseContext = [[NSManagedObjectContext alloc]init];
        [self.databaseContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin| UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;

    self.view.backgroundColor = [UIColor blackColor];
    _currentViewController = self.mapViewController;
    [self.view addSubview:_currentViewController.view];
}


-(UFOMapViewController*)mapViewController
{
    if(_mapViewController)
        return _mapViewController;
   
    _mapViewController = [[UFOMapViewController alloc]init];
    _mapViewController.managedObjectContext = _mapContext;
    _mapViewController.rootController = self;
    _mapViewController.view.frame = self.view.bounds;
    
    return _mapViewController;
}


-(UFODatabaseExplorerViewController*)databaseViewController
{
    if(_databaseViewController)
        return _databaseViewController;
    
    _databaseViewController = [[UFODatabaseExplorerViewController alloc]init];
    _databaseViewController.managedObjectContext = _databaseContext;
    _databaseViewController.rootController = self;
    _databaseViewController.view.frame = self.view.bounds;
    
    return _databaseViewController;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


-(void)switchViewController
{
     UIDeviceOrientation deviceOrientation = [[UIApplication sharedApplication]statusBarOrientation];
    UIViewController* nextViewController;
    UIViewAnimationOptions animationOption;
    if([_currentViewController isKindOfClass:[UFODatabaseExplorerViewController class]])
    {
     
        if (UIInterfaceOrientationIsLandscape(deviceOrientation )) 
        {   // Setup For Landscape
            animationOption = UIViewAnimationOptionTransitionFlipFromBottom;
        }
        else 
        {   // Setup For Portrait
            animationOption = UIViewAnimationOptionTransitionFlipFromLeft;
        }

       
        nextViewController = self.mapViewController;
    }
    else 
    {
        

        if (UIInterfaceOrientationIsLandscape(deviceOrientation )) 
        {   // Setup For Landscape
             animationOption = UIViewAnimationOptionTransitionFlipFromTop;
        }
        else 
        {   // Setup For Portrait
                 animationOption = UIViewAnimationOptionTransitionFlipFromRight;   
        }

        nextViewController = self.databaseViewController;
    }
    
    nextViewController.view.frame = self.view.bounds;
     
     [UIView transitionWithView:self.view duration:1.5f options:animationOption animations:^{
         [self.view addSubview:nextViewController.view];
     } completion:^(BOOL finished){
         [_currentViewController.view removeFromSuperview];
         _currentViewController = nil;
         _currentViewController = nextViewController;
     }];
    

    
    
}


     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
@end
