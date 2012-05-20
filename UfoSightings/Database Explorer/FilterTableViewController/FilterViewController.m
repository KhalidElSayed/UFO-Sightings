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
@interface FilterViewController ()
{
    NSMutableDictionary* _predicates;
    NSArray* _categories;
}
@end

@implementation FilterViewController
@synthesize delegate;
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
        // Custom initialization


        _categories = [NSArray arrayWithObjects:@"Report", @"Reported", @"Shape", @"Sighted", nil];
        
                _predicates = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UITableView* tableView = (UITableView*)self.view;
    [tableView registerNib:[UINib nibWithNibName:@"MasterCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"masterCell"];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tableView setAllowsMultipleSelection:YES];
    
    
    
}

-(void)viewWillLayoutSubviews
{/*
    for (NSString* key in _categories) {
        if ([_predicates objectForKey:key] != nil) {
            NSUInteger row = [_categories indexOfObject:key];
            
            [(UITableView*)self.view selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
   */ 
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
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *masterCellIdentifier = @"masterCell";
    
    NSString* categoryName = [_categories objectAtIndex:indexPath.row];
    
    MasterCell *cell = [tableView dequeueReusableCellWithIdentifier:masterCellIdentifier];
    [cell.mainLabel setText:categoryName];
    
    if([_predicates objectForKey:categoryName] == nil)
        cell.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"masterCell.png"]];
    else
    {
        cell.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"masterCellSelected.png"]];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.f;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if(indexPath.row == 0)
    {
        ReportLengthSelectorController* rls = [[ReportLengthSelectorController alloc]init];
        
        [self.navigationController pushViewController:rls animated:YES];
        
        
    }
    else if (indexPath.row == 1) {
        DatePickerTableViewController* datePickerVC = [[DatePickerTableViewController alloc]init];
        
        
        //datePickerVC.view.frame = self.view.bounds;
        [datePickerVC.slider setMinimumValue:1904];
        [datePickerVC.slider setMaximumValue:2012];
        [datePickerVC.slider setSelectedMinimumValue:1904];
        [datePickerVC.slider setSelectedMaximumValue:2012];
        [datePickerVC.slider setMinimumRange:1];
        [datePickerVC setAttribute:@"reportedAt"];
        [datePickerVC setPredicateKey:[_categories objectAtIndex:indexPath.row]];
        
        [self.navigationController pushViewController:datePickerVC animated:YES];
 
        
    }
    else if(indexPath.row == 2)
    {
        ShapeSelectorViewController* shapeSelector = [[ShapeSelectorViewController alloc]init];
        shapeSelector.predicateKey = [_categories objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:shapeSelector animated:YES];
        
        
    }
    else if (indexPath.row == 3) {
        DatePickerTableViewController* datePickerVC = [[DatePickerTableViewController alloc]init];
        
        
        //datePickerVC.view.frame = self.view.bounds;
        [datePickerVC.slider setMinimumValue:1904];
        [datePickerVC.slider setMaximumValue:2012];
        [datePickerVC.slider setSelectedMinimumValue:1904];
        [datePickerVC.slider setSelectedMaximumValue:2012];
        [datePickerVC.slider setMinimumRange:1];
        [datePickerVC setAttribute:@"sightedAt"];
        [datePickerVC setPredicateKey:[_categories objectAtIndex:indexPath.row]];

        [self.navigationController pushViewController:datePickerVC animated:YES];
    }
    
    
    
}

// Called when the navigation controller shows a new top view controller via a push, pop or setting of the view controller stack.
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{

    if (viewController == self) {
        [navigationController setNavigationBarHidden:YES];
    }
    else {
        [navigationController setNavigationBarHidden:NO];
    }

    NSLog(@"%@",_predicates);
    
    [(UITableView*)self.view reloadData];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
{
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
