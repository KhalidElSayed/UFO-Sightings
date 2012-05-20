//
//  PaperView.h
//  UfoSightings
//
//  Created by Richard Kirk on 5/8/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaperView : UIView
@property (strong, nonatomic) IBOutlet UIImageView *topImageView;
@property (strong, nonatomic) IBOutlet UIImageView *leftImageView;
@property (strong, nonatomic) IBOutlet UIImageView *rightImageView;
@property (strong, nonatomic) IBOutlet UIImageView *BottomImageView;
@property (strong, nonatomic) IBOutlet UILabel *sightedLabel;
@property (strong, nonatomic) IBOutlet UILabel *ReportedLabel;
@property (strong, nonatomic) IBOutlet UILabel *durationLabel;
@property (strong, nonatomic) IBOutlet UITextView *reportTextView;


-(void)randomize;

@end
