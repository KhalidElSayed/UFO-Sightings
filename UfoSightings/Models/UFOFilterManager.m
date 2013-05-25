//
//  UFOFilterManager.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/22/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "UFOFilterManager.h"
#import "NSFileManager+Extras.h"
#import "NSDate+Extras.h"

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

- (NSDateFormatter*)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc]init];
        [_dateFormatter setDateFormat:@"yyyyMMdd"];
    }
    return _dateFormatter;
}

- (NSMutableDictionary*)filterDictionary
{
    if(!_filterDictionary){
        NSString *filterPlistPath = [[NSFileManager defaultManager] filterDictonaryPath];
        _filterDictionary = [[NSMutableDictionary dictionaryWithContentsOfFile:filterPlistPath] mutableCopy];
    }
    return _filterDictionary;
}


- (void)saveFilters
{
    if(!_filterDictionary) { return; }
    NSString *filterPlistPath = [[NSFileManager defaultManager] filterDictonaryPath];
    [self.filterDictionary writeToFile:filterPlistPath atomically:YES];
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
    if([date isEqualToDate:self.filterDictionary[kUFOSelectedReportedAtMinimumDate]]) { return; }
    [self.filterDictionary setObject:date forKey:kUFOSelectedReportedAtMinimumDate];
    self.hasNewFilters = YES;
}

- (void)setSelectedReportedAtMaximumDate:(NSDate *)date
{
    if([date isEqualToDate:self.filterDictionary[kUFOSelectedReportedAtMaximumDate]]) { return; }
    [self.filterDictionary setObject:date forKey:kUFOSelectedReportedAtMaximumDate];
    self.hasNewFilters = YES;
}

- (void)setSelectedSightedAtMinimumDate:(NSDate*)date
{
    if([date isEqualToDate:self.filterDictionary[kUFOSelectedSightedAtMinimumDate]]) { return; }
    [self.filterDictionary setObject:date forKey:kUFOSelectedSightedAtMinimumDate];
    self.hasNewFilters = YES;
}

- (void)setSelectedSightedAtMaximumDate:(NSDate*)date
{
    if([date isEqualToDate:self.filterDictionary[kUFOSelectedSightedAtMaximumDate]]) { return; }
    [self.filterDictionary setObject:date forKey:kUFOSelectedSightedAtMaximumDate];
    self.hasNewFilters = YES;
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
    return self.filterDictionary[kUFOSelectedSightedAtMaximumDate];
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
    if([reportLengths isEqualToArray:self.filterDictionary[kUFOReportLengthsFilterKey]]) { return; }
    [self.filterDictionary setObject:reportLengths forKey:kUFOReportLengthsFilterKey];
    self.hasNewFilters = YES;
}

#pragma mark - Shapes Filtering

- (NSArray*)shapesToFilter
{
    return [self.filterDictionary objectForKey:kUFOShapesFilterKey];
}

- (void)setShapesToFilter:(NSArray*)shapes
{
    if([shapes isEqualToArray:self.filterDictionary[kUFOShapesFilterKey]]) { return; }
    [self.filterDictionary setObject:shapes forKey:kUFOShapesFilterKey];
    self.hasNewFilters = YES;
}


#pragma mark - predicate creation

- (NSPredicate*)createReportedAtPredicate
{
    NSMutableArray* predicates = [[NSMutableArray alloc]initWithCapacity:2];
    
    if(![[self selectedReportedAtMinimumDate] dateInSameYear:[self defaultReportedAtMinimumDate]]) {
        NSPredicate* minimumDatePredicate = [NSPredicate predicateWithFormat:@"%K > %@", kUFOReportedAtCellPredicateKey, [self selectedReportedAtMinimumDate]];
        [predicates addObject:minimumDatePredicate];
    }
    if(![[self selectedReportedAtMaximumDate] dateInSameYear:[self defaultReportedAtMaximumDate]]) {
        NSPredicate* maximumDatePredicate = [NSPredicate predicateWithFormat:@"%K < %@", kUFOReportedAtCellPredicateKey, [self selectedReportedAtMaximumDate]];
        [predicates addObject:maximumDatePredicate];
    }
    
    if([predicates count] == 1) {
        return predicates[0];
    }
    else if([predicates count] == 2) {
        return [[NSCompoundPredicate alloc]initWithType:NSAndPredicateType subpredicates:predicates];
    }
    
    return nil;
}


- (NSPredicate*)createSightedAtPredicate
{
    NSMutableArray* predicates = [[NSMutableArray alloc]initWithCapacity:2];
    
    if(![[self selectedSightedAtMinimumDate] dateInSameYear:[self defaultSightedAtMinimumDate]]) {
        NSPredicate* minimumDatePredicate = [NSPredicate predicateWithFormat:@"%K > %@", kUFOSightedAtCellPredicateKey, [self selectedSightedAtMinimumDate]];
        [predicates addObject:minimumDatePredicate];
    }
    if(![[self selectedSightedAtMaximumDate] dateInSameYear:[self defaultSightedAtMaximumDate]]) {
        NSPredicate* maximumDatePredicate = [NSPredicate predicateWithFormat:@"%K < %@", kUFOSightedAtCellPredicateKey, [self selectedSightedAtMaximumDate]];
        [predicates addObject:maximumDatePredicate];
    }
    
    if([predicates count] == 1) {
        return predicates[0];
    }
    else if([predicates count] == 2) {
        return [[NSCompoundPredicate alloc]initWithType:NSAndPredicateType subpredicates:predicates];
    }
    
    return nil;
}


- (NSPredicate*)createShapesPredicate
{
    
    NSMutableArray* predicates = [[NSMutableArray alloc]init];
    NSDictionary* badShapeMapping = [[NSFileManager defaultManager] shapeNameMappingDictionary];
    
    for (NSString* shapeToFilter in [self shapesToFilter]) {
        
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"shape != %@", shapeToFilter];
        [predicates addObject:predicate];
        for (NSString* shapeMatchedString in [badShapeMapping allKeysForObject:shapeToFilter]) {
            NSPredicate* badShapePredicate = [NSPredicate predicateWithFormat:@"shape != %@", shapeMatchedString];
            [predicates addObject:badShapePredicate];
        }
        
    }
    
    if ([predicates count] == 1) {
        return predicates[0];
    }
    else if ([predicates count] > 1) {
        return [[NSCompoundPredicate alloc]initWithType:NSAndPredicateType subpredicates:predicates];
    }
    
    return  nil;
}


- (NSPredicate*)createReportLengthPredicate
{
    bool a = [[self reportLengthsToFilter] containsObject:@"short"];
    bool b = [[self reportLengthsToFilter] containsObject:@"medium"];
    bool c = [[self reportLengthsToFilter] containsObject:@"long"];
    
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



- (NSPredicate*)buildPredicate
{
    NSMutableArray* predicates = [[NSMutableArray alloc]initWithCapacity:4];
    NSPredicate* sightedAtPredicate = [self createSightedAtPredicate];
    NSPredicate* reportedAtPredicate = [self createReportedAtPredicate];
    NSPredicate* shapesPredicate = [self createShapesPredicate];
    NSPredicate* reportLengthPredicate = [self createReportLengthPredicate];
    
    if(sightedAtPredicate)      { [predicates addObject:sightedAtPredicate]; }
    if(reportedAtPredicate)     { [predicates addObject:reportedAtPredicate]; }
    if( shapesPredicate)        { [predicates addObject:shapesPredicate]; }
    if(reportLengthPredicate)   { [predicates addObject:reportLengthPredicate]; }

    if ([predicates count] == 1) {
        return predicates[0];
    }
    else if ([predicates count] > 1){
        return [[NSCompoundPredicate alloc]initWithType:NSAndPredicateType subpredicates:predicates];
    }
    self.hasNewFilters = NO;
    return nil;
}

@end
