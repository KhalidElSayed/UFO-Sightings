//
//  DatePickerTableViewController.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/15/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import "DatePickerTableViewController.h"
#import "UFOFilterViewController.h"
#import "RangeCell.h"

@interface DatePickerTableViewController ()
{
    bool                _hasChosenRange;
    NSDateFormatter*    _df;

}
@property (strong, nonatomic) UILabel* rangeLabel;
- (void)sliderDidUpdate;
@end

@implementation DatePickerTableViewController

- (id)initWithType:(UFODatePickerType)type
{
    if((self = [super init])) {
        self.pickerType = type;
        _slider = [[RangeSlider alloc]initWithFrame:CGRectMake(0, 0, 210, 80)];
        [_slider addTarget:self action:@selector(sliderDidUpdate) forControlEvents:UIControlEventValueChanged];
        [_slider setMinimumRange:1];
        _df = [[NSDateFormatter alloc]init];
        self.title = type == UFODatePickerTypeReportedAt ? @"Reported" : @"Sighted";     
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UITableView* tableView = (UITableView*)self.view;
    [tableView registerNib:[UINib nibWithNibName:@"RangeCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"rangeCell"];
    tableView.backgroundColor = [UIColor rgbColorWithRed:41 green:41 blue:41 alpha:1.0f];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.scrollEnabled = NO;
}


- (void)saveState
{
    [_df setDateFormat:@"yyyy"];
    
    NSDate *minDate = [_df dateFromString:[NSString stringWithFormat:@"%i",(int)_slider.selectedMinimumValue]];
    NSDate *maxDate = [_df dateFromString:[NSString stringWithFormat:@"%i",(int)_slider.selectedMaximumValue]];
    
    switch (self.pickerType) {
        case UFODatePickerTypeReportedAt:
            [self.filterManager setSelectedReportedAtMinimumDate:minDate];
            [self.filterManager setSelectedReportedAtMaximumDate:maxDate];
            [self.filterManager setHasFilters:_hasChosenRange forCellWithPredicateKey:kUFOReportedAtCellPredicateKey];
            break;
        case UFODatePickerTypeSightedAt:
            [self.filterManager setSelectedSightedAtMinimumDate:minDate];
            [self.filterManager setSelectedSightedAtMaximumDate:maxDate];
            [self.filterManager setHasFilters:_hasChosenRange forCellWithPredicateKey:kUFOSightedAtCellPredicateKey];
        default:
            break;
    }
    
    if(_hasChosenRange){
        NSString* key = self.pickerType == UFODatePickerTypeSightedAt ? kUFOSightedAtCellPredicateKey : kUFOReportedAtCellPredicateKey;
        [self.filterManager setSubtitle:self.rangeLabel.text forCellWithPredicateKey:key];
    }
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
    
        
    if(indexPath.row == 0)
    {
        RangeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"greyCellBackground.png"]];
        
        CGRect b = cell.bounds;
        b.size.width = 200;
        b.origin.x = 10;
        

        
        [_df setDateFormat:@"yyyy"];
        NSDate* minimumDate;
        NSDate* maximumDate;
        switch (self.pickerType) {
            case UFODatePickerTypeReportedAt:
                minimumDate = [self.filterManager defaultReportedAtMinimumDate];
                maximumDate = [self.filterManager defaultReportedAtMaximumDate];
                break;
            case UFODatePickerTypeSightedAt:
                minimumDate = [self.filterManager defaultSightedAtMinimumDate];
                maximumDate = [self.filterManager defaultSightedAtMaximumDate];
                break;
            default:
                break;
        }
        
        cell.minLabel.text = [_df stringFromDate:minimumDate];
        cell.maxLabel.text = [_df stringFromDate:maximumDate];
        if([self.predicateKey isEqualToString:@"reportedAt"] || [self.predicateKey isEqualToString:@"sightedAt"]) {
            
            NSDate* selectedMaximumDate;
            NSDate* selectedMinimumDate;
            
            switch (self.pickerType) {
                case UFODatePickerTypeReportedAt:
                    selectedMinimumDate = [self.filterManager selectedReportedAtMinimumDate];
                    selectedMaximumDate = [self.filterManager selectedReportedAtMaximumDate];
                    break;
                case UFODatePickerTypeSightedAt:
                    selectedMinimumDate = [self.filterManager selectedSightedAtMinimumDate];
                    selectedMaximumDate = [self.filterManager selectedSightedAtMaximumDate];
                    break;
                default:
                    break;
            }
            
            
            [_slider setMinimumValue:[[_df stringFromDate:minimumDate] floatValue]];
            [_slider setMaximumValue:[[_df stringFromDate:maximumDate] floatValue]];
            [_slider setSelectedMinimumValue:[[_df stringFromDate:selectedMinimumDate] floatValue]];
            [_slider setSelectedMaximumValue:[[_df stringFromDate:selectedMaximumDate] floatValue]];
            
            if(_slider.selectedMinimumValue == _slider.minimumValue && _slider.selectedMaximumValue == _slider.maximumValue)
                _hasChosenRange = NO;
            else {
                _hasChosenRange = YES;

            }
        }
        _slider.center = cell.center;

        [cell addSubview:_slider];
        return cell;
    }
    else if(indexPath.row == 1) {
       UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:anotherCellIdentifier];
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
            [label setTextAlignment:NSTextAlignmentCenter];
            [cell addSubview:label];
            _rangeLabel = label;
            
        }
        [_rangeLabel setText:[NSString stringWithFormat:@"%i - %i",(int)_slider.selectedMinimumValue, (int)_slider.selectedMaximumValue]];
        return cell;
    }
    else {
        NSLog(@"BAD INDEX PATH: %i",indexPath.row);
    }
    return [[UITableViewCell alloc]initWithFrame:CGRectZero];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
        return 80.0f;
    else if (indexPath.row == 1) 
        return 20.0f;
    else 
        return 0.0f;
}


- (void)sliderDidUpdate
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

- (BOOL)canReset
{
    return _hasChosenRange;
}


- (void)reset
{
    _slider.selectedMinimumValue = _slider.minimumValue;
    _slider.selectedMaximumValue = _slider.maximumValue;
    [_slider setNeedsLayout];
    [self sliderDidUpdate];
}

- (NSPredicate*)createPredicate
{
    [_df setDateFormat:@"yyyyMMdd"];
    NSPredicate* minimumDate = nil;
    NSPredicate* maximumDate = nil;
    if(_slider.selectedMinimumValue == _slider.minimumValue && _slider.selectedMaximumValue == _slider.maximumValue)
        return nil;
    
    
    if(_slider.selectedMinimumValue > _slider.minimumValue)
    {
        NSDate *minDate = [_df dateFromString:[NSString stringWithFormat:@"%i0101",(int)_slider.selectedMinimumValue]];
        minimumDate = [NSPredicate predicateWithFormat:@"%K > %@", _predicateKey, minDate];        
    }
    if(_slider.selectedMaximumValue < _slider.maximumValue)
    {
        NSDate *maxDate = [_df dateFromString:[NSString stringWithFormat:@"%i0101",(int)_slider.selectedMaximumValue]];
        maximumDate = [NSPredicate predicateWithFormat:@"%K < %@", _predicateKey, maxDate];
        if(minimumDate == nil)
            return maximumDate;
    }
    if(maximumDate == nil)
        return minimumDate;

    return [[NSCompoundPredicate alloc]initWithType:NSAndPredicateType subpredicates:[NSArray arrayWithObjects:maximumDate, minimumDate, nil] ];
}

@end
