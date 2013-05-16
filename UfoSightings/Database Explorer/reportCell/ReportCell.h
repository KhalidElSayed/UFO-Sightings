//
//  ReportCell.h
//  UfoSightings
//
//  Created by Richard Kirk on 5/14/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *sightedLabel;
@property (strong, nonatomic) IBOutlet UILabel *reportedLabel;
@property (strong, nonatomic) IBOutlet UITextView *reportTextView;
@property (strong, nonatomic) IBOutlet UIImageView *shapeImageView;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;

- (CGFloat)mySize;
@end
