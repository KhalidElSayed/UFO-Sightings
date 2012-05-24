//
//  FilterViewControllerViewController.h
//  UfoSightings
//
//  Created by Richard Kirk on 5/13/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterViewController.h"



@interface DatabaseExplorerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate>
{
    UINavigationController* _filterNavController;


    
}
@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (strong, nonatomic) IBOutlet UIView *masterView;
@property (strong, nonatomic) IBOutlet UIView *detailView;
@property (strong, nonatomic) IBOutlet UITableView *reportsTable;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSMutableArray* reports;
@property (strong, atomic) NSMutableDictionary* filterOptions;

@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIButton *resetButton;
@property (strong, nonatomic) IBOutlet UILabel *filterLabel;
@property (strong, nonatomic) IBOutlet UIButton *viewOnMapButton;
- (IBAction)viewOnMapSelected:(UIButton *)sender;

- (IBAction)backButtonPressed:(UIButton *)sender;
- (IBAction)resetButtonPressed:(UIButton *)sender;
@end




@protocol PredicateCreation <NSObject>
-(NSPredicate*)createPredicate;

@required
@property (strong, nonatomic)NSString* predicateKey;
-(BOOL)canReset;
-(void)reset;

@end
