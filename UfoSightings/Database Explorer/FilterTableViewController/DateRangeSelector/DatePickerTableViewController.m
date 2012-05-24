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
    NSDateFormatter* df;
    UILabel* _rangeLabel;
}
-(void)sliderDidUpdate;
@end

@implementation DatePickerTableViewController
@synthesize slider = _slider;
@synthesize  predicateKey;
@synthesize filterDict;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _slider = [[RangeSlider alloc]initWithFrame:CGRectMake(0, 0, 210, 80)];
        [_slider addTarget:self action:@selector(sliderDidUpdate) forControlEvents:UIControlEventValueChanged];
        [_slider setMinimumRange:1];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UITableView* tableView = (UITableView*)self.view;
    [tableView registerNib:[UINib nibWithNibName:@"RangeCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"rangeCell"];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    df = [[NSDateFormatter alloc]init];
    
    

    
    
   

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
    NSDate *minDate = [df dateFromString:[NSString stringWithFormat:@"%i0101",(int)_slider.selectedMinimumValue]];
    NSDate *maxDate = [df dateFromString:[NSString stringWithFormat:@"%i0101",(int)_slider.selectedMaximumValue]];
    [filterDict setObject:minDate forKey:[NSString stringWithFormat:@"%@SelectedMinimumDate", predicateKey]];
    [filterDict setObject:maxDate forKey:[NSString stringWithFormat:@"%@SelectedMaximumDate",predicateKey]];
    NSMutableArray* filterCells = [filterDict objectForKey:@"filterCells"];
    NSMutableDictionary* cell;
    for (NSMutableDictionary* cellDict in filterCells) {
        if([(NSString*)[cellDict objectForKey:@"predicateKey"] compare:self.predicateKey] == 0)
        {
            cell = cellDict;
            break;
        }
    }
    
    [cell setObject:[NSNumber numberWithBool:_hasChosenRange ] forKey:@"hasFilters"];


    if(_hasChosenRange)
            [cell setObject:_rangeLabel.text forKey:@"subtitle"];
    
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
    
    if(indexPath.row == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"greyCellBackground.png"]];
        
        CGRect b = cell.bounds;
        b.size.width = 200;
        b.origin.x = 10;
        
        NSDate* minimumDate;
        NSDate* maximumDate;
        NSDate* selectedMaximumDate;
        NSDate* selectedMinimumDate;
        
        if([predicateKey isEqualToString:@"reportedAt"] || [predicateKey isEqualToString:@"sightedAt"])
        {
            
            [df setDateFormat:@"yyyy"];
            minimumDate = [filterDict objectForKey:[NSString stringWithFormat:@"%@MinimumDate",predicateKey]];
            maximumDate = [filterDict objectForKey:[NSString stringWithFormat:@"%@MaximumDate",predicateKey]];
            selectedMaximumDate = [filterDict objectForKey:[NSString stringWithFormat:@"%@SelectedMaximumDate", predicateKey]];
            selectedMinimumDate = [filterDict objectForKey:[NSString stringWithFormat:@"%@SelectedMinimumDate",predicateKey]];
            
            [_slider setMinimumValue:[[df stringFromDate:minimumDate] floatValue]];
            [_slider setMaximumValue:[[df stringFromDate:maximumDate] floatValue]];
            [_slider setSelectedMinimumValue:[[df stringFromDate:selectedMinimumDate] floatValue]];
            [_slider setSelectedMaximumValue:[[df stringFromDate:selectedMaximumDate] floatValue]];
            
            if(_slider.selectedMinimumValue == _slider.minimumValue && _slider.selectedMaximumValue == _slider.maximumValue)
                _hasChosenRange = NO;
            else {
                _hasChosenRange = YES;

            }
        }

        
        
        
        _slider.center = cell.center;

        [cell addSubview:_slider];
    }
    else if(indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:anotherCellIdentifier];
        if(!cell)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:anotherCellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UIImage* strechyImage = [[UIImage imageNamed:@"blueStrechyBox.png"] stretchableImageWithLeftCapWidth:2 topCapHeight:9];
            UIImageView* imgView = [[UIImageView alloc]initWithImage:strechyImage];
            imgView.frame = cell.bounds;
            [cell setBackgroundView:imgView];
            
            UILabel*label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 280, 20)];
            [label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12.0f]];
            [label setTextColor:[UIColor whiteColor]];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setTextAlignment:UITextAlignmentCenter];
            [cell addSubview:label];
            _rangeLabel = label;
            
        }
                
        
        [_rangeLabel setText:[NSString stringWithFormat:@"%i - %i",(int)_slider.selectedMinimumValue, (int)_slider.selectedMaximumValue]];
        
    }
    else {
        NSLog(@"%i",indexPath.row);
    }
    
    // Configure the cell...
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
        return 80.0f;
    else if (indexPath.row == 1) 
        return 20.0f;
    else 
        return 0.0f;
}


-(void)sliderDidUpdate
{
  
    
    if(_slider.selectedMinimumValue != _slider.minimumValue || _slider.selectedMaximumValue != _slider.maximumValue)
    {

        
        if(![self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]])
        {
            [self.tableView beginUpdates];
            _hasChosenRange = YES; 
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
            [self.tableView endUpdates];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"FilterChoiceChanged" object:self];
        }
        
        [_rangeLabel setText:[NSString stringWithFormat:@"%i - %i",(int)_slider.selectedMinimumValue, (int)_slider.selectedMaximumValue]];
    }
    else {
        if([self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]])
        {
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
            _hasChosenRange = NO;
            [self.tableView endUpdates];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"FilterChoiceChanged" object:self];
        }
    }
    
}

-(BOOL)canReset
{
    return _hasChosenRange;
}


-(void)reset
{

    _slider.selectedMinimumValue = _slider.minimumValue;
    _slider.selectedMaximumValue = _slider.maximumValue;
    [_slider setNeedsLayout];
    [self sliderDidUpdate];
}

-(NSPredicate*)createPredicate
{
    
    
    [df setDateFormat:@"yyyyMMdd"];
    NSPredicate* minimumDate = nil;
    NSPredicate* maximumDate = nil;
    if(_slider.selectedMinimumValue == _slider.minimumValue && _slider.selectedMaximumValue == _slider.maximumValue)
        return nil;
    
    
    if(_slider.selectedMinimumValue > _slider.minimumValue)
    {
        NSDate *minDate = [df dateFromString:[NSString stringWithFormat:@"%i0101",(int)_slider.selectedMinimumValue]];
        minimumDate = [NSPredicate predicateWithFormat:@"%K > %@", predicateKey, minDate];        
    }
    if(_slider.selectedMaximumValue < _slider.maximumValue)
    {
        NSDate *maxDate = [df dateFromString:[NSString stringWithFormat:@"%i0101",(int)_slider.selectedMaximumValue]];
        maximumDate = [NSPredicate predicateWithFormat:@"%K < %@", predicateKey, maxDate];
        if(minimumDate == nil)
            return maximumDate;
    }
    if(maximumDate == nil)
        return minimumDate;

    return [[NSCompoundPredicate alloc]initWithType:NSAndPredicateType subpredicates:[NSArray arrayWithObjects:maximumDate, minimumDate, nil] ];
}

@end
