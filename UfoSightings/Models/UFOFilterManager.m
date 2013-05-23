//
//  UFOFilterManager.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/22/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "UFOFilterManager.h"
#import "NSFileManager+Extras.h"

static NSString * const kUFOSightedAtMinimumDate = @"sightedAtMinimumDate";
static NSString * const kUFOSightedAtMaximumDate = @"sightedAtMaximumDate";
static NSString * const kUFOReportedAtMinimumDate = @"reportedAtMinimumDate";
static NSString * const kUFOReportedAtMaximumDate = @"reportedAtMaximumDate";


static NSString * const kUFOSelectedSightedAtMinimumDate = @"sightedAtSelectedMinimumDate";
static NSString * const kUFOSelectedSightedAtMaximumDate = @"sightedAtSelectedMaximumDate";
static NSString * const kUFOSelectedReportedAtMinimumDate = @"reportedAtSelectedMinimumDate";
static NSString * const kUFOSelectedReportedAtMaximumDate = @"reportedAtSelectedMaximumDate";

static NSString * const kUFOReportLengthsFilterKey = @"reportLengthsToFilter";
static NSString * const kUFOShapesFilterKey = @"shapesToFilter";

@interface UFOFilterManager ()
@property (strong, nonatomic) NSMutableDictionary* filterDictionary;
- (void)saveFilterDictionary:(NSDictionary*)filterDict;
@end

@implementation UFOFilterManager

+ (UFOFilterManager*)sharedManager
{
    static UFOFilterManager * singleton;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [ [ UFOFilterManager alloc ] init ];
    });
    return singleton;
}


- (NSMutableDictionary*)filterDictionary
{
    if(!_filterDictionary){
        NSString *filterPlistPath = [[NSFileManager defaultManager] filterDictonaryPath];
        _filterDictionary = [[NSMutableDictionary dictionaryWithContentsOfFile:filterPlistPath] mutableCopy];
    }
    return _filterDictionary;
}


- (void)saveFilterDictionary:(NSDictionary*)filterDict
{
    NSString *filterPlistPath = [[NSFileManager defaultManager] filterDictonaryPath];
    [filterDict writeToFile:filterPlistPath atomically:YES];
}


- (NSDictionary*)predicates
{
    return [self.filterDictionary objectForKey:@"predicates"];
}

- (NSArray*)filterCells
{
    return [self.filterDictionary objectForKey:@"filterCells"];
}

- (void)resetFilters
{
    [[NSFileManager defaultManager] moveDatabaseFiltersPlistIntoProjectShouldOverwrite:YES];
    _filterDictionary = nil;
}


#pragma mark - Sighted/Reported Dates

- (void)setSelectedReportedAtMinimumDate:(NSDate*)date
{
    [self.filterDictionary setObject:date forKey:kUFOSelectedReportedAtMinimumDate];
}

- (void)setSelectedReportedAtMaximumDate:(NSDate *)date
{
    [self.filterDictionary setObject:date forKey:kUFOSelectedReportedAtMaximumDate];
}

- (void)setSelectedSightedAtMinimumDate:(NSDate*)date
{
    [self.filterDictionary setObject:date forKey:kUFOSelectedSightedAtMinimumDate];
}

- (void)setSelectedSightedAtMaximumDate:(NSDate*)date
{
    [self.filterDictionary setObject:date forKey:kUFOSelectedSightedAtMinimumDate];
}

- (NSDate*)selectedReportedAtMinimumDate
{
    return self.filterDictionary[kUFOSelectedReportedAtMinimumDate];
}

- (NSDate*)selectedReportedAtMaximumDate
{
    return self.filterDictionary[kUFOSelectedReportedAtMaximumDate];
}

- (NSDate*)selectedSightedAtMinimumDate
{
    return self.filterDictionary[kUFOSelectedSightedAtMinimumDate];
}

- (NSDate*)selectedSightedAtMaximumDate
{
    return self.filterDictionary[kUFOSelectedSightedAtMinimumDate];
}

- (NSDate*)defaultReportedAtMinimumDate
{
    return [self.filterDictionary objectForKey:kUFOReportedAtMinimumDate];
}

- (NSDate*)defaultReportedAtMaximumDate
{
    return [self.filterDictionary objectForKey:kUFOReportedAtMaximumDate];
}

- (NSDate*)defaultSightedAtMinimumDate
{
    return [self.filterDictionary objectForKey:kUFOSightedAtMinimumDate];
}

- (NSDate*)defaultSightedAtMaximumDate
{
    return [self.filterDictionary objectForKey:kUFOSightedAtMaximumDate];
}


- (void)setHasFilters:(BOOL)filter forCellWithPredicateKey:(NSString *)predicateKey
{
    NSMutableDictionary* cell;
    for (NSMutableDictionary* cellDict in self.filterCells) {
        
        if([(NSString*)[cellDict objectForKey:@"predicateKey"] compare:predicateKey] == 0) {
            cell = cellDict;
            break;
        }
    }
    
    if(!cell) {return;}

    [cell setObject:[NSNumber numberWithBool:filter] forKey:@"hasFilters"];
}


- (void)setSubtitle:(NSString*)subtitle forCellWithPredicateKey:(NSString *)predicateKey
{
    NSMutableDictionary* cell;
    for (NSMutableDictionary* cellDict in self.filterCells) {
        
        if([(NSString*)[cellDict objectForKey:@"predicateKey"] compare:predicateKey] == 0) {
            cell = cellDict;
            break;
        }
    }
    
    if(!cell) {return;}
    
    [cell setObject:subtitle forKey:@"subtitle"];
}


#pragma mark - Report Lengths Filtering

- (NSArray*)reportLengthsToFilter
{
    return [self.filterDictionary objectForKey:kUFOReportLengthsFilterKey];
}


- (void)setReportLengthsToFilter:(NSArray *)reportLengths
{
    [self.filterDictionary setObject:reportLengths forKey:kUFOReportLengthsFilterKey];
}

#pragma mark - Shapes Filtering

- (NSArray*)shapesToFilter
{
    return [self.filterDictionary objectForKey:kUFOShapesFilterKey];
}

- (void)setShapesToFilter:(NSArray*)shapes
{
    [self.filterDictionary setObject:shapes forKey:kUFOShapesFilterKey];
}

@end
