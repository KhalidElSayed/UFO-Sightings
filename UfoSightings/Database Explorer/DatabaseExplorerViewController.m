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


@interface DatabaseExplorerViewController ()
{
    UIImageView*    _separationLine;
    NSDateFormatter* _df;
    NSFetchedResultsController* _fetchController;
    NSPredicate*            _currentPredicate;
    
}
-(void)setupForPortrait;
-(void)setupForLandscape;
-(void)reloadFetchWithSortDescriptors:(NSArray*)sorts andPredicate:(NSPredicate*)predicate;
-(void)getMoreReportsWithLimit:(NSUInteger)limit;
@end

@implementation DatabaseExplorerViewController


#pragma mark - ViewController Life cycle
@synthesize masterView = _masterView;
@synthesize detailView = _detailView;
@synthesize reportsTable = _reportsTable;
@synthesize activityIndicator = _activityIndicator;
@synthesize managedObjectContext;
@synthesize reports = _reports;
@synthesize filterOptions = _filterOptions;


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
        _currentPredicate = nil;
        _reports = [[NSMutableArray alloc]init];
        
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
    //[fvc.view setFrame:CGRectMake(20, 96, 280, 556)];
    //fvc.view.layer.cornerRadius = 5.0f;

    _filterNavController = [[UINavigationController alloc]initWithRootViewController:fvc];
    _filterNavController.view.frame = CGRectMake(20, 96, 280, 556);
    //[_filterNavController pushViewController:fvc animated:YES];
    _filterNavController.delegate = fvc;
    
    [_masterView addSubview:_filterNavController.view];
    

    _reportsTable.layer.cornerRadius = 5.0f;
    
    //NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"sightedAt" ascending:YES]; 
    //[self reloadFetchWithSortDescriptors:[NSArray arrayWithObject:sortDescriptor] andPredicate:nil];
    
        
 
    [self getMoreReportsWithLimit:100];
    
    
}



- (void)viewDidUnload
{
    [self setMasterView:nil];
    [self setDetailView:nil];
    [self setReportsTable:nil];

    [self setActivityIndicator:nil];

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



-(NSMutableDictionary*)defaultFilterOptions
{
    NSMutableDictionary* fo = [[NSMutableDictionary alloc]init];
    

    
    [fo setObject:[[Sighting oldestSightingBasedOn:@"sightedAt"] sightedAt] forKey:@"earliestSightedAtDate"];
    [fo setObject:[[Sighting oldestSightingBasedOn:@"reportedAt"] reportedAt] forKey:@"earliestReportedAtDate"];
    [fo setObject:[[Sighting newestSightingBasedOn:@"sightedAt"] sightedAt] forKey:@"newestSightedAtDate"];
    [fo setObject:[[Sighting newestSightingBasedOn:@"reportedAt"] reportedAt] forKey:@"newestReportedAtDate"];
    
    
    
    return fo;
    
    
}

-(NSMutableDictionary*)filterOptions
{
    
    if (!_filterOptions) {
        _filterOptions = [self defaultFilterOptions];
    }
    return _filterOptions;
    
}


#pragma mark - UITableViewDataSource 
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
    

    if (tableView == _reportsTable) 
    {
        
        
        ReportCell *cell = [tableView dequeueReusableCellWithIdentifier:reportCellIdentifier];
        if(indexPath.row < [_reports count])
        {
            Sighting* sighting = [_reports objectAtIndex:indexPath.row];
            
            cell.sightedLabel.text = [_df stringFromDate:sighting.sightedAt];
            cell.reportedLabel.text = [_df stringFromDate:sighting.reportedAt];
            cell.reportTextView.text = sighting.report;
          
            NSString* shapeString = [sighting.shape stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([shapeString caseInsensitiveCompare:@"changed"] == 0) 
                shapeString = @"changing";
            else if([shapeString caseInsensitiveCompare:@"light"] == 0)
                shapeString = @"flash";
            else if ([shapeString caseInsensitiveCompare:@"sphere"] == 0)
                shapeString = @"circle";
            else if ([shapeString caseInsensitiveCompare:@"unknown"] == 0|| [shapeString caseInsensitiveCompare:@"unspecified"] == 0)
                shapeString = @"other";
            
            NSString* imgString = [NSString stringWithFormat:@"%@.png", shapeString]; 
            cell.shapeImageView.image = [UIImage imageNamed:imgString];
        }
        else {
            cell.backgroundColor = [UIColor blueColor];
        }
        
        return cell;    
    }
    else
        return nil;
}


#pragma mark - UITableViewDelegate



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == _reportsTable && indexPath.row == [_reports count])
        [self getMoreReportsWithLimit:100];
    
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _reportsTable) {

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
        NSPredicate* predicate = _currentPredicate;
        if([_reports count] > 0)
        {
            NSDate* date = [[_reports lastObject] sightedAt];
            NSPredicate* datePredicate = [NSPredicate predicateWithFormat:@"sightedAt > %@", date]; 
            predicate = [[NSCompoundPredicate alloc]initWithType:NSAndPredicateType subpredicates:[NSArray arrayWithObjects:datePredicate, _currentPredicate, nil]];
        }
        [fetchRequest setPredicate:predicate];
    
        [_reports addObjectsFromArray:[self.managedObjectContext executeFetchRequest:fetchRequest error:nil]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_reportsTable reloadData];
        });
        
    });

    
    
}



#pragma mark - FilterDelegate 

-(void)filterViewController:(FilterViewController*)fvc didUpdatePredicate:(NSPredicate*)predicate
{
    
    _currentPredicate = predicate;
    
    [_reports filterUsingPredicate:_currentPredicate];
    if (_reports.count < 100) {
        [self getMoreReportsWithLimit:100 - _reports.count];
    }
    else {
        [_reportsTable reloadData];
    }
    
}













































@end
