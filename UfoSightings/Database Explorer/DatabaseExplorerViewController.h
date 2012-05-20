//
//  FilterViewControllerViewController.h
//  UfoSightings
//
//  Created by Richard Kirk on 5/13/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterViewController.h"

@interface DatabaseExplorerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, FilterControllerDelegate>
{
    UINavigationController* _filterNavController;


    
}
@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (strong, nonatomic) IBOutlet UIView *masterView;
@property (strong, nonatomic) IBOutlet UIView *detailView;
@property (strong, nonatomic) IBOutlet UITableView *reportsTable;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSMutableArray* reports;
@property (strong, nonatomic) NSMutableDictionary* filterOptions;


@end
