//
//  UFOFilterManager.h
//  UfoSightings
//
//  Created by Richard Kirk on 5/22/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kUFOReportedAtCellPredicateKey = @"reportedAt";
static NSString * const kUFOReportLengthCellPredicateKey = @"reportLength";
static NSString * const kUFOShapeCellPredicateKey = @"shape";
static NSString * const kUFOSightedAtCellPredicateKey = @"sightedAt";

@interface UFOFilterManager : NSObject

@property (strong, nonatomic) NSDateFormatter* dateFormatter;
@property (assign, nonatomic) bool hasNewFilters;

+ (UFOFilterManager*)sharedManager;

- (NSDictionary*)predicates;
- (NSArray*)filterCells;

- (void)resetFilters;
- (void)saveFilters;

- (void)setSelectedReportedAtMinimumDate:(NSDate*)date;
- (void)setSelectedReportedAtMaximumDate:(NSDate*)date;
- (void)setSelectedSightedAtMinimumDate:(NSDate*)date;
- (void)setSelectedSightedAtMaximumDate:(NSDate*)date;

- (NSDate*)selectedReportedAtMinimumDate;
- (NSDate*)selectedReportedAtMaximumDate;
- (NSDate*)selectedSightedAtMinimumDate;
- (NSDate*)selectedSightedAtMaximumDate;

- (NSDate*)defaultReportedAtMinimumDate;
- (NSDate*)defaultReportedAtMaximumDate;
- (NSDate*)defaultSightedAtMinimumDate;
- (NSDate*)defaultSightedAtMaximumDate;

- (void)setHasFilters:(BOOL)filter forCellWithPredicateKey:(NSString*)predicateKey;
- (void)setSubtitle:(NSString*)subtitle forCellWithPredicateKey:(NSString *)predicateKey;

- (NSArray*)reportLengthsToFilter;
- (void)setReportLengthsToFilter:(NSArray*)reportLengths;

- (NSArray*)shapesToFilter;
- (void)setShapesToFilter:(NSArray*)shapes;


- (NSPredicate*)createReportedAtPredicate;
- (NSPredicate*)createSightedAtPredicate;
- (NSPredicate*)createShapesPredicate;
- (NSPredicate*)createReportLengthPredicate;
- (NSPredicate*)buildPredicate;

@end
