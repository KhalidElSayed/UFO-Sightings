//
//  MapModalView.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/9/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import "MapModalView.h"
#import "Sighting.h"
#import "SightingLocation.h"
#import "MapModalCell.h"
#import "PaperView.h"

@interface MapModalView ()
{
    NSMutableArray* _pages;
    bool pageControlUsed;
    Sighting* _currentSighting;
    NSUInteger _currentSelectionIndex;

    
}
@property (strong, nonatomic)NSArray* _sightings;
-(void)setupSlider;
-(void)setupForPortrait;
-(void)setupForLandscape;
-(void)displayDocumentWithSighting:(Sighting*)sighting animated:(BOOL)animate;
@end

@implementation MapModalView
@synthesize documentView;
@synthesize paperViewPlaceholder = _paperViewPlaceholder;
@synthesize tableView = _tableView, scrollView = _scrollView;
@synthesize location = _location;
@synthesize _sightings;
@synthesize df;
@synthesize backgroundImageView = _backgroundImageView;
@synthesize sliderPageControl;

#pragma mark - UIViewController Functions
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(id)initWithSightingLocation:(SightingLocation*)location
{
    if ((self = [super init]))
    {
        [self setLocation:location];
        _currentSighting = [_sightings objectAtIndex:0];
        df = [[NSDateFormatter alloc]init];
        [df setDateStyle:NSDateFormatterMediumStyle];
        _currentSelectionIndex = 0;
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.tableView registerNib:[UINib nibWithNibName:@"MapModalCell" bundle:[NSBundle mainBundle]]  forCellReuseIdentifier:@"modalCell"];
    
    _pages = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < [_sightings count]; i++)
		[_pages addObject:[NSNull null]];
    
    
    [self setupSlider];
    
}

- (void)viewDidUnload
{
    [self setDocumentView:nil];
    [self setTableView:nil];
    [self setPaperViewPlaceholder:nil];
    [self setScrollView:nil];
    [self setBackgroundImageView:nil];
    _pages = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    
    
	return YES;
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


-(void)setupForLandscape
{
    self.backgroundImageView.image = [UIImage imageNamed:@"modalBackground.png"];
    [self.tableView setFrame:CGRectMake(45, 27, 214, 461)];
    [self.paperViewPlaceholder setFrame:CGRectMake(320, 45, 375, 535)];
    
    //NSIndexPath* currentElement = [NSIndexPath indexPathForRow:[sliderPageControl currentPage] inSection:0];
    NSIndexPath* currentElement = [NSIndexPath indexPathForRow:_currentSelectionIndex inSection:0];
    [self.tableView selectRowAtIndexPath:currentElement animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    PaperView *paperView = [self paperViewForIndex:_currentSelectionIndex];
    
    
    if(paperView.superview)
    {
        [paperView removeFromSuperview];
    }
    
    paperView.frame = self.paperViewPlaceholder.bounds;
    
    if ([[self.paperViewPlaceholder subviews] count] != 0) {
        for (UIView* view in self.paperViewPlaceholder.subviews) {
            
            [view removeFromSuperview];
        }
    }
    
    [self.paperViewPlaceholder addSubview:paperView];
    
    [self.scrollView setFrame:CGRectZero];
    [self.sliderPageControl setFrame:CGRectZero];
    
}

-(void)setupForPortrait
{
    
    self.backgroundImageView.image = [UIImage imageNamed:@"modalBackgroundPortrait.png"];
    
    [self.scrollView setFrame:CGRectMake(36, 75, 495, 711)];
    [self.sliderPageControl setFrame:CGRectMake(36, 794, 495, 20)];
    [self resizeScrollView];
    
    
    /*
     PaperView* paperView;    
     if ([self.paperViewPlaceholder.subviews count] != 0) {
     paperView = [self.paperViewPlaceholder.subviews lastObject];
     [paperView removeFromSuperview];
     }
     else {
     paperView = [self paperViewForIndex:self.tableView.indexPathForSelectedRow.row];
     }
     
     if ([_pages objectAtIndex:self.tableView.indexPathForSelectedRow.row]) {
     [_pages removeObjectAtIndex:self.tableView.indexPathForSelectedRow.row];
     }
     [_pages insertObject:paperView atIndex:self.tableView.indexPathForSelectedRow.row];
     
     */  
    
    PaperView *paperView = [self paperViewForIndex:_currentSelectionIndex];
    if(paperView.superview)
        [paperView removeFromSuperview];
    
    
    [self changeToPage:_currentSelectionIndex + 1 animated:NO];
    [self.paperViewPlaceholder setFrame:CGRectZero];
    
    [self.tableView setFrame:CGRectZero];
    
}


#pragma mark - Custom setters

-(void)setLocation:(SightingLocation *)location
{
    _location = location;
    
    NSMutableSet *fillerSet = [[NSMutableSet alloc]init];
    
    [fillerSet unionSet:[_location sighting]];
    
    for (SightingLocation* containedLocation in [_location containedAnnotations]) {
        [fillerSet unionSet:[containedLocation sighting]];
    }
    
    
    _sightings = [[fillerSet allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        Sighting* a = (Sighting*)obj1;
        Sighting* b = (Sighting*)obj2;
        return [a.sightedAt compare:b.sightedAt];
    }];
    
    
    /*    
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
     
     
     NSMutableSet *fillerSet = [[NSMutableSet alloc]init];
     
     [fillerSet unionSet:[_location sighting]];
     
     for (SightingLocation* containedLocation in [_location containedAnnotations]) {
     [fillerSet unionSet:[containedLocation sighting]];
     }
     
     
     _sightings = [[fillerSet allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
     Sighting* a = (Sighting*)obj1;
     Sighting* b = (Sighting*)obj2;
     return [a.sightedAt compare:b.sightedAt];
     }];
     
     dispatch_async(dispatch_get_main_queue(), ^{
     [self.view setNeedsLayout];
     });
     
     });
     
     
     
     */  
}


#pragma mark - UITableViewDataSource 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_sightings count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* modalCellIdentifier = @"modalCell";
    
    Sighting* aSighting = [_sightings objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:modalCellIdentifier];
    NSString *theName = [self.df stringFromDate:aSighting.sightedAt];
    
    NSLog(@"%@",theName);
    [[(MapModalCell *)cell label] setText:theName];
    return cell;
    
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_currentSelectionIndex != indexPath.row)    
    {
        _currentSelectionIndex = indexPath.row;
        PaperView *paperView = [self paperViewForIndex:_currentSelectionIndex];
        
        if(paperView.superview)
            [paperView removeFromSuperview];
        
        paperView.frame = self.paperViewPlaceholder.bounds;
        
        if ([[self.paperViewPlaceholder subviews] count] != 0) {
            for (UIView* view in self.paperViewPlaceholder.subviews) {
                
                [view removeFromSuperview];
            }
        }
        
        [self.paperViewPlaceholder addSubview:paperView];
    }
}


-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView* header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 214, 40)];
    header.backgroundColor = [UIColor clearColor];
    
    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 214, 30)];
    [label setFont:[UIFont fontWithName:@"Courier-Bold" size:15.0f]];
    [label setTextColor:[UIColor whiteColor]];
    [label setAdjustsFontSizeToFitWidth:YES];
    [label setMinimumFontSize:10.0f];
    [label  setBackgroundColor:[UIColor clearColor]];
    [label setText:@"SELECT SIGHTING"];
    
    
    [header addSubview:label];
    
    UIImageView* imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 30, 166, 10)];
    [imgView setImage:[UIImage imageNamed:@"line.png"]];
    
    [header addSubview:imgView];
    
    return header;
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}


#pragma mark - IBActions


- (IBAction)exitSelected:(id)sender 
{
    
    for (UIView* view in [self.view subviews]) {
        NSLog(@"%@",view);
    }
    
    
    //    [self dismissModalViewControllerAnimated:YES];
    
    
}


-(void)displayDocumentWithSighting:(Sighting*)sighting animated:(BOOL)animate
{
    PaperView* paperView;
    for (UIView* view in [self.view subviews]) {
        if ([view class] == [PaperView class]) {
            paperView = (PaperView*)view;
        }
        
    }
    
    if (!paperView) {
        paperView = [self paperViewForIndex:[_sightings indexOfObject:sighting]];
    }
    else {
        
        NSString* sightedString = [self.df stringFromDate:sighting.sightedAt];
        NSString* reportedString = [self.df stringFromDate:sighting.reportedAt];
        NSString* durationString = sighting.duration;
        NSString* reportString = sighting.report;
        
        [paperView.sightedLabel setText:sightedString];
        [paperView.ReportedLabel setText:reportedString];
        [paperView.reportTextView setText:reportString];
        [paperView.durationLabel setText:durationString];
        [paperView randomize];
    }
    
    paperView.frame = self.paperViewPlaceholder.frame;
    self.paperViewPlaceholder = paperView;
    paperView.alpha = 0.0f;
    
    [self.view addSubview:paperView];
    if (animate) {
        [UIView animateWithDuration:1.0f delay:0.0f options:UIViewAnimationCurveEaseInOut animations:^{
            paperView.alpha = 1.0f;
        } completion:^(BOOL finished){}];
    }
    else {
        paperView.alpha = 1.0f;
    }
    
}


-(PaperView*)paperViewForIndex:(NSUInteger)index
{
    
    PaperView* aPaperView;
    
    aPaperView = [_pages objectAtIndex:index];
    
    if ((NSNull *)aPaperView == [NSNull null] || aPaperView == nil)
    {
        aPaperView = [[PaperView alloc]init];
        [_pages insertObject:aPaperView atIndex:index];
    }
    
    Sighting* selectedSighting = [_sightings objectAtIndex:index];
    NSString* sightedString = [self.df stringFromDate:selectedSighting.sightedAt];
    NSString* reportedString = [self.df stringFromDate:selectedSighting.reportedAt];
    NSString* durationString = selectedSighting.duration;
    NSString* reportString = selectedSighting.report;
    
    
    
    
    [aPaperView randomize];
    [aPaperView.sightedLabel setText:sightedString];    
    [aPaperView.ReportedLabel setText:reportedString];
    [aPaperView.durationLabel setText:durationString];
    [aPaperView.reportTextView setText:reportString];
    
    
    return aPaperView;
}



#pragma mark - Scroll View Functions

/*
 This function is a modified function from an Apple example named : ScrollViewWithPaging
 The purpose of this funtion is to supply the Page-enabled ScrollView with new viewcontrollers
 */
- (void)loadScrollViewWithPage:(int)page
{   
    /* if the page being requested is out of bounds, leave the function */
    if (page < 0 || page > [_sightings count] )
        return;
    
    
    
    /* We will take our lazily loaded controllers, test for null and init
     new Book View controllers to supply to the ScrollView */
    
    PaperView* paperView = [self paperViewForIndex:page];
    
    if(!paperView.superview && paperView.superview != self.scrollView)
        [paperView removeFromSuperview];
    
    /* Add the controller's view to the scroll view */
    if (paperView.superview == nil)
    {   
        CGRect frame = self.scrollView.bounds;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        paperView.frame = frame;
        [self.scrollView addSubview:paperView];
    }
    
}


/*
 This function is a modified function from an Apple example named : ScrollViewWithPaging
 This scrollView delegate function determines which page the the scrollView is on
 and loads the viewcontrollers to the left and right to make the user expierience seamless.
 The example function did not include the section where pages are being nulled out. 
 This was done for memory savings and to allow infinite pages without slow down.
 */
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    
    
    if (sender == self.tableView) 
        return;
    
    NSUInteger page = [self currentPage];
    
    /* load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling) */
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    /* update our sliderControl */
    [sliderPageControl setCurrentPage:page animated:YES];
    
    // Apple : A possible optimization would be to unload the views+controllers which are no longer visible
    /* Me    : We Shall */
    for (NSUInteger i = 0; i < [_sightings count]; i++)
    {
        /* ignore the pages currently surrounding the page in view */
        if( i == page - 1 || i == page || i == page + 1)
            continue;
        
    
        /* If this Book is not null, then it will become null */
        PaperView *paperView = [_pages objectAtIndex:i];
        
        if ((NSNull*)paperView != [NSNull null]) 
        {
            /* if the book is a subview of another view then remove it */
            if (paperView.superview != nil ) 
            {
                [paperView removeFromSuperview];
            }
            
            [_pages replaceObjectAtIndex:i withObject:[NSNull null]];
        }  
        
    }
    
}

-(NSUInteger)currentPage
{
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth);
    return page;
}

-(void)resizeScrollView
{
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * [_sightings count], self.scrollView.frame.size.height);
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	pageControlUsed = NO;
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	pageControlUsed = NO;
}



#pragma mark - SliderPageControl Functions

-(void)setupSlider
{
    self.sliderPageControl = [[SliderPageControl  alloc] init];
    [self.sliderPageControl addTarget:self action:@selector(onPageChanged:) forControlEvents:UIControlEventValueChanged];
    [self.sliderPageControl setDelegate:self];
    [self.sliderPageControl setShowsHint:YES];
    [self.view addSubview:self.sliderPageControl];
    
    [self.sliderPageControl setNumberOfPages:[_sightings count]];
    
    
}


/* Returns the Title for the OverlayView when Choosing by SlideControl */
- (NSString *)sliderPageController:(id)controller hintTitleForPage:(NSInteger)page
{    
    Sighting *currentSighting = [_sightings objectAtIndex:page];
    return [self.df stringFromDate:currentSighting.sightedAt];
}


- (void)onPageChanged:(id)sender
{
	pageControlUsed = YES;
	[self slideToCurrentPage:YES];	
}


- (void)slideToCurrentPage:(bool)animated 
{
	int page = sliderPageControl.currentPage;
	
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:animated]; 
}


- (void)changeToPage:(int)page animated:(BOOL)animated
{
    [self loadScrollViewWithPage:page];
	[sliderPageControl setCurrentPage:page animated:YES];
	[self slideToCurrentPage:animated];
}









@end
