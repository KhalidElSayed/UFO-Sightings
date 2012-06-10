//
//  FilterViewControllerViewController.h
//  UfoSightings
//
//  Created by Richard Kirk on 5/13/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import <UIKit/UIKit.h>


@class FilterViewController;
@class RootController;
@interface DatabaseExplorerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate>
{
    UINavigationController* _filterNavController;
}
@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (weak) RootController* rootController;
@property (strong, nonatomic) NSArray* reports;
@property (strong, atomic) NSMutableDictionary* filterOptions;
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
-(IBAction)addMoreButtonSelected:(UIButton*)button;
-(NSPredicate*)fullPredicate;

@end



@protocol PredicateCreation <NSObject>
@property (strong, nonatomic)NSString* predicateKey;
-(BOOL)canReset;
-(void)reset;


@optional
-(NSPredicate*)createPredicate;
-(void)saveState;
@end
