//
//  FilterViewControllerViewController.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/13/12.
//  Copyright (c) 2012 Home. All rights reserved.


#import <QuartzCore/QuartzCore.h>
#import "DatabaseExplorerViewController.h"
#import "RootController.h"
#import "FilterViewController.h"
#import "Sighting.h"
#import "ReportCell.h"
#import "UIColor+RKColor.h"


static dispatch_queue_t coredata_background_queue;
dispatch_queue_t CDbackground_queue()
{
    if (coredata_background_queue == NULL)
    {
        coredata_background_queue = dispatch_queue_create("com.richardKirk.coredata.backgroundfetches", 0);
    }
    return coredata_background_queue;
}

@interface DatabaseExplorerViewController ()
{
    NSDateFormatter*            _df;
    NSMutableDictionary*        _currentPredicates;
    UIActivityIndicatorView*    _cellLoadingIndicator;
}
-(void)getMoreReportsWithLimit:(NSUInteger)limit;
-(NSPredicate*)fullPredicate;
-(void)filterCanReset:(NSNotification*)notification;
-(NSMutableDictionary*)retrieveFilterOptions;
-(void)saveFilterOptions:(NSDictionary*)options;
-(void)refreshReportsWithPredicate:(NSPredicate*)predicate andPredicateKey:(NSString*)predKey;
@end

@implementation DatabaseExplorerViewController

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
        _reports = [[NSMutableArray alloc]init];

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
    _filterNavController.view.frame = CGRectMake(20, 171, 280, 320);
    _filterNavController.delegate = self;
    _filterNavController.view.layer.borderWidth = 2.0f;
    _filterNavController.view.layer.borderColor = [UIColor blackColor].CGColor;
    _filterNavController.view.layer.cornerRadius = 4.0f;

    [_masterView addSubview:_filterNavController.view];
    
    _reportsTable.layer.cornerRadius = 5.0f;
    self.backButton.superview.layer.cornerRadius = 10.0f;    
    self.backButton.superview.layer.borderWidth = 7.0f;
    self.backButton.superview.layer.borderColor = [UIColor rgbColorWithRed:33 green:33 blue:33 alpha:1.0].CGColor;

    [self getMoreReportsWithLimit:100];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filterCanReset:) name:@"FilterChoiceChanged" object:nil];
}


- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    dispatch_release(CDbackground_queue());
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_reports)
        return [_reports count] + 1;
    else
        return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* reportCellIdentifier = @"reportCell";
    static NSString* moreCellIdentifier = @"moreCell";
    
    if(indexPath.row < [_reports count])
    {
        ReportCell *cell = [tableView dequeueReusableCellWithIdentifier:reportCellIdentifier];
        Sighting* sighting = [_reports objectAtIndex:indexPath.row];
        
        cell.sightedLabel.text = [_df stringFromDate:sighting.sightedAt];
        cell.reportedLabel.text = [_df stringFromDate:sighting.reportedAt];
        cell.reportTextView.text = sighting.report;
      //  cell.locationLabel.text = sighting.location.formattedAddress;
        NSString* shapeString = [[_filterOptions objectForKey:@"badShapeMatching"] objectForKey:sighting.shape];
            
        if (!shapeString)
            shapeString = sighting.shape;
        
        NSString* imgString = [NSString stringWithFormat:@"%@.png", shapeString]; 
        cell.shapeImageView.image = [UIImage imageNamed:imgString];
        return cell;    
    }
    else if (indexPath.row == [_reports count])
    {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:moreCellIdentifier];
        if(!cell)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:moreCellIdentifier];
            UIImage* strechyImage = [[UIImage imageNamed:@"blueStrechyBox.png"] stretchableImageWithLeftCapWidth:2 topCapHeight:9];
            UIImageView* imgView = [[UIImageView alloc]initWithImage:strechyImage];
            imgView.frame = cell.bounds;
            [cell setBackgroundView:imgView];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            UIActivityIndicatorView* aiv = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            
            [cell addSubview:aiv];
            aiv.center = cell.center;
            _cellLoadingIndicator = aiv;
            
        }
        
        return cell;            
    }
    else 
        return [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"junk"];

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if(tableView == _reportsTable && indexPath.row == [_reports count])
        [self getMoreReportsWithLimit:100];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [_reports count]) 
    {
        if(indexPath.row == [_reports count])
            return 100.0f;
        
        NSString *text = [[_reports objectAtIndex:indexPath.row] report];
        CGSize constraint = CGSizeMake( _reportsTable.bounds.size.width - (20 * 2), 20000.0f);
        CGSize size = [text sizeWithFont:[UIFont fontWithName:@"Helvetica-Light" size:14] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        CGFloat height = MAX(size.height, 44.0f);
        
        return height + 120.0f;
    }
    else 
        return 44.0f;
}
//***************************************************************************************************





//***************************************************************************************************
#pragma mark - Filtering Functions
//***************************************************************************************************
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if([viewController isKindOfClass:[FilterViewController class]])
        self.backButton.alpha = 0.0f;
    else 
        self.backButton.alpha = 1.0f;
    
    self.filterLabel.text = viewController.title;
    [navigationController setNavigationBarHidden:YES];
}


-(void)filterCanReset:(NSNotification*)notification 
{
    [self.resetButton setEnabled:[(id<PredicateCreation>)notification.object canReset]];
}


- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
{
    self.resetButton.enabled = [(id<PredicateCreation>)viewController canReset];
}



-(NSPredicate*)fullPredicate
{
    if([[_currentPredicates allValues] count] > 0)
        return [[NSCompoundPredicate alloc]initWithType:NSAndPredicateType subpredicates:[_currentPredicates allValues]];
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
            NSSortDescriptor* sort = [NSSortDescriptor sortDescriptorWithKey:@"sightedAt" ascending:NO];
            [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
            NSPredicate* predicate = [self fullPredicate];
            NSUInteger limit = MAX(_reports.count, 100);
            NSLog(@"%i", limit);
            [fetchRequest setFetchLimit:limit];
            [fetchRequest setPredicate:predicate];
            
            NSError* error = nil;
            __block NSArray* newReports = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if(error)
                NSLog(@"%@",error);
            
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.loadingIndicator stopAnimating];
                [self.loadingLabel setHidden:YES];
                _reports = [newReports mutableCopy];
                [_reportsTable reloadData];
            });
            
        });
    }
}



-(void)getMoreReportsWithLimit:(NSUInteger)limit
{   
    
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
        NSArray* results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [_cellLoadingIndicator stopAnimating];
            [_reports addObjectsFromArray:results];
            [_reportsTable reloadData];
            
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
    
    
    NSPredicate* predicate = [(id<PredicateCreation>)_filterNavController.topViewController createPredicate];
    NSString* predicateKey = [(id<PredicateCreation>)_filterNavController.topViewController predicateKey];
    [self refreshReportsWithPredicate:predicate andPredicateKey:predicateKey];
    
    if(_filterNavController.view.frame.size.height != 320)
    {
        CGRect frame = _filterNavController.view.frame;
        frame.size.height = 320;
        
        [UIView animateWithDuration:0.5 animations:^{
            _filterNavController.view.frame = frame;
        } completion:^(BOOL finished){
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
