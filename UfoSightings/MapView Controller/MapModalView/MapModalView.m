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
#import "UIColor+RKColor.h"
#import "ConsoleDocumentView.h"
#import <QuartzCore/QuartzCore.h>

@interface MapModalView ()
{
    NSMutableArray* _documents;
    bool pageControlUsed;
    NSDateFormatter* _df;

}
@property (strong, nonatomic)NSArray* _sightings;
@property (strong, nonatomic)NSTimer* loadingTimer;
- (void)setupSlider;
- (void)setupForPortrait;
- (void)setupForLandscape;
- (void)refreshLocation;
- (void)showLoadingView;
- (void)hideLoadingView;
- (void)updateLoadingLabel;
@end

@implementation MapModalView
@synthesize headerLabel = _headerLabel;
@synthesize loadingView = _loadingView;
@synthesize loadingLabel = _loadingLabel;
@synthesize tableView = _tableView, scrollView = _scrollView;
@synthesize location = _location;
@synthesize _sightings;
@synthesize predicate = _predicate;
@synthesize loadingTimer;



#pragma mark - UIViewController Functions
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (id)initWithSightingLocation:(SightingLocation*)location andPredicate:(NSPredicate*)pred
{
    if ((self = [super init]))
    {   
        _predicate = pred;
        [self setLocation:location];
        _df = [[NSDateFormatter alloc]init];
        [_df setDateStyle:NSDateFormatterMediumStyle];
        _sightings = [[NSArray alloc]init];
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    _scrollView.scrollEnabled = NO;

    [self.tableView registerNib:[UINib nibWithNibName:@"MapModalCell" bundle:[NSBundle mainBundle]]  forCellReuseIdentifier:@"modalCell"];
    self.loadingLabel.font = [UIFont fontWithName:@"AndaleMono" size:30.0f];
    self.loadingView.layer.cornerRadius = 5.0f;

    
    [self refreshLocation];
    

}


- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setScrollView:nil];
    _documents = nil;
    [self setHeaderLabel:nil];
    [self setLoadingView:nil];
    [self setLoadingLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    int curretPage = [self currentPage];
    
    if(self.loadingView.superview != nil)
    {
        self.loadingView.center = [self.view.superview convertPoint:self.view.superview.center toView:self.view];
    }

    
    void (^finishedBlock)() = ^{
        [self resizeScrollView];    
        for (ConsoleDocumentView* document in _documents) 
        {
            if((NSNull*)document != [NSNull null])
            {
                NSUInteger page = [_documents indexOfObject:document];
                
                CGRect frame = self.scrollView.bounds;
                frame.origin.x = frame.size.width * page;
                frame.origin.y = 0;
                document.frame = frame;
                
            }
        }
        [self changeToPage:curretPage animated:NO];
        _sliderPageControl.maskRect = _scrollView.frame;
    };
    
    
    UIDeviceOrientation deviceOrientation = [[UIApplication sharedApplication]statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(deviceOrientation )) {
        
     //   [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
            [self.tableView setFrame:CGRectMake(60, 60, 320, 560)];
            [_scrollView setFrame:CGRectMake(280, 40, 552, 560)];
            [_sliderPageControl setAlpha:0.0f];
                self.headerLabel.alpha = 1.0f;
        // } completion:^(BOOL finished){
         //   if (finished) {
                finishedBlock();
     //       }
      //  }];
        
    }
    else {
        
        //[UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
            [self.tableView setFrame:CGRectMake(-321, 40, 320, 623)];
            [_scrollView setFrame:CGRectMake(40, 60, 600, 850)];
            [_sliderPageControl setAlpha:1.0f];
        self.headerLabel.alpha = 0.0f;
       // } completion:^(BOOL finished){
         //   if (finished) {
                finishedBlock();
           // }
       // }];
        
    }
    
    
}



- (void)setupForLandscape
{
    [self.scrollView setFrame:CGRectZero];
    [_sliderPageControl setFrame:CGRectZero];
}

- (void)setupForPortrait
{
    
    
    
    [self.scrollView setFrame:CGRectMake(36, 75, 495, 711)];
    [_sliderPageControl setFrame:CGRectMake(36, 794, 495, 20)];
    [self resizeScrollView];
    
  //  [self changeToPage:_currentSelectionIndex + 1 animated:NO];
 
    
    [self.tableView setFrame:CGRectZero];
    
}


#pragma mark - Custom setters

- (void)refreshLocation
{

    [self showLoadingView];
  //  NSManagedObjectContext* threadContext = [[_location managedObjectContext] concurrencyType]
    
    NSPersistentStoreCoordinator* persistentStore = [[_location managedObjectContext] persistentStoreCoordinator];
    NSManagedObjectContext* threadContext = [[NSManagedObjectContext alloc]init];
    [threadContext setPersistentStoreCoordinator:persistentStore];
    
    

    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableSet *fillerSet = [[NSMutableSet alloc]init];
        
        [fillerSet unionSet:[_location sighting]];
        
        for (SightingLocation* containedLocation in [_location containedAnnotations]) {
            [fillerSet unionSet:[containedLocation sighting]];
        }
        

        NSArray* sortedSightings = [[fillerSet allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
            Sighting* a = (Sighting*)obj1;
            Sighting* b = (Sighting*)obj2;
            return [a.sightedAt compare:b.sightedAt];
        }];
        _documents = [[NSMutableArray alloc] init];
        for (unsigned i = 0; i < [sortedSightings count]; i++)
            [_documents addObject:[NSNull null]];
        

        dispatch_sync(dispatch_get_main_queue(), ^{
            [self hideLoadingView];
            _sightings = sortedSightings;
                [self resizeScrollView];
            [_tableView reloadData];
            [self setupSlider];
            _scrollView.scrollEnabled = YES;
            [self changeToPage:0 animated:YES];
            [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
            
        });
    });

}


#pragma mark - UITableViewDataSource 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_sightings count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* modalCellIdentifier = @"modalCell";
    
    Sighting* aSighting = [_sightings objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:modalCellIdentifier];
    NSString *theName = [NSString stringWithFormat:@"%i.  %@", indexPath.row + 1, [_df stringFromDate:aSighting.sightedAt]];
    
    [[(MapModalCell *)cell label] setText:theName];
    return cell;
    
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self changeToPage:indexPath.row animated:YES];
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc]initWithFrame:CGRectMake(0, 0, 321, 1)];
}
    /*
    UIView* header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 214, 40)];
    header.backgroundColor = [UIColor clearColor];
    header.opaque = YES;
    
    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 214, 30)];
    [label setFont:[UIFont fontWithName:@"Courier-Bold" size:15.0f]];
    [label setTextColor:[UIColor whiteColor]];
    [label setAdjustsFontSizeToFitWidth:YES];
    [label setMinimumFontSize:10.0f];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setText:@"SELECT SIGHTING"];
    
    
    [header addSubview:label];
    
    UIImageView* imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 30, 166, 10)];
    [imgView setImage:[UIImage imageNamed:@"line.png"]];
    
    [header addSubview:imgView];
    
    return header;
    
}
*/


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}


#pragma mark - IBActions
- (IBAction)exitSelected:(id)sender 
{
    

        if(self.parentViewController)
    [self.parentViewController performSelector:@selector(modalWantsToDismiss)];
    
}

#pragma mark - Scroll View Functions

/*
 This function is a modified function from an Apple example named : ScrollViewWithPaging
 The purpose of this funtion is to supply the Page-enabled ScrollView with new viewcontrollers
 */
- (void)loadScrollViewWithPage:(int)page
{   
    /* if the page being requested is out of bounds, leave the function */
    if (page < 0 || page >= [_sightings count] )
        return;
    
    
    ConsoleDocumentView* document = [_documents objectAtIndex:page];
    if((NSNull*)document == [NSNull null])
    {
        document = [[ConsoleDocumentView alloc]initWithSighting:[_sightings objectAtIndex:page]];
       
        [_documents insertObject:document atIndex:page];
    
    }
  
    if (document.superview == nil)
    {   

        CGRect frame = self.scrollView.bounds;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        document.frame = frame;
        document.scrollView.contentOffset = CGPointZero;
        [self.scrollView addSubview:document];
      
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
   // NSLog(@"%i",page);
    /* load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling) */
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    /* update our sliderControl */
    [_sliderPageControl setCurrentPage:page animated:YES];
    if(sender.isDragging)
    {
        [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:page inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:page inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    }
        
        
    // Apple : A possible optimization would be to unload the views+controllers which are no longer visible
    /* Me    : We Shall */
  
    for (NSUInteger i = 0; i < [_sightings count]; i++)
    {
        // ignore the pages currently surrounding the page in view 
        if( i == page - 1 || i == page || i == page + 1)
            continue;
        
    
        // If this Book is not null, then it will become null 
        ConsoleDocumentView *document = [_documents objectAtIndex:i];
        
        if ((NSNull*)document != [NSNull null]) 
        {
            // if the book is a subview of another view then remove it 
            if (document.superview != nil ) 
            {
                [document removeFromSuperview];
             //   NSLog(@"removing doc = %i",i);
            }
            
            [_documents replaceObjectAtIndex:i withObject:[NSNull null]];
        }  
        
    }
    
}

- (NSUInteger)currentPage
{
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;

    return MAX(page, 0);
}

- (void)resizeScrollView
{
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * [_sightings count], 1);
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

- (void)setupSlider
{
    _sliderPageControl = [[SliderPageControl  alloc] initWithFrame:CGRectMake(40, 870, 600, 40)];
    [_sliderPageControl addTarget:self action:@selector(onPageChanged:) forControlEvents:UIControlEventValueChanged];
    [_sliderPageControl setDelegate:self];
    [_sliderPageControl setShowsHint:YES];
    [self.view addSubview:_sliderPageControl];
    
    [_sliderPageControl setNumberOfPages:[_sightings count]];
    
    
}


/* Returns the Title for the OverlayView when Choosing by SlideControl */
- (NSString *)sliderPageController:(id)controller hintTitleForPage:(NSInteger)page
{    
    Sighting *currentSighting = [_sightings objectAtIndex:page];
    return [_df stringFromDate:currentSighting.sightedAt];
}


- (void)onPageChanged:(id)sender
{
	pageControlUsed = YES;
	[self changeToPage:[self currentPage] animated:YES];	
}


- (void)slideToCurrentPage:(bool)animated 
{
	int page = _sliderPageControl.currentPage;
	
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:animated]; 
}


- (void)changeToPage:(int)page animated:(BOOL)animated
{
    [self loadScrollViewWithPage:page];
	[_sliderPageControl setCurrentPage:page animated:YES];
   
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:animated]; 

}


- (void)showLoadingView
{
    [self.view addSubview:self.loadingView];
    
    self.loadingTimer = [NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(updateLoadingLabel) userInfo:nil repeats:YES];

}


- (void)updateLoadingLabel
{
    NSString* loadingText = self.loadingLabel.text;
    if(loadingText.length < 12)
        loadingText = [loadingText stringByAppendingString:@"."];
    else 
        loadingText = @"LOADING";
    
    self.loadingLabel.text = loadingText;
    
}


- (void)hideLoadingView
{
    
    [self.loadingView removeFromSuperview];
    [self.loadingTimer invalidate];
   
    
}








@end
