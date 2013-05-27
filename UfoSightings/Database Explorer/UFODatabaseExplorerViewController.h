//
//  FilterViewControllerViewController.h
//  UfoSightings
//
//  Created by Richard Kirk on 5/13/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import "UFOBaseViewController.h"

@class UFOFilterViewController;
@class UFORootController;

@protocol UFODatabaseExplorerDelegate;

@interface UFODatabaseExplorerViewController : UFOBaseViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (weak, nonatomic) id<UFODatabaseExplorerDelegate> delegate;
@property (strong, nonatomic) UINavigationController* filterNavController;
@property (strong, nonatomic) NSArray* reports;
@property (strong, nonatomic, readonly) NSDictionary* shapesDictionary;
@property (strong, nonatomic) NSPredicate* lastPredicateFetched;
@property (weak, nonatomic) IBOutlet UITableView *reportsTable;
@property (weak, nonatomic) IBOutlet UIView *masterView;
@property (weak, nonatomic) IBOutlet UIView *detailView;
@property (strong, nonatomic) IBOutlet UIButton *addMoreButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UIButton *viewOnMapButton;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UILabel *filterLabel;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

- (IBAction)viewOnMapSelected:(UIButton *)sender;
- (IBAction)backButtonPressed:(UIButton *)sender;
- (IBAction)resetButtonPressed:(UIButton *)sender;
- (IBAction)addMoreButtonSelected:(UIButton*)button;

@end


@protocol UFODatabaseExplorerDelegate <NSObject>
- (void)UFODatabaseExplorerWantsToViewMap:(UFODatabaseExplorerViewController*)databaseExplorer;
@end


@protocol UFOPredicateCreation <NSObject>
- (BOOL)canReset;
- (void)resetInterface;
@optional
- (void)saveFiltersToFilterManager;
@end
