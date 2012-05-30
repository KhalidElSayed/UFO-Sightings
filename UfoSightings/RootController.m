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
}


@end

@implementation RootController
@synthesize managedObjectContext;


-(id)initWithManagedObjectContext:(NSManagedObjectContext*)context
{
    if ((self = [super init]))
    {
        self.managedObjectContext = context;
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin| UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    }
return self;

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    

    if([[NSUserDefaults standardUserDefaults] integerForKey:@"CurrentControllerShowing"]) 
    {
        switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"CurrentControllerShowing"]) {
            case 0:
                _mapViewController = [[MapViewController alloc]init];
                _mapViewController.managedObjectContext = self.managedObjectContext;
                _mapViewController.rootController = self;
                _mapViewController.view.frame = self.view.bounds;
                _currentViewController = _mapViewController;
                break;
            case 1:
                _databaseViewController = [[DatabaseExplorerViewController alloc]init];
                _databaseViewController.managedObjectContext = self.managedObjectContext;
                _databaseViewController.rootController = self;
                _databaseViewController.view.frame = self.view.bounds;
                _currentViewController = _databaseViewController;
                break;
            default:
                break;
        }
    }

    [self.view addSubview:_databaseViewController.view];
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
  
    UIViewController* nextViewController;
    UIViewAnimationOptions animationOption;
    if([_currentViewController isKindOfClass:[DatabaseExplorerViewController class]])
    {
        animationOption = UIViewAnimationOptionTransitionFlipFromLeft;
        if(!_mapViewController)
        {
            _mapViewController = [[MapViewController alloc]init];
            _mapViewController.managedObjectContext = self.managedObjectContext;
            _mapViewController.rootController = self;

            
        }
        
        _mapViewController.predicate = [(DatabaseExplorerViewController*)_currentViewController fullPredicate];
        nextViewController = _mapViewController;
    }
    else 
    {
        animationOption = UIViewAnimationOptionTransitionFlipFromRight;
        if(!_databaseViewController)
        {
            _databaseViewController = [[DatabaseExplorerViewController alloc]init];
            _databaseViewController.managedObjectContext = self.managedObjectContext;
            _databaseViewController.rootController = self;
        }
        nextViewController = _databaseViewController;
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
