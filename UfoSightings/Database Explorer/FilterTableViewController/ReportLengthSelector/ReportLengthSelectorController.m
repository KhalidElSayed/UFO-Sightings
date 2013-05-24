//
//  ReportLengthSelectorController.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/16/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import "ReportLengthSelectorController.h"

@implementation ReportLengthSelectorController

- (id)init
{
    if ((self = [super self])) {
        self.title = @"Reports";
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage* strechyBackgroundImage =  [[UIImage imageNamed:@"greyBoxStrechable.png"] stretchableImageWithLeftCapWidth:3 topCapHeight:3];
    for (UIImageView* imgView in self.tileBackgroundImageViews) {
        imgView.image = strechyBackgroundImage;
    }
    
    NSArray* lengthsToFilter = [self.filterManager reportLengthsToFilter];
    for (UIButton* checkMarkButton in self.checkmarkButtons) {
        if(checkMarkButton.tag == 0) {
            [checkMarkButton setSelected:![lengthsToFilter containsObject:@"short"]];
        }
        else if(checkMarkButton.tag == 1) {
            [checkMarkButton setSelected:![lengthsToFilter containsObject:@"medium"]];
        }
        else if(checkMarkButton.tag == 2) {
            [checkMarkButton setSelected:![lengthsToFilter containsObject:@"long"]];
        }
    }
    
}


- (void)saveFiltersToFilterManager
{
    NSMutableArray* lengthsToFilter = [[NSMutableArray alloc]initWithCapacity:3];
    
    for (UIButton* checkmarkButton in self.checkmarkButtons) {
        
        if (checkmarkButton.isSelected)
            continue;
        
        if(checkmarkButton.tag == 0) {
            [lengthsToFilter addObject:@"short"];
        }
        else if (checkmarkButton.tag == 1) {
            [lengthsToFilter addObject:@"medium"];
        }
        else if (checkmarkButton.tag == 2) {
            [lengthsToFilter addObject:@"long"];
        }
    }
    [self.filterManager setReportLengthsToFilter:lengthsToFilter];
    
    bool filters = lengthsToFilter.count > 0;
    
    if (filters) {
        NSMutableString* subtitle = [[NSMutableString alloc]init];
        
        for (NSString* string in lengthsToFilter) {
            [subtitle appendFormat:@"%@, ",string];
        }
        
        [subtitle deleteCharactersInRange:NSMakeRange(subtitle.length -2, 2)];
        
        [self.filterManager setSubtitle:subtitle forCellWithPredicateKey:kUFOReportLengthCellPredicateKey];
    }
    [self.filterManager setHasFilters:filters forCellWithPredicateKey:kUFOReportLengthCellPredicateKey];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}


- (IBAction)checkmarkButtonSelected:(UIButton *)sender 
{    
    [sender setSelected:!sender.isSelected];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FilterChoiceChanged" object:self];
}


- (BOOL)canReset
{
    for (UIButton* checkmarkButton in self.checkmarkButtons) {
        if (!checkmarkButton.isSelected) {
            return YES;
        }
    }
    return NO;
}


- (void)resetInterface
{
    for (UIButton* checkmarkButton in self.checkmarkButtons) {
        [checkmarkButton setSelected:YES];
    }
}


- (NSPredicate*)createPredicate
{
    [self saveFiltersToFilterManager];
    return [self.filterManager createReportLengthPredicate];
}

@end
