//
//  FilterViewControllerViewController.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/13/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import "DatabaseExplorerViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Sighting.h"
#import "ReportCell.h"
#import "FilterViewController.h"
#import "UIColor+RKColor.h"


@interface DatabaseExplorerViewController ()
{
    UIImageView*    _separationLine;
    NSDateFormatter* _df;
    NSFetchedResultsController* _fetchController;
    NSMutableDictionary*    _currentPredicates;
}
-(void)setupForPortrait;
-(void)setupForLandscape;
-(void)reloadFetchWithSortDescriptors:(NSArray*)sorts andPredicate:(NSPredicate*)predicate;
-(void)getMoreReportsWithLimit:(NSUInteger)limit;
-(NSPredicate*)fullPredicate;
-(void)filterCanReset:(NSNotification*)notification;
@end

@implementation DatabaseExplorerViewController


#pragma mark - ViewController Life cycle
@synthesize masterView = _masterView, detailView = _detailView;
@synthesize reportsTable = _reportsTable;
@synthesize activityIndicator = _activityIndicator;
@synthesize managedObjectContext;
@synthesize reports = _reports;
@synthesize filterOptions = _filterOptions;
@synthesize backButton = _backButton;
@synthesize resetButton = _resetButton;
@synthesize filterLabel = _filterLabel;
@synthesize viewOnMapButton = _viewOnMapButton;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}


-(id)init
{
    if ((self = [super init]))
    {
        _df = [[NSDateFormatter alloc]init];
        _reports = [[NSMutableArray alloc]init];
        _currentPredicates = [[NSMutableDictionary alloc]initWithCapacity:4];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"greyNoiseBackground.png"]];
    
    [_reportsTable registerNib:[UINib nibWithNibName:@"ReportCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"reportCell"];
    
    [_df setDateStyle:NSDateFormatterMediumStyle];    
    UIImage* lineImg = [[UIImage imageNamed:@"lineWithShadow.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:1];
    _separationLine = [[UIImageView alloc]initWithImage:lineImg];
    
    
    FilterViewController* fvc = [[FilterViewController alloc]init];
    fvc.delegate = self;
    fvc.filterDict = self.filterOptions;
    fvc.title = @"Filters";
    
    //[fvc.view setFrame:CGRectMake(20, 96, 280, 556)];
    //fvc.view.layer.cornerRadius = 5.0f;
    
    _filterNavController = [[UINavigationController alloc]initWithRootViewController:fvc];
    _filterNavController.view.frame = CGRectMake(20, 171, 280, 320);
    //[_filterNavController pushViewController:fvc animated:YES];
    _filterNavController.delegate = self;
    _filterNavController.view.layer.borderWidth = 2.0f;
    _filterNavController.view.layer.borderColor = [UIColor blackColor].CGColor;
    _filterNavController.view.layer.cornerRadius = 4.0f;
    
    [_masterView addSubview:_filterNavController.view];
    
    
    _reportsTable.layer.cornerRadius = 5.0f;
    
    //NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"sightedAt" ascending:YES]; 
    //[self reloadFetchWithSortDescriptors:[NSArray arrayWithObject:sortDescriptor] andPredicate:nil];
    
    self.backButton.superview.layer.cornerRadius = 10.0f;    
    self.backButton.superview.layer.borderWidth = 7.0f;
    self.backButton.superview.layer.borderColor = [UIColor rgbColorWithRed:33 green:33 blue:33 alpha:1.0].CGColor;
    [self.viewOnMapButton addTarget:self.parentViewController action:@selector(switchViewController) forControlEvents:UIControlEventTouchUpInside];
    
    [self getMoreReportsWithLimit:100];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filterCanReset:) name:@"FilterChoiceChanged" object:nil];


}



- (void)viewDidUnload
{
    [self setMasterView:nil];
    [self setDetailView:nil];
    [self setReportsTable:nil];
    
    [self setActivityIndicator:nil];
    
    [self setBackButton:nil];
    [self setResetButton:nil];
    [self setFilterLabel:nil];
    [self setViewOnMapButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    UIDeviceOrientation deviceOrientation = [[UIApplication sharedApplication]statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(deviceOrientation )) {
        [self setupForLandscape];
    }
    else {
        [self setupForPortrait];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(void)setupForPortrait
{
    [_separationLine removeFromSuperview];
    [_masterView removeFromSuperview];
    _detailView.frame = self.view.bounds;
    
}


-(void)setupForLandscape
{
    [_separationLine setFrame:CGRectMake(320, 0, 5, self.view.frame.size.height)];
    [_detailView setFrame:CGRectMake(320, 0, self.view.bounds.size.width - 320, self.view.bounds.size.height)];
    
    [self.view addSubview:_separationLine];
    [self.view addSubview:_masterView];
    
}


#pragma mark - Setters/Getters


-(NSMutableDictionary*)filterOptions
{
    if(_filterOptions != nil)
    {
        return _filterOptions;        
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filterPlistPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"filters.plist"];
    NSDictionary* plist = [NSDictionary dictionaryWithContentsOfFile:filterPlistPath];
    
    _filterOptions =  [plist objectForKey:@"Filters"];
    
    return _filterOptions;
}


-(void)saveFilterOptions
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filterPlistPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"filters.plist"];
    NSMutableDictionary* plist = [NSMutableDictionary dictionaryWithContentsOfFile:filterPlistPath];
    
    [plist setObject:_filterOptions forKey:@"Filters"];
    [plist writeToFile:filterPlistPath atomically:YES];
    
}


#pragma mark - UITableViewDataSource 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (tableView == _reportsTable) {
        if(_reports)
            return [_reports count] + 1;
        else
            return 0;
    }
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
        cell.locationLabel.text = sighting.location.formattedAddress;
        
        NSString* shapeString = [[_filterOptions objectForKey:@"badShapeMatching"] objectForKey:sighting.shape];
            
        if (!shapeString)
            shapeString = sighting.shape;
        
        
        NSString* imgString = [NSString stringWithFormat:@"%@.png", shapeString]; 
        cell.shapeImageView.image = [UIImage imageNamed:imgString];
        return cell;    
    }
    else if (indexPath.row == [_reports count]){
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:moreCellIdentifier];
        if(!cell)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:moreCellIdentifier];
            UIImage* strechyImage = [[UIImage imageNamed:@"blueStrechyBox.png"] stretchableImageWithLeftCapWidth:2 topCapHeight:9];
        UIImageView* imgView = [[UIImageView alloc]initWithImage:strechyImage];
        imgView.frame = cell.bounds;
        [cell setBackgroundView:imgView];

        }
        
        return cell;            
    }
    else 
        return [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"s"];

}


#pragma mark - UITableViewDelegate



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(tableView == _reportsTable && indexPath.row == [_reports count])
        [self getMoreReportsWithLimit:100];
    
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [_reports count]) {
        
        //NSLog(@"%d",indexPath.row);
        if(indexPath.row == [_reports count])
            return 100.0f;
        
        NSString *text = [[_reports objectAtIndex:indexPath.row] report];
        
        CGSize constraint = CGSizeMake( _reportsTable.bounds.size.width - (20 * 2), 20000.0f);
        
        CGSize size = [text sizeWithFont:[UIFont fontWithName:@"Helvetica-Light" size:14] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        
        CGFloat height = MAX(size.height, 44.0f);
        
        return height + 120.0f;
        
        //  UITextView *tv = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, _reportsTable.bounds.size.width - 40, 0)];
        //[tv setFont:[UIFont fontWithName:@"Helvetica-Light" size:14]];
        //[tv setText:[[_reports objectAtIndex:indexPath.row] report]];
        //return 45 + tv.contentSize.height + 5.0f;
        
    }
    else 
        return 44.0f;
}


-(NSPredicate*)fullPredicate
{
    if([[_currentPredicates allValues] count] > 0)
        return [[NSCompoundPredicate alloc]initWithType:NSAndPredicateType subpredicates:[_currentPredicates allValues]];
    else
        return nil;
}


-(void)reloadFetchWithSortDescriptors:(NSArray*)sorts andPredicate:(NSPredicate*)predicate;
{
    
    
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Sighting"];
    
    [fetchRequest setSortDescriptors:sorts];
    [fetchRequest setPredicate:predicate];
    
    _fetchController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    _reportsTable.alpha = 0.0f;
    [self.activityIndicator startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        NSError* error;
        [_fetchController performFetch:&error];
        if(!error)
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [_reportsTable reloadData];
                [self.activityIndicator stopAnimating];
                _reportsTable.alpha = 1.0f;
            });
            
            
        }
        
    });
    
    
    
}


-(void)getMoreReportsWithLimit:(NSUInteger)limit
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
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
        
        [_reports addObjectsFromArray:[self.managedObjectContext executeFetchRequest:fetchRequest error:nil]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_reportsTable reloadData];
        });
        
    });
    
    
    
}


#pragma mark - FilterDelegate 
// Called when the navigation controller shows a new top view controller via a push, pop or setting of the view controller stack.
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if([viewController isKindOfClass:[FilterViewController class]])
    {
        self.backButton.alpha = 0.0f;
    }
    else 
    {
        self.backButton.alpha = 1.0f;
    }
    
    self.filterLabel.text = viewController.title;
    
    [navigationController setNavigationBarHidden:YES];
    //[(UITableView*)viewController.view reloadData];
}


- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
{
    self.resetButton.enabled = [(id<PredicateCreation>)viewController canReset];
}


- (IBAction)viewOnMapSelected:(UIButton *)sender 
{

}

- (IBAction)backButtonPressed:(UIButton *)sender {
    
    
    
    NSPredicate* predicate = [(id<PredicateCreation>)_filterNavController.topViewController createPredicate];
    NSString* predicateKey = [(id<PredicateCreation>)_filterNavController.topViewController predicateKey];
    if(![predicate isEqual:[_currentPredicates objectForKey:predicateKey]])
    {
       
        if (predicate != nil) {
        [_currentPredicates setObject:predicate forKey:predicateKey];
        }
        else {
            [_currentPredicates removeObjectForKey:predicateKey];
        }
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSFetchRequest* fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Sighting"];
            NSSortDescriptor* sort = [NSSortDescriptor sortDescriptorWithKey:@"sightedAt" ascending:NO];
            [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
            NSPredicate* predicate = [self fullPredicate];
            [fetchRequest setFetchLimit:MAX(_reports.count, 100)];
         
            [fetchRequest setPredicate:predicate];

            NSError* error = nil;
            NSArray* newReports = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            
            if(error)
                NSLog(@"%@",error);
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
            

                _reports = [newReports mutableCopy];
                [_reportsTable reloadData];

        });
            
            });


        }
            
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

-(void)filterCanReset:(NSNotification*)notification 
{
    [self.resetButton setEnabled:[(id<PredicateCreation>)notification.object canReset]];
}

- (IBAction)resetButtonPressed:(UIButton *)sender 
{
    NSString* predicateKey = [(id <PredicateCreation>)_filterNavController.topViewController predicateKey];

    [(id <PredicateCreation>)_filterNavController.topViewController reset];
    if([predicateKey compare:@"main"] == 0)
    {
        [_currentPredicates removeAllObjects];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSFetchRequest* fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Sighting"];
            NSSortDescriptor* sort = [NSSortDescriptor sortDescriptorWithKey:@"sightedAt" ascending:NO];
            [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
            NSPredicate* predicate = [self fullPredicate];
            [fetchRequest setFetchLimit:MAX(_reports.count, 100)];
            // if([_reports count] > 0)
            //{
            //  NSDate* date = [[_reports lastObject] sightedAt];
            //NSPredicate* datePredicate = [NSPredicate predicateWithFormat:@"sightedAt > %@", date]; 
            //      predicate = [[NSCompoundPredicate alloc]initWithType:NSAndPredicateType subpredicates:[NSArray arrayWithObjects:datePredicate, predicate, nil]];
            // }
            
            [fetchRequest setPredicate:predicate];
            
            NSError* error = nil;
            NSArray* newReports = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            
            if(error)
                NSLog(@"%@",error);
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                _reports = [newReports mutableCopy];
                [_reportsTable reloadData];
                
            });
            
        });

    }
    else if([_currentPredicates objectForKey:predicateKey])
                [_currentPredicates removeObjectForKey:predicateKey];
    
    
        

    [self.resetButton setEnabled:NO];
    
}
@end
