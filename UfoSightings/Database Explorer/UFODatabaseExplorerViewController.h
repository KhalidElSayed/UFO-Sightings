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
@property (strong, nonatomic) IBOutlet UIView *masterView;
@property (strong, nonatomic) IBOutlet UIView *detailView;
@property (strong, nonatomic) IBOutlet UITableView *reportsTable;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIButton *resetButton;
@property (strong, nonatomic) IBOutlet UILabel *filterLabel;
@property (strong, nonatomic) IBOutlet UIButton *viewOnMapButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (strong, nonatomic) IBOutlet UILabel *loadingLabel;
@property (strong, nonatomic) IBOutlet UIButton *addMoreButton;


- (IBAction)viewOnMapSelected:(UIButton *)sender;
- (IBAction)backButtonPressed:(UIButton *)sender;
- (IBAction)resetButtonPressed:(UIButton *)sender;
- (IBAction)addMoreButtonSelected:(UIButton*)button;
- (NSPredicate*)buildPredicateWithFilters:(NSDictionary*)filters;

@end


@protocol UFODatabaseExplorerDelegate <NSObject>
- (void)UFODatabaseExplorerWantsToViewMap:(UFODatabaseExplorerViewController*)databaseExplorer;
@end


@protocol UFOPredicateCreation <NSObject>
@property (strong, nonatomic)NSString* predicateKey;
- (BOOL)canReset;
- (void)reset;


@optional
- (NSPredicate*)createPredicate;
- (void)saveState;
@end
