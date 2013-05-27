//
//  UFOFilterManager.h
//  UfoSightings
//
//  Created by Richard Kirk on 5/22/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kUFOReportedAPredicateKey = @"reportedAt";
static NSString * const kUFOReportLengthPredicateKey = @"reportLength";
static NSString * const kUFOShapePredicateKey = @"shape";
static NSString * const kUFOSightedAtPredicateKey = @"sightedAt";

@interface UFOFilterManager : NSObject

@property (strong, nonatomic) NSDateFormatter* dateFormatter;
@property (assign, nonatomic) bool hasNewFilters;

@property (nonatomic, readonly) NSDate* defaultReportedAtMaximumDate;
@property (nonatomic, readonly) NSDate* defaultReportedAtMinimumDate;
@property (nonatomic, readonly) NSDate* defaultSightedAtMinimumDate;
@property (nonatomic, readonly) NSDate* defaultSightedAtMaximumDate;

@property (nonatomic) NSDate* selectedReportedAtMaximumDate;
@property (nonatomic) NSDate* selectedReportedAtMinimumDate;
@property (nonatomic) NSDate* selectedSightedAtMaximumDate;
@property (nonatomic) NSDate* selectedSightedAtMinimumDate;

+ (UFOFilterManager*)sharedManager;

- (NSDictionary*)predicates;
- (NSArray*)filterCells;

- (void)resetFilters;
- (void)saveFilters;

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
