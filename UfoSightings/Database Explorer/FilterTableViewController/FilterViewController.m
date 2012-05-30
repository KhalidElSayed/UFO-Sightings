//
//  FilterViewController.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/15/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import "FilterViewController.h"
#import "DatePickerTableViewController.h"
#import "ShapeSelectorViewController.h"
#import "ReportLengthSelectorController.h"
#import "MasterCell.h"



@implementation FilterViewController
@synthesize filterDict;
@synthesize predicateKey;


-(id)init
{
    if((self = [super init]))
    {
        self.predicateKey = @"main";
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    UITableView* tableView = (UITableView*)self.view;
    [tableView registerNib:[UINib nibWithNibName:@"MasterCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"masterCell"];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tableView setAllowsMultipleSelection:YES];
    [tableView setBackgroundColor:[UIColor rgbColorWithRed:41 green:41 blue:41 alpha:1.0f]];
}


-(void)viewWillAppear:(BOOL)animated
{
    if(animated)
    [self.tableView reloadData];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.filterDict objectForKey:@"filterCells"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *masterCellIdentifier = @"masterCell";
    
    NSDictionary* cellDict = [[self.filterDict objectForKey:@"filterCells"] objectAtIndex:indexPath.row];
    MasterCell *cell = [tableView dequeueReusableCellWithIdentifier:masterCellIdentifier];
    
    [cell.mainLabel setText:[cellDict objectForKey:@"title"]];
    
    if([(NSNumber*)[cellDict objectForKey:@"hasFilters"] boolValue])
    {
        cell.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"masterCellSelected.png"]];
        [cell.subtitleLabel setText:[cellDict objectForKey:@"subtitle"]];
        CGRect frame = cell.mainLabel.frame;
        frame.origin.y = 0;
        
        [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationCurveEaseInOut animations:^{
            cell.mainLabel.frame = frame;
        } completion:^(BOOL finished){
            [UIView animateWithDuration:0.3 animations:^{
                cell.subtitleLabel.alpha = 1.0f;
            }];
        }];
    }
    else
    {
        cell.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"masterCell.png"]];
        
        CGRect frame = cell.mainLabel.frame;
        if(frame.origin.y != 20.0f)
        {
            frame.origin.y = 20.0f;
            [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationCurveEaseInOut animations:^{
                cell.mainLabel.frame = frame;
                cell.subtitleLabel.alpha = 0.0f;
            } completion:^(BOOL finished){
                    [cell.subtitleLabel setText:@""];
            }];
        }
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row == 0)
    {
        DatePickerTableViewController* datePickerVC = [[DatePickerTableViewController alloc]init];
        [datePickerVC setPredicateKey:@"reportedAt"];
        datePickerVC.filterDict = self.filterDict;
        datePickerVC.title = @"Reported";
        
        [self.navigationController pushViewController:datePickerVC animated:YES];
    
    }
    else if (indexPath.row == 1) 
    {
        ReportLengthSelectorController* rls = [[ReportLengthSelectorController alloc]init];
        rls.filterOptions = self.filterDict;
        rls.title = @"Reports";
        [self.navigationController pushViewController:rls animated:YES];
    }
    else if(indexPath.row == 2)
    {
        ShapeSelectorViewController* shapeSelector = [[ShapeSelectorViewController alloc]init];
        shapeSelector.filterDict = self.filterDict;
        shapeSelector.title = @"Shapes";
        [self.navigationController pushViewController:shapeSelector animated:YES];
    }
    else if (indexPath.row == 3) 
    {
        DatePickerTableViewController* datePickerVC = [[DatePickerTableViewController alloc]init];
        [datePickerVC setPredicateKey:@"sightedAt"];
        datePickerVC.title = @"Sighted";
        datePickerVC.filterDict = self.filterDict;
        [self.navigationController pushViewController:datePickerVC animated:YES];
    }
}


-(BOOL)canReset
{
    BOOL hasFilters = NO;
    NSArray* cells = [self.filterDict objectForKey:@"filterCells"];    
    
    for (NSDictionary* cellDict in cells) {
        if ([[cellDict objectForKey:@"hasFilters"] boolValue])
            {
                hasFilters = YES;
                break;
            }
    }
    
    return hasFilters;
}


-(void)reset
{
    NSArray* cells = [self.filterDict objectForKey:@"filterCells"];        
    for (NSMutableDictionary* cellDict in cells) {
        [cellDict setObject:[NSNumber numberWithBool:NO] forKey:@"hasFilters"];
    }
    
    [filterDict setObject:[filterDict objectForKey:@"reportedAtMinimumDate"] forKey:@"reportedAtSelectedMinimumDate"];
    [filterDict setObject:[filterDict objectForKey:@"reportedAtMaximumDate"] forKey:@"reportedAtSelectedMaximumDate"];    
    [filterDict setObject:[filterDict objectForKey:@"sightedAtMinimumDate"] forKey:@"sightedAtSelectedMinimumDate"]; 
    [filterDict setObject:[filterDict objectForKey:@"sightedAtMaximumDate"] forKey:@"sightedAtSelectedMaximumDate"];
    
    [filterDict setObject:[NSArray array] forKey:@"shapesToFilter"];
    [filterDict setObject:[NSArray array] forKey:@"reportLengthsToFilter"];    
    [(UITableView*)self.view reloadData];
}


@end
