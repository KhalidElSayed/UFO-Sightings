//
//  FilterViewControllerViewController.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/13/12.
//  Copyright (c) 2012 Home. All rights reserved.


#import <QuartzCore/QuartzCore.h>
#import "UFODatabaseExplorerViewController.h"
#import "UFORootController.h"
#import "FilterViewController.h"
#import "Sighting.h"
#import "ReportCell.h"
#import "UIColor+RKColor.h"

#define FILTER_NAV_FRAME CGRectMake(20, 171, 280, 320)
#define DEFAULT_FETCH_LIMIT 50

static dispatch_queue_t coredata_background_queue;
dispatch_queue_t CDbackground_queue()
{
    if (coredata_background_queue == NULL)
    {
        coredata_background_queue = dispatch_queue_create("com.richardKirk.coredata.backgroundfetches", DISPATCH_QUEUE_SERIAL);
    }
    return coredata_background_queue;
}

@interface UFODatabaseExplorerViewController ()
{
    NSDateFormatter*            _df;
    NSMutableDictionary*        _currentPredicates;
    UIActivityIndicatorView*    _cellLoadingIndicator;
    __block bool                _cancelFetch;
    NSManagedObjectContext*     _backgroundContext;

}
-(void)getMoreReportsWithLimit:(NSUInteger)limit;
-(NSPredicate*)fullPredicate;
-(void)filterCanReset:(NSNotification*)notification;
-(NSMutableDictionary*)retrieveFilterOptions;
-(void)saveFilterOptions:(NSDictionary*)options;
-(void)refreshReportsWithPredicate:(NSPredicate*)predicate andPredicateKey:(NSString*)predKey;

@end

@implementation UFODatabaseExplorerViewController
@synthesize addMoreButton = _addMoreButton;

@synthesize rootController;
@synthesize managedObjectContext;
@synthesize masterView = _masterView, detailView = _detailView;
@synthesize reportsTable = _reportsTable;
@synthesize reports = _reports;
@synthesize filterOptions = _filterOptions;
@synthesize backButton = _backButton, resetButton = _resetButton, viewOnMapButton = _viewOnMapButton;
@synthesize filterLabel = _filterLabel;
@synthesize loadingIndicator = _loadingIndicator, loadingLabel = _loadingLabel;

//***************************************************************************************************
#pragma mark - ViewController Life cycle
//***************************************************************************************************
-(id)init
{
    if ((self = [super init]))
    {
        _df = [[NSDateFormatter alloc]init];
        [_df setDateStyle:NSDateFormatterMediumStyle];
        _reports = [[NSArray alloc]init];
        _cancelFetch = NO;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"greyNoiseBackground.png"]];    
    [_reportsTable registerNib:[UINib nibWithNibName:@"ReportCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"reportCell"];
    
    _filterOptions = [self retrieveFilterOptions];
    _currentPredicates = [_filterOptions objectForKey:@"predicates"];
    FilterViewController* fvc = [[FilterViewController alloc]init];
    fvc.filterDict = _filterOptions;
    fvc.title = @"Filters";
    
        
    _filterNavController = [[UINavigationController alloc]initWithRootViewController:fvc];
    _filterNavController.view.frame = FILTER_NAV_FRAME;
    _filterNavController.delegate = self;
    _filterNavController.view.layer.borderWidth = 2.0f;
    _filterNavController.view.layer.borderColor = [UIColor blackColor].CGColor;
    _filterNavController.view.layer.cornerRadius = 4.0f;
    [_filterNavController setNavigationBarHidden:YES];
    [_masterView addSubview:_filterNavController.view];
    
    _reportsTable.layer.cornerRadius = 5.0f;
    self.backButton.superview.layer.cornerRadius = 10.0f;    
    self.backButton.superview.layer.borderWidth = 7.0f;
    self.backButton.superview.layer.borderColor = [UIColor rgbColorWithRed:33 green:33 blue:33 alpha:1.0].CGColor;
    _cellLoadingIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _cellLoadingIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    _cellLoadingIndicator.userInteractionEnabled = NO;
   
    _backgroundContext = [[NSManagedObjectContext alloc]init];
    _backgroundContext.persistentStoreCoordinator = self.managedObjectContext.persistentStoreCoordinator;
    
    [self getMoreReportsWithLimit:DEFAULT_FETCH_LIMIT];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filterCanReset:) name:@"FilterChoiceChanged" object:nil];
}


- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // TODO: Find out if I should keep a reference to this queue
    _backgroundContext = nil;
    [self saveFilterOptions:_filterOptions];
    [self setMasterView:nil];
    [self setDetailView:nil];
    [self setReportsTable:nil];
    [self setBackButton:nil];
    [self setResetButton:nil];
    [self setFilterLabel:nil];
    [self setViewOnMapButton:nil];
    [self setReports:nil];
    [self setLoadingIndicator:nil];
    [self setLoadingLabel:nil];
    [self setAddMoreButton:nil];
    [super viewDidUnload];
}


-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    UIDeviceOrientation deviceOrientation = [[UIApplication sharedApplication]statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(deviceOrientation )) 
    {   // Setup For Landscape
        [_detailView setFrame:CGRectMake(320, 0, self.view.bounds.size.width - 320, self.view.bounds.size.height)];    
        [self.view addSubview:_masterView];
    }
    else 
    {   // Setup For Portrait
        [_masterView removeFromSuperview];
        _detailView.frame = self.view.bounds;
    }
}


-(void)addMoreButtonSelected:(UIButton*)button
{

    [self getMoreReportsWithLimit:DEFAULT_FETCH_LIMIT];

}

//***************************************************************************************************





//***************************************************************************************************
#pragma mark - FilterOptions
//***************************************************************************************************
-(NSMutableDictionary*)retrieveFilterOptions
{
    if(_filterOptions != nil)
    {
        return _filterOptions;        
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filterPlistPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"filters.plist"];
    NSMutableDictionary* plist = [[NSMutableDictionary dictionaryWithContentsOfFile:filterPlistPath] mutableCopy];
    _filterOptions =  [plist objectForKey:@"Filters"];
    
    return _filterOptions;
}


-(void)saveFilterOptions:(NSDictionary*)options
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filterPlistPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"filters.plist"];
    NSMutableDictionary* plist = [NSMutableDictionary dictionaryWithContentsOfFile:filterPlistPath];
    [plist setObject:options forKey:@"Filters"];
    [plist writeToFile:filterPlistPath atomically:YES];
}
//***************************************************************************************************





//***************************************************************************************************
#pragma mark - UITableView Delegate/DataSource
//***************************************************************************************************
/**
 One section for all of the reports and one section with one row for the "add more" button 
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

/**
 We must ensure that if we are going to return the count of reports, it must be loaded. 
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0 && _reports )
        return [_reports count];
    else if(section == 1)
        return 1;
    
    return 0;
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
    
    if(indexPath.section == 0)
    {
        ReportCell *cell = [tableView dequeueReusableCellWithIdentifier:reportCellIdentifier];
        Sighting* sighting = [_reports objectAtIndex:indexPath.row];
        
        cell.sightedLabel.text = [_df stringFromDate:sighting.sightedAt];
        cell.reportedLabel.text = [_df stringFromDate:sighting.reportedAt];
        cell.reportTextView.text = sighting.report;
        cell.locationLabel.text =  sighting.location.formattedAddress; //[_sightingLocations objectAtIndex:indexPath.row];
        NSString* shapeString = [[_filterOptions objectForKey:@"badShapeMatching"] objectForKey:sighting.shape];
            
        if (!shapeString)
            shapeString = sighting.shape;
        
        NSString* imgString = [NSString stringWithFormat:@"%@.png", shapeString]; 
        cell.shapeImageView.image = [UIImage imageNamed:imgString];
        return cell;    
    }
    else if (indexPath.section == 1)
    {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:moreCellIdentifier];
        if(!cell)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:moreCellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            UIImage* strechyImage = [[UIImage imageNamed:@"blueStrechyBox.png"] stretchableImageWithLeftCapWidth:2 topCapHeight:9];
            UIImageView* imgView = [[UIImageView alloc]initWithImage:strechyImage];
            imgView.frame = cell.bounds;
            [cell setBackgroundView:imgView];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            
            [cell.contentView addSubview:_cellLoadingIndicator];
            [cell.contentView addSubview:_addMoreButton];
            _cellLoadingIndicator.center = cell.contentView.center;
            _addMoreButton.center = cell.contentView.center;
          
            
        }
        
        return cell;            
    }
    else 
        return [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"junk"];

}


/**
 When determining a height for the report cell it must be large enough to fit the report. 
 This is a problem when calculating 60,000 reports because while the UITableView does not
 load all of the data into the table at once, it does calculate the height for every cell up front. 
 */
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) 
    {
        if(indexPath.row == [_reports count])
            return 100.0f;
        
        NSString *text = [[_reports objectAtIndex:indexPath.row] report];
        CGSize constraint = CGSizeMake( _reportsTable.bounds.size.width - (20 * 2), 20000.0f);
        CGSize size = [text sizeWithFont:[UIFont fontWithName:@"Helvetica-Light" size:14] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        CGFloat height = MAX(size.height, 44.0f);
        
        return height + 120.0f;
    }
    else if(indexPath.section == 1)
        return 44.0f;
    
    return 0.0f;
}
//***************************************************************************************************





//***************************************************************************************************
#pragma mark - Filtering Functions
//***************************************************************************************************
/**
 This function gets called whenever the navigation controller will show a new view controller. 
 We will use this opportunity to determine if we should show the back button in our custom TitleView 
 */
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if([viewController isKindOfClass:[FilterViewController class]])
        self.backButton.alpha = 0.0f;
    else 
        self.backButton.alpha = 1.0f;
    
    self.filterLabel.text = viewController.title;
//    [navigationController setNavigationBarHidden:YES];
}


/**
 This will be called whenever one of the filter selection view controllers recognizes that
 it's state has been altered. 
 */
-(void)filterCanReset:(NSNotification*)notification 
{
    [self.resetButton setEnabled:[(id<PredicateCreation>)notification.object canReset]];
}


/**
 When showing a new view controller we want to check if it's state differs from default
 */
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
{
    self.resetButton.enabled = [(id<PredicateCreation>)viewController canReset];
}



-(NSPredicate*)fullPredicate
{
    if([[_currentPredicates allValues] count] > 0)
    {
        NSMutableArray* array = [[NSMutableArray alloc]initWithCapacity:4];
        
        if([_currentPredicates objectForKey:@"sightedAt"])
            [array addObject:[_currentPredicates objectForKey:@"sightedAt"]];
        if([_currentPredicates objectForKey:@"reportLength"])
            [array addObject:[_currentPredicates objectForKey:@"reportLength"]];
        if([_currentPredicates objectForKey:@"shape"])
            [array addObject:[_currentPredicates objectForKey:@"shape"]];
        if([_currentPredicates objectForKey:@"reportedAt"])
            [array addObject:[_currentPredicates objectForKey:@"reportedAt"]];
        return [[NSCompoundPredicate alloc]initWithType:NSAndPredicateType subpredicates:array];        
    }
    else
        return nil;
}

-(void)refreshReportsWithPredicate:(NSPredicate*)predicate andPredicateKey:(NSString*)predKey
{

    
    if(![predicate isEqual:[_currentPredicates objectForKey:predKey]] || (predKey == nil && predicate == nil))
    {
        if (predicate != nil) 
            [_currentPredicates setObject:predicate forKey:predKey];    
        else if( predKey != nil)
            [_currentPredicates removeObjectForKey:predKey];    
        
        [self.loadingIndicator startAnimating];
        [self.loadingLabel setHidden:NO];
        dispatch_async(CDbackground_queue(), ^{
            
            NSFetchRequest* fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Sighting"];
            //NSSortDescriptor* sort = [NSSortDescriptor sortDescriptorWithKey:@"sightedAt" ascending:NO];
            //[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
            NSPredicate* predicate = [self fullPredicate];
            NSUInteger limit = MAX(_reports.count, 50);
            [fetchRequest setFetchLimit:limit];
            [fetchRequest setPredicate:predicate];
            [fetchRequest setResultType:NSManagedObjectIDResultType];
            NSError* error = nil;
            NSArray* newReportIDs = [_backgroundContext executeFetchRequest:fetchRequest error:&error];
            if(error)
                NSLog(@"%@",error);
            
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                NSMutableArray* newReports = [[NSMutableArray alloc]initWithCapacity:DEFAULT_FETCH_LIMIT];
                for (NSManagedObjectID* ObjID in newReportIDs) {
                    [newReports addObject:[self.managedObjectContext objectWithID:ObjID]];
                }
                [newReports sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sightedAt" ascending:NO]]];
                _reports = newReports;
                [_reportsTable reloadData];
                [self.loadingIndicator stopAnimating];
                [self.loadingLabel setHidden:YES];
                

            });
            
        });
    }
}



-(void)getMoreReportsWithLimit:(NSUInteger)limit
{       
    /* Animating the Lading indicator*/
    if(!_addMoreButton.isSelected)
        [_addMoreButton setSelected:YES];
    [_cellLoadingIndicator startAnimating];

    
    dispatch_async(CDbackground_queue(), ^{
        
        NSFetchRequest* fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Sighting"];
        NSSortDescriptor* sort = [NSSortDescriptor sortDescriptorWithKey:@"sightedAt" ascending:NO];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
        [fetchRequest setFetchLimit:limit];
        NSPredicate* predicate = [self fullPredicate];
        if([_reports count] > 0)
        {
            NSDate* date = [[_reports lastObject] sightedAt];
            NSPredicate* datePredicate = [NSPredicate predicateWithFormat:@"sightedAt > %@", date]; 
            predicate = [[NSCompoundPredicate alloc]initWithType:NSAndPredicateType subpredicates:[NSArray arrayWithObjects:datePredicate, predicate, nil]];
        }
        [fetchRequest setPredicate:predicate];
        [fetchRequest setResultType:NSManagedObjectIDResultType];
        NSArray* newReportIDs = [_backgroundContext executeFetchRequest:fetchRequest error:nil];
                
        /* This is for smooth addition of cells */
        
        NSMutableArray* indexPaths = [[NSMutableArray alloc]init];
        int beginIndex = _reports ? _reports.count : 0;
        int endIndex = newReportIDs.count >= 5 ? beginIndex + 5 : beginIndex + newReportIDs.count - 1;
        for (int i = beginIndex; i < endIndex; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            NSMutableArray* newlyFetchedReports = [[NSMutableArray alloc]initWithCapacity:DEFAULT_FETCH_LIMIT];
            for (NSManagedObjectID* objID in newReportIDs) {
                [newlyFetchedReports addObject:[self.managedObjectContext objectWithID:objID]];
            }
            
            NSMutableArray* newArrayOfReports = [[NSMutableArray alloc]initWithArray:_reports];
            NSIndexSet *initialSetOfCellsToAdd = [[NSIndexSet alloc]initWithIndexesInRange:NSMakeRange(0, 5)];
            [newArrayOfReports addObjectsFromArray:[newlyFetchedReports objectsAtIndexes:initialSetOfCellsToAdd]];
            
            [_reportsTable beginUpdates];
            _reports = newArrayOfReports;
            [_reportsTable insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
            [_reportsTable reloadData];
            [_reportsTable endUpdates];
            
            if(newlyFetchedReports.count >= 5)
            {
                [newArrayOfReports removeObjectsAtIndexes:initialSetOfCellsToAdd];
                [newArrayOfReports addObjectsFromArray:newlyFetchedReports];
                _reports = newArrayOfReports;
                [_reportsTable reloadData];
            }
            
            [_cellLoadingIndicator stopAnimating];
            if(_addMoreButton.isSelected)
                [_addMoreButton setSelected:NO];
        });
    });
}
//***************************************************************************************************





//***************************************************************************************************
#pragma mark - IBActions
//***************************************************************************************************
- (IBAction)viewOnMapSelected:(UIButton *)sender 
{
    [self.rootController switchViewController];
}


- (IBAction)backButtonPressed:(UIButton *)sender 
{
    
    [(id<PredicateCreation>)_filterNavController.topViewController saveState];
    NSPredicate* predicate = [(id<PredicateCreation>)_filterNavController.topViewController createPredicate];
    NSString* predicateKey = [(id<PredicateCreation>)_filterNavController.topViewController predicateKey];
    [self refreshReportsWithPredicate:predicate andPredicateKey:predicateKey];
    
    if(_filterNavController.view.frame.size.height != 320)
    {
        
        [UIView animateWithDuration:0.5 animations:^{
            _filterNavController.view.frame = FILTER_NAV_FRAME;
        } completion:^(BOOL finished){
            if(finished)
                [_filterNavController popViewControllerAnimated:YES];
            
        }];
    }
    else 
        [_filterNavController popViewControllerAnimated:YES];
}


- (IBAction)resetButtonPressed:(UIButton *)sender 
{
    NSString* predicateKey = [(id <PredicateCreation>)_filterNavController.topViewController predicateKey];
    [(id <PredicateCreation>)_filterNavController.topViewController reset];
    
    if([predicateKey compare:@"main"] == 0)
    {
        [_currentPredicates removeAllObjects];
        [self refreshReportsWithPredicate:nil andPredicateKey:nil];
    }
    else if([_currentPredicates objectForKey:predicateKey])
        [_currentPredicates removeObjectForKey:predicateKey];
    
    [self.resetButton setEnabled:NO];    
}










@end
