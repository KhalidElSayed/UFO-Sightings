//
//  ReportLengthSelectorController.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/16/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import "ReportLengthSelectorController.h"

@implementation ReportLengthSelectorController
@synthesize predicateKey;
- (id)init
{
    if ((self = [super self])) {
        self.title = @"Reports";
        self.predicateKey = @"reportLength";
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
        switch (checkMarkButton.tag) {
            case 0:
                [checkMarkButton setSelected:![lengthsToFilter containsObject:@"short"]];
                break;
            case 1:
                [checkMarkButton setSelected:![lengthsToFilter containsObject:@"medium"]];
                break;
            case 2:
                [checkMarkButton setSelected:![lengthsToFilter containsObject:@"long"]];
                break;
            default:
                break;
        }
    }
}


- (void)saveState
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
    
    [self.filterManager setReportLengthsToFilter:lengthsToFilter];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)checkmarkButtonSelected:(UIButton *)sender 
{    
    [sender setSelected:!sender.isSelected];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FilterChoiceChanged" object:self];
}

- (BOOL)canReset
{
    BOOL hasChosenLengths = NO;
    for (UIButton* checkmarkButton in self.checkmarkButtons) {
        if (!checkmarkButton.isSelected) {
            hasChosenLengths = YES;
            break;
        }
    }
    
    return hasChosenLengths;
}


- (void)reset
{
    for (UIButton* checkmarkButton in self.checkmarkButtons) {
        [checkmarkButton setSelected:YES];
    }
}


- (NSPredicate*)createPredicate
{
    [self saveState];
    return [self.filterManager createReportLengthPredicate];
}

@end
