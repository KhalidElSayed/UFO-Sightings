//
//  FilterViewController.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/15/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import "UFOFilterViewController.h"
#import "DatePickerTableViewController.h"
#import "ShapeSelectorViewController.h"
#import "ReportLengthSelectorController.h"
#import "UFOFilterTableViewCell.h"

@interface UFOFilterViewController()
{
    NSArray* _filterCells;
}
@end

@implementation UFOFilterViewController

- (id)init
{
    if((self = [super init])) {
        self.predicateKey = @"main";
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    UITableView* tableView = (UITableView*)self.view;
    [tableView registerNib:[UINib nibWithNibName:@"UFOFilterTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"masterCell"];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tableView setAllowsMultipleSelection:YES];
    [tableView setBackgroundColor:[UIColor rgbColorWithRed:41 green:41 blue:41 alpha:1.0f]];
    [tableView setScrollEnabled:NO];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(animated) {
        [self.tableView reloadData];
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

/**
filterCells is an array of dictionaries to configure cells
 filterCellDict keys are as follows :
 predicateKey :: (NSString*) the predicate that this cell can create
 hasFilters   :: (NSNumber*(bool)) wheter this cell has filters applied
 title        :: (NSString*) the title of the cell
 subtitle     :: (NSString*) the subtitle of the cell
 */
- (NSArray*)filterCells
{
    if(!_filterCells) {
        _filterCells = [self.filterManager filterCells];
    }
    return _filterCells;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.filterCells count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *masterCellIdentifier = @"masterCell";
    
    UFOFilterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:masterCellIdentifier];
    NSDictionary* cellDict = [self.filterCells objectAtIndex:indexPath.row];
    
    [cell configureWithDictionary:cellDict];

    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UIViewController* viewControllerToPush = nil;
    if(indexPath.row == 0) {
        DatePickerTableViewController* datePickerVC = [[DatePickerTableViewController alloc]initWithType:UFODatePickerTypeReportedAt];
        viewControllerToPush = datePickerVC;
    }
    else if (indexPath.row == 1) {
        ReportLengthSelectorController* rls = [[ReportLengthSelectorController alloc]init];
        viewControllerToPush = rls;
    }
    else if(indexPath.row == 2) {
        ShapeSelectorViewController* shapeSelector = [[ShapeSelectorViewController alloc]init];
        shapeSelector.title = @"Shapes";
        viewControllerToPush = shapeSelector;
    }
    else if (indexPath.row == 3) {
        DatePickerTableViewController* datePickerVC = [[DatePickerTableViewController alloc]initWithType:UFODatePickerTypeSightedAt];
        viewControllerToPush = datePickerVC;
    }
    [self.navigationController pushViewController:viewControllerToPush animated:YES];
}


- (BOOL)canReset
{
    BOOL hasFilters = NO;
    
    for (NSDictionary* cellDict in self.filterCells) {
        
        if ([[cellDict objectForKey:@"hasFilters"] boolValue]) {
            hasFilters = YES;
            break;
        }
    }
    
    return hasFilters;
}


- (void)reset
{
    [self.filterManager resetFilters];
    [(UITableView*)self.view reloadData];
}


@end