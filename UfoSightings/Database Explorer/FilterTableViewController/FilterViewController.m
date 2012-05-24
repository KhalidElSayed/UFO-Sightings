//
//  FilterViewController.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/15/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import "FilterViewController.h"
#import "MasterCell.h"
#import "DatePickerTableViewController.h"
#import "Sighting.h"
#import "ShapeSelectorViewController.h"
#import "ReportLengthSelectorController.h"
#import "UIColor+RKColor.h"

@interface FilterViewController ()
{
    NSMutableDictionary* _predicates;
    NSArray* _categories;
}

@end

@implementation FilterViewController
@synthesize delegate;
@synthesize filterDict;
@synthesize predicateKey;


-(id)init
{
    if((self = [super init]))
    {
        
    }
    return self;
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
        _categories = [NSArray arrayWithObjects:@"Report", @"Reported", @"Shape", @"Sighted", nil];
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
}


-(void)viewWillLayoutSubviews
{
    /*
     for (NSString* key in _categories) {
     if ([_predicates objectForKey:key] != nil) {
     NSUInteger row = [_categories indexOfObject:key];
     
     [(UITableView*)self.view selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
     }
     }
     */ 
}

-(void)viewWillAppear:(BOOL)animated
{
    if(animated)
    [self.tableView reloadData];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{// Return the number of rows in the section.
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
        
       // CGRect frame = self.navigationController.view.frame;
        
        [self.navigationController pushViewController:datePickerVC animated:YES];
    
                NSLog(@"%@",NSStringFromCGRect(datePickerVC.view.frame));
    }
    else if (indexPath.row == 1) {
        
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
    else if (indexPath.row == 3) {
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



-(NSCompoundPredicate*)predicate
{
    return [[NSCompoundPredicate alloc]initWithType:NSAndPredicateType subpredicates:[_predicates allValues]];
}

-(void)storePredicate:(NSPredicate*)predicate forKey:(NSString*)key
{
    if (!predicate) {
        [_predicates removeObjectForKey:key];
    }
    else
        [_predicates setObject:predicate forKey:key];
    
    [self.delegate filterViewController:self didUpdatePredicate:self.predicate];
}

@end
