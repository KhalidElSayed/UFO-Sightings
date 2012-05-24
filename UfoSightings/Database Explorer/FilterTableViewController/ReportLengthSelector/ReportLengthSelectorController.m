//
//  ReportLengthSelectorController.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/16/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import "ReportLengthSelectorController.h"

@interface ReportLengthSelectorController ()

@end

@implementation ReportLengthSelectorController
@synthesize checkmarkButtons;
@synthesize tileBackgroundImageViews;
@synthesize predicateKey;
@synthesize filterOptions;

-(id)init
{
    if ((self = [super self]))
    {
        self.predicateKey = @"reportLength";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIImage* strechyBackgroundImage =  [[UIImage imageNamed:@"greyBoxStrechable.png"] stretchableImageWithLeftCapWidth:3 topCapHeight:3];
    
    for (UIImageView* imgView in self.tileBackgroundImageViews) {
        imgView.image = strechyBackgroundImage;
    }
    
    NSArray* lengthsToFilter = [filterOptions objectForKey:@"reportLengthsToFilter"];
    
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

- (void)viewDidUnload
{
    
    [self setTileBackgroundImageViews:nil];
    [self setCheckmarkButtons:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


-(void)viewWillDisappear:(BOOL)animated
{
  
    NSMutableArray* lengthsToFilter = [[NSMutableArray alloc]initWithCapacity:3];
    
    for (UIButton* checkmarkButton in self.checkmarkButtons) {
        
        if (checkmarkButton.isSelected)
            continue;
        
        if(checkmarkButton.tag == 0)
        {
            [lengthsToFilter addObject:@"short"];
        }
        else if (checkmarkButton.tag == 1) {
            [lengthsToFilter addObject:@"medium"];
        }
        else if (checkmarkButton.tag == 2) {
            [lengthsToFilter addObject:@"long"];
        }
        
        
    }
    
    NSMutableArray* filterCells = [filterOptions objectForKey:@"filterCells"];
    NSMutableDictionary* cell;
    for (NSMutableDictionary* cellDict in filterCells) {
        if([(NSString*)[cellDict objectForKey:@"predicateKey"] compare:self.predicateKey] == 0)
        {
            cell = cellDict;
            break;
        }
    }
    bool filters = lengthsToFilter.count > 0;
    
    if (filters) {
        NSMutableString* subtitle = [[NSMutableString alloc]init];
       
        for (NSString* string in lengthsToFilter) {
            [subtitle appendFormat:@"%@, ",string];
        }
        
        [subtitle deleteCharactersInRange:NSMakeRange(subtitle.length -2, 2)];
        [cell setObject:subtitle forKey:@"subtitle"];
    }
    
    [cell setObject:[NSNumber numberWithBool:filters ] forKey:@"hasFilters"];
    
    [self.filterOptions setObject:lengthsToFilter forKey:@"reportLengthsToFilter"];
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



-(BOOL)canReset
{
    BOOL hasChosenLengths = NO;
    for (UIButton* checkmarkButton in self.checkmarkButtons) {
        if (!checkmarkButton.isSelected)
        {
            hasChosenLengths = YES;
            break;
        }
    }
    
    return hasChosenLengths;
    
}


-(void)reset
{
    for (UIButton* checkmarkButton in self.checkmarkButtons) {
        [checkmarkButton setSelected:YES];
    }
}


-(NSPredicate*)createPredicate
{

    bool a = NO;
    bool b = NO;
    bool c = NO;
    
    for (UIButton* checkmarkButton in self.checkmarkButtons) {
        if (checkmarkButton.isSelected)
            continue;
        
        if(checkmarkButton.tag == 0)
        {
            a = YES;
        }
        else if (checkmarkButton.tag == 1) {
            b = YES;
        }
        else if (checkmarkButton.tag == 2) {
            c = YES;
        }
    }
    
    if( !a && !b && !c)
        return nil;
    else if (a && !b && !c) {
        return [NSPredicate predicateWithFormat:@"reportLength > 50"];
    }
    else if (a && b && !c) {
        return [NSPredicate predicateWithFormat:@"reportLength > 200"];
    }
    else if (!a && b && c) {
        return [NSPredicate predicateWithFormat:@"reportLength < 50"];
    }
    else if (!a && !b && c)
    {
        return [NSPredicate predicateWithFormat:@"reportLength < 200"];
    }
    else if (!a && b && !c) {
        return  [NSPredicate predicateWithFormat:@"reportLength < 50 OR reportLength > 200"];
    }
    else if (a && !b && c)
    {
        return  [NSPredicate predicateWithFormat:@"reportLength BETWEEN { 50 , 200 }"];
    }
    else {
        return [NSPredicate predicateWithFormat:@"FALSEPREDICATE"];
    }
    
       
    
    
    
}





@end
