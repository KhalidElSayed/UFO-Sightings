//
//  DatePickerTableViewController.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/15/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import "DatePickerTableViewController.h"
#import "FilterViewController.h"
#import "RangeCell.h"

@interface DatePickerTableViewController ()
{
    bool _hasChosenRange;
}
-(void)sliderDidUpdate;
@end

@implementation DatePickerTableViewController
@synthesize slider = _slider;
@synthesize attribute, predicateKey;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _slider = [[RangeSlider alloc]initWithFrame:CGRectMake(0, 0, 210, 80)];
        [_slider addTarget:self action:@selector(sliderDidUpdate) forControlEvents:UIControlEventValueChanged];

        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UITableView* tableView = (UITableView*)self.view;
    [tableView registerNib:[UINib nibWithNibName:@"RangeCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"rangeCell"];
    [tableView setBackgroundColor:[UIColor clearColor]];
    
    
    [self.navigationController setNavigationBarHidden:NO];
        
    _hasChosenRange = NO;

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.slider = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSPredicate* predicate = [self createPredicate];
    if (predicate) {
        FilterViewController *fvc = [self.navigationController.viewControllers objectAtIndex:0];
        [fvc storePredicate:predicate forKey:self.predicateKey];

    }
    
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
{   
    if(_hasChosenRange)
    {
        return 2;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"rangeCell";
    static NSString *anotherCellIdentifier = @"aCell";
    
    UITableViewCell *cell;
    
    if(indexPath.row == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor whiteColor];
        
        UIView* aView = [[UIView alloc] init];
        aView.backgroundColor = [UIColor whiteColor];
        cell.backgroundView = aView;
        //CGRectMake(47, 29, 150, 22)
        CGRect b = cell.bounds;
        b.size.width = 200;
        b.origin.x = 10;
        
        _slider.center = cell.center;

        [cell addSubview:_slider];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:anotherCellIdentifier];
        if(!cell)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:anotherCellIdentifier];
            CGRect frame = cell.frame;
            frame.size.height = 20.f;
            cell.frame = frame;
            UIImage* strechyImage = [[UIImage imageNamed:@"blueStrectchyBox.png"] stretchableImageWithLeftCapWidth:3 topCapHeight:5];
            UIImageView* imgView = [[UIImageView alloc]initWithImage:strechyImage];

    
            
            [cell setBackgroundView:imgView];
            UILabel*label = [[UILabel alloc]initWithFrame:cell.bounds];
            [label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12.0f]];
            [label setTextColor:[UIColor whiteColor]];
            [label setBackgroundColor:[UIColor clearColor]];
        
            [cell addSubview:label];
        }
                
        
        
        
    }
    
    
    // Configure the cell...
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1)
    return 80.0f;
    
    return 20.0f;
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

-(void)sliderDidUpdate
{
    if(_slider.selectedMinimumValue == _slider.minimumValue && _slider.selectedMaximumValue == _slider.maximumValue)
    {
        //(UITableView*)self.view  
    }
    
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

-(NSPredicate*)createPredicate
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSPredicate* minimumDate = nil;
    NSPredicate* maximumDate = nil;
    if(_slider.selectedMinimumValue == _slider.minimumValue && _slider.selectedMaximumValue == _slider.maximumValue)
        return nil;
    
    
    if(_slider.selectedMinimumValue > _slider.minimumValue)
    {
        NSDate *minDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%i0101",(int)_slider.selectedMinimumValue]];
        minimumDate = [NSPredicate predicateWithFormat:@"%K > %@", attribute, minDate];        
    }
    if(_slider.selectedMaximumValue < _slider.maximumValue)
    {
        NSDate *maxDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%i0101",(int)_slider.selectedMaximumValue]];
        maximumDate = [NSPredicate predicateWithFormat:@"%K < %@", attribute, maxDate];
        if(minimumDate == nil)
            return maximumDate;
    }
    if(maximumDate == nil)
        return minimumDate;

    return [[NSCompoundPredicate alloc]initWithType:NSAndPredicateType subpredicates:[NSArray arrayWithObjects:maximumDate, minimumDate, nil] ];
}

@end
