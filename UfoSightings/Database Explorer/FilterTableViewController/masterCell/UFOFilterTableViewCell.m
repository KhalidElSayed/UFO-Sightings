//
//  MasterCell.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/14/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import "UFOFilterTableViewCell.h"

@implementation UFOFilterTableViewCell

- (void)configureWithDictionary:(NSDictionary *)cellDict
{
    [self.headerLabel setText:[cellDict objectForKey:@"title"]];
    BOOL cellHasFilters = [(NSNumber*)[cellDict objectForKey:@"hasFilters"] boolValue];
    if(cellHasFilters) {
        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"masterCellSelected.png"]];
        [self.subtitleLabel setText:[cellDict objectForKey:@"subtitle"]];
    }
    else {
        self.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"masterCell.png"]];
    }
    
    [self animateLabelsHasFilters:cellHasFilters];
}


- (void)animateLabelsHasFilters:(BOOL)filters
{
    CGRect headerLabelFrame = self.headerLabel.frame;
    if(filters) {
        if (headerLabelFrame.origin.y == 0) { return; }
        headerLabelFrame.origin.y = 0;
        
        [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationCurveEaseInOut animations:^{
            self.headerLabel.frame = headerLabelFrame;
        } completion:^(BOOL finished){
            [UIView animateWithDuration:0.3 animations:^{
                self.subtitleLabel.alpha = 1.0f;
            }];
        }];
    }
    else {
        if(headerLabelFrame.origin.y == 20.0f) { return; }
        
        headerLabelFrame.origin.y = 20.0f;

        [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationCurveEaseInOut animations:^{
            self.headerLabel.frame = headerLabelFrame;
            self.subtitleLabel.alpha = 0.0f;
        } completion:^(BOOL finished){
            [self.subtitleLabel setText:@""];
        }];
    }
}

@end
