//
//  RootViewController.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/23/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import "RootController.h"

@interface RootController ()
{
    UIViewController* _currentViewController;
    NSManagedObjectContext*     _mapContext;
    NSManagedObjectContext*     _databaseContext;
}
@property (strong, nonatomic) NSManagedObjectContext* mapContext;
@property (strong, nonatomic) NSManagedObjectContext* databaseContext;
@property (strong, nonatomic) MapViewController* mapViewController;
@property (strong, nonatomic) DatabaseExplorerViewController* databaseViewController;
@end

@implementation RootController
@synthesize persistentStoreCoordinator;
@synthesize mapContext = _mapContext, databaseContext = _databaseContext;
@synthesize mapViewController = _mapViewController, databaseViewController = _databaseViewController;
-(id)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator*)persistentStoreCor
{
    if ((self = [super init]))
    {
        self.persistentStoreCoordinator = persistentStoreCor;
        
        self.mapContext = [[NSManagedObjectContext alloc]init];
        [self.mapContext setPersistentStoreCoordinator:persistentStoreCor ];
        self.databaseContext = [[NSManagedObjectContext alloc]init];
        [self.databaseContext setPersistentStoreCoordinator:persistentStoreCor];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin| UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;

    switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"CurrentControllerShowing"]) {
        case 0:
                _currentViewController = self.mapViewController;
            break;
        case 1:
                _currentViewController = self.databaseViewController;
            break;
        default:
            break;
    }
    self.view.backgroundColor = [UIColor blackColor];

    [self.view addSubview:_currentViewController.view];
}


-(MapViewController*)mapViewController
{
    if(_mapViewController)
        return _mapViewController;
   
    _mapViewController = [[MapViewController alloc]init];
    _mapViewController.managedObjectContext = _mapContext;
    _mapViewController.rootController = self;
    _mapViewController.view.frame = self.view.bounds;
    
    return _mapViewController;
}


-(DatabaseExplorerViewController*)databaseViewController
{
    if(_databaseViewController)
        return _databaseViewController;
    
    _databaseViewController = [[DatabaseExplorerViewController alloc]init];
    _databaseViewController.managedObjectContext = _databaseContext;
    _databaseViewController.rootController = self;
    _databaseViewController.view.frame = self.view.bounds;
    
    return _databaseViewController;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    if([_currentViewController isKindOfClass:[DatabaseExplorerViewController class]])
    {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"CurrentControllerShowing"];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"CurrentControllerShowing"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
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
    if([_currentViewController isKindOfClass:[DatabaseExplorerViewController class]])
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
