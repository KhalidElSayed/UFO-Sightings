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
@property (assign, nonatomic) BOOL hasChosenRange;
- (void)sliderDidUpdate;

@end

@implementation DatePickerTableViewController

- (id)initWithType:(UFODatePickerType)type
{
    if((self = [super init])) {
        self.pickerType = type;
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


- (NSDateFormatter*)dateFormatter
{
    if(!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc]init];
        [_dateFormatter setDateFormat:@"yyyy"];
    }
    return _dateFormatter;
}


- (void)setCellSlider:(RangeSlider *)cellSlider
{
    _cellSlider = cellSlider;
    [_cellSlider addTarget:self action:@selector(sliderDidUpdate) forControlEvents:UIControlEventValueChanged];
}


- (BOOL)hasChosenRange
{
    if(!self.cellSlider) { return NO; }
    return self.cellSlider.selectedMinimumValue != self.cellSlider.minimumValue || self.cellSlider.selectedMaximumValue != self.cellSlider.maximumValue;
}


- (UILabel*)rangeLabel
{
    if(!_rangeLabel) {
        _rangeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 280, 20)];
        [_rangeLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12.0f]];
        [_rangeLabel setTextColor:[UIColor whiteColor]];
        [_rangeLabel setBackgroundColor:[UIColor clearColor]];
        [_rangeLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return _rangeLabel;
}


- (void)saveFiltersToFilterManager
{
    NSDate *minDate = [self.dateFormatter dateFromString:[NSString stringWithFormat:@"%i",(int)self.cellSlider.selectedMinimumValue]];
    NSDate *maxDate = [self.dateFormatter dateFromString:[NSString stringWithFormat:@"%i",(int)self.cellSlider.selectedMaximumValue]];
    
    switch (self.pickerType) {
        case UFODatePickerTypeReportedAt:
            [self.filterManager setSelectedReportedAtMinimumDate:minDate];
            [self.filterManager setSelectedReportedAtMaximumDate:maxDate];
            [self.filterManager setHasFilters:self.hasChosenRange forCellWithPredicateKey:kUFOReportedAPredicateKey];
            break;
        case UFODatePickerTypeSightedAt:
            [self.filterManager setSelectedSightedAtMinimumDate:minDate];
            [self.filterManager setSelectedSightedAtMaximumDate:maxDate];
            [self.filterManager setHasFilters:self.hasChosenRange forCellWithPredicateKey:kUFOSightedAtPredicateKey];
        default:
            break;
    }
    
    if(self.hasChosenRange){
        NSString* key = self.pickerType == UFODatePickerTypeSightedAt ? kUFOSightedAtPredicateKey : kUFOReportedAPredicateKey;
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
    return self.hasChosenRange ? 2 : 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section > 0 || indexPath.row > 1) { return 0; }
    return indexPath.row == 0 ? 80 : 20;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"rangeCell";
    static NSString *anotherCellIdentifier = @"aCell";
    
    if(indexPath.row == 0) {
        RangeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        NSDate* minimumDate = self.pickerType == UFODatePickerTypeReportedAt ? [self.filterManager defaultReportedAtMinimumDate] : [self.filterManager defaultSightedAtMinimumDate];
        NSDate* maximumDate = self.pickerType == UFODatePickerTypeReportedAt ? [self.filterManager defaultReportedAtMaximumDate] : [self.filterManager defaultSightedAtMaximumDate];
        NSDate* selectedMinimumDate = self.pickerType == UFODatePickerTypeReportedAt ? [self.filterManager selectedReportedAtMinimumDate] : [self.filterManager selectedSightedAtMinimumDate];
        NSDate* selectedMaximumDate = self.pickerType == UFODatePickerTypeReportedAt ? [self.filterManager selectedReportedAtMaximumDate] : [self.filterManager selectedSightedAtMaximumDate];
        
        cell.minLabel.text = [self.dateFormatter stringFromDate:minimumDate];
        cell.maxLabel.text = [self.dateFormatter stringFromDate:maximumDate];
        
        self.cellSlider = cell.slider;
        [cell.slider setMinimumValue:[[self.dateFormatter stringFromDate:minimumDate] floatValue]];
        [cell.slider setMaximumValue:[[self.dateFormatter stringFromDate:maximumDate] floatValue]];
        [cell.slider setSelectedMinimumValue:[[self.dateFormatter stringFromDate:selectedMinimumDate] floatValue]];
        [cell.slider setSelectedMaximumValue:[[self.dateFormatter stringFromDate:selectedMaximumDate] floatValue]];
        
        return cell;
    }
    else if(indexPath.row == 1) {
       UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:anotherCellIdentifier];
        if(!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:anotherCellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UIImage* strechyImage = [[UIImage imageNamed:@"blueStrechyBox.png"] stretchableImageWithLeftCapWidth:2 topCapHeight:9];
            UIImageView* imgView = [[UIImageView alloc]initWithImage:strechyImage];
            imgView.frame = cell.bounds;
            [cell setBackgroundView:imgView];
            
            [cell addSubview:self.rangeLabel];
        }

        return cell;
    }
    return [[UITableViewCell alloc]initWithFrame:CGRectZero];
}


#pragma mark - Slider Update Action

- (void)sliderDidUpdate
{
    if(self.hasChosenRange) {
        
        if(![self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]) {
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
            [self.tableView endUpdates];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"FilterChoiceChanged" object:self];
        }
        
        [self.rangeLabel setText:[NSString stringWithFormat:@"%i - %i",(int)self.cellSlider.selectedMinimumValue, (int)self.cellSlider.selectedMaximumValue]];
    }
    else {
        
        if([self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]) {
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
            [self.tableView endUpdates];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"FilterChoiceChanged" object:self];
        }
    }
}


- (BOOL)canReset
{
    return self.hasChosenRange;
}


- (void)resetInterface
{
    self.cellSlider.selectedMinimumValue = self.cellSlider.minimumValue;
    self.cellSlider.selectedMaximumValue = self.cellSlider.maximumValue;
    [self.cellSlider setNeedsLayout];
    [self sliderDidUpdate];
}

@end
