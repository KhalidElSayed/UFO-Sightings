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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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


}

- (void)viewDidUnload
{

    [self setTileBackgroundImageViews:nil];
    [self setCheckmarkButtons:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)checkmarkButtonSelected:(UIButton *)sender 
{    
    [sender setSelected:!sender.isSelected];
}


-(NSPredicate*)createPredicate
{
    NSMutableSet* predicates = [NSMutableSet setWithCapacity:3];
    for (UIButton* checkmarkButton in self.checkmarkButtons) {
    
        if (checkmarkButton.isSelected)
            continue;
        
        if(checkmarkButton.tag == 0)
        {
            
        }
        
        
    }
    
    
    
    
}





@end
