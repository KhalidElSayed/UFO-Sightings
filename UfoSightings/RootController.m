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
    }
return self;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _databaseViewController = [[DatabaseExplorerViewController alloc]init];
    _databaseViewController.managedObjectContext = self.managedObjectContext;
    _currentViewController = _databaseViewController;
    [self.view addSubview:_databaseViewController.view];
    
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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
        }
        
        nextViewController = _mapViewController;
    }
    else 
    {
        animationOption = UIViewAnimationOptionTransitionFlipFromRight;
        if(!_databaseViewController)
        {
            _databaseViewController = [[DatabaseExplorerViewController alloc]init];
            _databaseViewController.managedObjectContext = self.managedObjectContext;
        }
        nextViewController = _databaseViewController;
    }
    
    
     
     [UIView transitionWithView:self.view duration:1.5f options:animationOption animations:^{
         [self.view addSubview:nextViewController.view];
     } completion:^(BOOL finished){
         [_currentViewController.view removeFromSuperview];
         _currentViewController = nextViewController;
     }];
    

    
    
}


     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
@end
