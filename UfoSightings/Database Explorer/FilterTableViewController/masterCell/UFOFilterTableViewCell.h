//
//  MasterCell.h
//  UfoSightings
//
//  Created by Richard Kirk on 5/14/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UFOFilterTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *headerLabel;
@property (strong, nonatomic) IBOutlet UILabel *subtitleLabel;

- (void)configureWithDictionary:(NSDictionary*)cellDict;
- (void)animateLabelsHasFilters:(BOOL)filters;

@end
