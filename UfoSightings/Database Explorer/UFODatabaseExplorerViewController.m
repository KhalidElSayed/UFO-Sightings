//
//  FilterViewControllerViewController.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/13/12.
//  Copyright (c) 2012 Home. All rights reserved.


#import <QuartzCore/QuartzCore.h>
#import "UFODatabaseExplorerViewController.h"
#import "UFORootController.h"
#import "UFOFilterViewController.h"
#import "Sighting.h"
#import "UFOReportCell.h"
#import "UIColor+RKColor.h"
#import "NSManagedObjectContext+Extras.h"
#import "NSFileManager+Extras.h"

#define FILTER_NAV_FRAME CGRectMake(20, 171, 280, 320)
#define DEFAULT_FETCH_LIMIT 50

static dispatch_queue_t coredata_background_queue;
dispatch_queue_t CDbackground_queue()
{
    if (coredata_background_queue == NULL) {
        coredata_background_queue = dispatch_queue_create("com.richardKirk.coredata.backgroundfetches", DISPATCH_QUEUE_SERIAL);
    }
    return coredata_background_queue;
}

@interface UFODatabaseExplorerViewController ()
{
    UIActivityIndicatorView*    _cellLoadingIndicator;
    __block bool                _cancelFetch;
    NSManagedObjectContext*     _backgroundContext;
    NSDictionary*               _shapesDictionary;
}
@property (strong, nonatomic) NSDateFormatter* dateFormatter;
@property (strong, nonatomic) NSMutableDictionary* currentPredicates;
@property (strong, nonatomic) UIActivityIndicatorView* cellLoadingIndicator;

- (void)getMoreReportsWithLimit:(NSUInteger)limit;
- (void)filterCanReset:(NSNotification*)notification;
- (void)saveFilterOptions:(NSDictionary*)options;
- (void)refreshReportsWithPredicate:(NSPredicate*)predicate;
@end



@implementation UFODatabaseExplorerViewController

#pragma mark - ViewController Life cycle

- (id)init
{
    if ((self = [super init])) {
        _reports = [[NSArray alloc]init];
        _cancelFetch = NO;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"greyNoiseBackground.png"]];    
    [self.reportsTable registerNib:[UINib nibWithNibName:@"UFOReportCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"reportCell"];
    
    self.currentPredicates = [[self.filterManager predicates] mutableCopy];
    
    [self.masterView addSubview:self.filterNavController.view];
    
    self.reportsTable.layer.cornerRadius = 5.0f;
    self.backButton.superview.layer.cornerRadius = 10.0f;    
    self.backButton.superview.layer.borderWidth = 7.0f;
    self.backButton.superview.layer.borderColor = [UIColor rgbColorWithRed:33 green:33 blue:33 alpha:1.0].CGColor;
    
    _backgroundContext = [[NSManagedObjectContext alloc]init];
    _backgroundContext.persistentStoreCoordinator = self.managedObjectContext.persistentStoreCoordinator;
    
    [self getMoreReportsWithLimit:DEFAULT_FETCH_LIMIT];
    self.lastPredicateFetched = [[NSPredicate alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filterCanReset:) name:@"FilterChoiceChanged" object:nil];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // TODO: Find out if I should keep a reference to this queue
    _backgroundContext = nil;
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    UIDeviceOrientation deviceOrientation = [[UIApplication sharedApplication]statusBarOrientation];
    
    if (UIInterfaceOrientationIsLandscape(deviceOrientation )) {   // Setup For Landscape
        [self.detailView setFrame:CGRectMake(320, 0, self.view.bounds.size.width - 320, self.view.bounds.size.height)];
        [self.view addSubview:self.masterView];
    }
    else {   // Setup For Portrait
        [self.masterView removeFromSuperview];
        self.detailView.frame = self.view.bounds;
    }
}


#pragma mark - Setters/Getters

- (NSDateFormatter*)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc]init];
        [_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    }
    return _dateFormatter;
}


- (UINavigationController*)filterNavController
{
    if(!_filterNavController) {
        UFOFilterViewController* fvc = [[UFOFilterViewController alloc]init];
        _filterNavController = [[UINavigationController alloc]initWithRootViewController:fvc];
        
        _filterNavController.view.frame = FILTER_NAV_FRAME;
        _filterNavController.delegate = self;
        _filterNavController.view.layer.borderWidth = 2.0f;
        _filterNavController.view.layer.borderColor = [UIColor blackColor].CGColor;
        _filterNavController.view.layer.cornerRadius = 4.0f;
        [_filterNavController setNavigationBarHidden:YES];
    }
    return _filterNavController;
}


- (UIActivityIndicatorView*)cellLoadingIndicator
{
    if(!_cellLoadingIndicator) {
        _cellLoadingIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _cellLoadingIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _cellLoadingIndicator.userInteractionEnabled = NO;
    }
    return _cellLoadingIndicator;
}


- (NSDictionary*)shapesDictionary
{
    if (!_shapesDictionary) {
        _shapesDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSFileManager defaultManager] shapesDictionaryPath]];
    }
    return _shapesDictionary;
}


#pragma mark - IBActions

- (IBAction)viewOnMapSelected:(UIButton *)sender
{
    [self.delegate UFODatabaseExplorerWantsToViewMap:self];
}


- (IBAction)backButtonPressed:(UIButton *)sender
{
    [(id<UFOPredicateCreation>)self.filterNavController.topViewController saveFiltersToFilterManager];
    
    if(self.filterManager.hasNewFilters) {
        [self refreshReportsWithPredicate:[self.filterManager buildPredicate]];
    }
    
    if(self.filterNavController.view.frame.size.height == 320) {
        [self.filterNavController popViewControllerAnimated:YES];
    }
    else {
        [UIView animateWithDuration:0.5 animations:^{
            self.filterNavController.view.frame = FILTER_NAV_FRAME;
        } completion:^(BOOL finished){
            if(finished) {
                [self.filterNavController popViewControllerAnimated:YES];
            }
        }];
    }

}


- (IBAction)resetButtonPressed:(UIButton *)sender
{
    [(id <UFOPredicateCreation>)self.filterNavController.topViewController resetInterface];
    if([self.filterNavController.topViewController isKindOfClass:[UFOFilterViewController class]]) {
        [self refreshReportsWithPredicate:[self.filterManager buildPredicate]];
    }
    [self.resetButton setEnabled:NO];
}


- (IBAction)addMoreButtonSelected:(UIButton*)button
{
    [self getMoreReportsWithLimit:DEFAULT_FETCH_LIMIT];
}


#pragma mark - UITableView Delegate/DataSource

// One section for all of the reports and one section with one row for the "add more" button
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


// We must ensure that if we are going to return the count of reports, it must be loaded.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    if(section > 1) { return 0; }
    return section == 0 ? [self.reports count] : 1;
}


/**
 This function deals with two cell styles. The more complicated of the two being ReportCell
 ReportCell has been subclassed and we use the filter dictionary to determine which Image to 
 use in the cell. The second cell is a much simplier cell which uses a strechable background image to 
 display a blue gradient. 
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* reportCellIdentifier = @"reportCell";
    static NSString* moreCellIdentifier = @"moreCell";
    
    if(indexPath.section == 0) {
        UFOReportCell *cell = [tableView dequeueReusableCellWithIdentifier:reportCellIdentifier];
        Sighting* sighting = [self.reports objectAtIndex:indexPath.row];
        
        cell.sightedLabel.text = [self.dateFormatter stringFromDate:sighting.sightedAt];
        cell.reportedLabel.text = [self.dateFormatter stringFromDate:sighting.reportedAt];
        cell.reportTextView.text = sighting.report;
        cell.locationLabel.text =  sighting.location.formattedAddress;
        NSString* shapeString = [[self.shapesDictionary objectForKey:@"badShapeMatching"] objectForKey:sighting.shape];
            
        if (!shapeString) {
            shapeString = sighting.shape;
        }
        
        cell.shapeImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", shapeString]];
        return cell;    
    }
    else if (indexPath.section == 1) {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:moreCellIdentifier];
        
        if(!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:moreCellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            UIImage* strechyImage = [[UIImage imageNamed:@"blueStrechyBox.png"] stretchableImageWithLeftCapWidth:2 topCapHeight:9];
            UIImageView* imgView = [[UIImageView alloc]initWithImage:strechyImage];
            imgView.frame = cell.bounds;
            [cell setBackgroundView:imgView];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            [cell.contentView addSubview:self.cellLoadingIndicator];
            [cell.contentView addSubview:self.addMoreButton];
            self.cellLoadingIndicator.center = cell.contentView.center;
            self.addMoreButton.center = cell.contentView.center;
        }
        
        return cell;            
    }
    else {
        return [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"junk"];
    }
}


/**
 When determining a height for the report cell it must be large enough to fit the report. 
 This is a problem when calculating 60,000 reports because while the UITableView does not
 load all of the data into the table at once, it does calculate the height for every cell up front. 
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if(indexPath.row == [self.reports count]) { return 100.0f; }
        
        NSString *text = [[self.reports objectAtIndex:indexPath.row] report];
        CGSize constraint = CGSizeMake( self.reportsTable.bounds.size.width - (20 * 2), 20000.0f);
        CGSize size = [text sizeWithFont:[UIFont fontWithName:@"Helvetica-Light" size:14] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        CGFloat height = MAX(size.height, 44.0f);
        
        return height + 120.0f;
    }
    else if(indexPath.section == 1) {
        return 44.0f;
    }
    
    return 0.0f;
}


#pragma mark - Filtering Functions

/**
 This function gets called whenever the navigation controller will show a new view controller. 
 We will use this opportunity to determine if we should show the back button in our custom TitleView 
 */
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    self.backButton.alpha = [viewController isKindOfClass:[UFOFilterViewController class]] ? 0.0 : 1.0f;
    self.filterLabel.text = viewController.title;
}


/**
 This will be called whenever one of the filter selection view controllers recognizes that
 it's state has been altered. 
 */
- (void)filterCanReset:(NSNotification*)notification 
{
    [self.resetButton setEnabled:[(id<UFOPredicateCreation>)notification.object canReset]];
}


/**
 When showing a new view controller we want to check if it's state differs from default
 */
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
{
    self.resetButton.enabled = [(id<UFOPredicateCreation>)viewController canReset];
}


- (void)refreshReportsWithPredicate:(NSPredicate*)predicate
{
    if (self.lastPredicateFetched == predicate) { return; }
    
    [self.loadingIndicator startAnimating];
    [self.loadingLabel setHidden:NO];
    
    dispatch_async(CDbackground_queue(), ^{
        
        NSFetchRequest* fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Sighting"];
        NSSortDescriptor* sort = [NSSortDescriptor sortDescriptorWithKey:@"sightedAt" ascending:NO];
        
        [fetchRequest setFetchLimit:MAX(_reports.count, 50)];
        [fetchRequest setSortDescriptors:@[sort]];
        [fetchRequest setResultType:NSManagedObjectIDResultType];
        
        if(predicate) {
            [fetchRequest setPredicate:predicate];
        }
        
        NSError* error = nil;
        NSArray* newReportIDs = [_backgroundContext executeFetchRequest:fetchRequest error:&error];
        if(error) { NSLog(@"%@",error); }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            NSMutableArray* newReports = [[NSMutableArray alloc]initWithCapacity:DEFAULT_FETCH_LIMIT];
            for (NSManagedObjectID* ObjID in newReportIDs) {
                [newReports addObject:[self.managedObjectContext objectWithID:ObjID]];
            }
            
            self.reports = newReports;
            [self.reportsTable reloadData];
            [self.loadingIndicator stopAnimating];
            [self.loadingLabel setHidden:YES];
            self.lastPredicateFetched = predicate;
        });
    });
}



- (void)getMoreReportsWithLimit:(NSUInteger)limit
{
    /* Animating the Loading indicator*/
    if(!self.addMoreButton.isSelected) {
        [self.addMoreButton setSelected:YES];
    }
    [self.cellLoadingIndicator startAnimating];

    __block NSPredicate* predicate = self.lastPredicateFetched;
    dispatch_async(CDbackground_queue(), ^{
        
        NSFetchRequest* fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Sighting"];
        NSSortDescriptor* sort = [NSSortDescriptor sortDescriptorWithKey:@"sightedAt" ascending:NO];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
        [fetchRequest setFetchLimit:limit];
        [fetchRequest setResultType:NSManagedObjectIDResultType];
        
        /* since we already have a set of reports, only load ones further below */
        if([self.reports count] > 0) {
            NSDate* date = [[self.reports lastObject] sightedAt];
            NSPredicate* datePredicate = [NSPredicate predicateWithFormat:@"sightedAt > %@", date]; 
            predicate = [[NSCompoundPredicate alloc]initWithType:NSAndPredicateType subpredicates: predicate == nil ? @[datePredicate] : @[datePredicate, predicate]];
        }
        
        if(predicate) {
            [fetchRequest setPredicate:predicate];
        }
        
        NSArray* newReportIDs = [_backgroundContext executeFetchRequest:fetchRequest error:nil];
                
        /* This is for smooth addition of cells */
        NSMutableArray* indexPaths = [[NSMutableArray alloc] init];
        int beginIndex = self.reports ? self.reports.count : 0;
        int endIndex = newReportIDs.count >= 5 ? beginIndex + 5 : beginIndex + newReportIDs.count - 1;
        for (int i = beginIndex; i < endIndex; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            NSArray* newlyFetchedReports =  [self.managedObjectContext objectsWithIDs:newReportIDs];
            
            NSMutableArray* newArrayOfReports = [[NSMutableArray alloc]initWithArray:self.reports];
            NSIndexSet *initialSetOfCellsToAdd = [[NSIndexSet alloc]initWithIndexesInRange:NSMakeRange(0, 5)];
            [newArrayOfReports addObjectsFromArray:[newlyFetchedReports objectsAtIndexes:initialSetOfCellsToAdd]];
            
            [self.reportsTable beginUpdates];
            self.reports = newArrayOfReports;
            [self.reportsTable insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
            [self.reportsTable reloadData];
            [self.reportsTable endUpdates];
            
            if(newlyFetchedReports.count >= 5) {
                [newArrayOfReports removeObjectsAtIndexes:initialSetOfCellsToAdd];
                [newArrayOfReports addObjectsFromArray:newlyFetchedReports];
                self.reports = newArrayOfReports;
                [self.reportsTable reloadData];
            }
            
            [self.cellLoadingIndicator stopAnimating];
            
            if(self.addMoreButton.isSelected) {
                [self.addMoreButton setSelected:NO];
            }
        });
    });
}

@end
