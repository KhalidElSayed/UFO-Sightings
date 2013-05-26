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
    bool pageControlUsed;
}
@property (strong, nonatomic) NSArray* sightings;
@property (strong, nonatomic) NSMutableArray* documents;
@property (strong, nonatomic) NSTimer* loadingTimer;
@property (strong, nonatomic) NSDateFormatter* df;
- (void)setupSlider;
- (void)setupForPortrait;
- (void)setupForLandscape;
- (void)refreshLocation;
- (void)showLoadingView;
- (void)hideLoadingView;
- (void)updateLoadingLabel;
@end

@implementation MapModalView

#pragma mark - UIViewController Functions


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
    self.scrollView.scrollEnabled = NO;

    [self.tableView registerNib:[UINib nibWithNibName:@"MapModalCell" bundle:[NSBundle bundleForClass:[self class]]]  forCellReuseIdentifier:@"modalCell"];
    self.loadingLabel.font = [UIFont fontWithName:@"AndaleMono" size:30.0f];
    self.loadingView.layer.cornerRadius = 5.0f;

    [self refreshLocation];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    int curretPage = [self currentPage];
    
    if(self.loadingView.superview != nil) {
        self.loadingView.center = [self.view.superview convertPoint:self.view.superview.center toView:self.view];
    }
    
    void (^finishedBlock)() = ^{
        [self resizeScrollView];    
        for (ConsoleDocumentView* document in self.documents) {
            
            if((NSNull*)document != [NSNull null]) {
                NSUInteger page = [self.documents indexOfObject:document];
                
                CGRect frame = self.scrollView.bounds;
                frame.origin.x = frame.size.width * page;
                frame.origin.y = 0;
                document.frame = frame;
            }
        }
        [self changeToPage:curretPage animated:NO];
        self.sliderPageControl.maskRect = self.scrollView.frame;
    };
    
    
    UIDeviceOrientation deviceOrientation = [[UIApplication sharedApplication]statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(deviceOrientation )) {
        
     //   [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
            [self.tableView setFrame:CGRectMake(60, 60, 320, 560)];
            [self.scrollView setFrame:CGRectMake(280, 40, 552, 560)];
            [self.sliderPageControl setAlpha:0.0f];
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
            [self.scrollView setFrame:CGRectMake(40, 60, 600, 850)];
            [self.sliderPageControl setAlpha:1.0f];
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
    [self.sliderPageControl setFrame:CGRectZero];
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
    
    NSPersistentStoreCoordinator* persistentStore = [[self.location managedObjectContext] persistentStoreCoordinator];
    NSManagedObjectContext* threadContext = [[NSManagedObjectContext alloc]init];
    [threadContext setPersistentStoreCoordinator:persistentStore];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableSet *fillerSet = [[NSMutableSet alloc]init];
        
        [fillerSet unionSet:[self.location sighting]];
        
        for (SightingLocation* containedLocation in [self.location containedAnnotations]) {
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
            self.sightings = sortedSightings;
            [self resizeScrollView];
            [self.tableView reloadData];
            [self setupSlider];
            self.scrollView.scrollEnabled = YES;
            [self changeToPage:0 animated:YES];
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
        });
    });

}


#pragma mark - UITableViewDataSource 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sightings count];
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


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}


#pragma mark - IBActions

- (IBAction)exitSelected:(id)sender
{
    if(self.parentViewController){
        [self.parentViewController performSelector:@selector(modalWantsToDismiss)];
    }
}


#pragma mark - Scroll View Functions

/*
 This function is a modified function from an Apple example named : ScrollViewWithPaging
 The purpose of this funtion is to supply the Page-enabled ScrollView with new viewcontrollers
 */
- (void)loadScrollViewWithPage:(int)page
{   
    /* if the page being requested is out of bounds, leave the function */
    if (page < 0 || page >= [self.sightings count] )
        return;
    
    ConsoleDocumentView* document = [self.documents objectAtIndex:page];
    if((NSNull*)document == [NSNull null]) {
        document = [[ConsoleDocumentView alloc]initWithSighting:[self.sightings objectAtIndex:page]];
        [self.documents insertObject:document atIndex:page];
    }
  
    if (document.superview == nil) {
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
    if (sender == self.tableView) {return;}
    
    NSUInteger page = [self currentPage];

    /* load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling) */
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    /* update our sliderControl */
    [self.sliderPageControl setCurrentPage:page animated:YES];
    if(sender.isDragging) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:page inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:page inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    
    for (NSUInteger i = 0; i < [_sightings count]; i++) {
        // ignore the pages currently surrounding the page in view 
        if( i == page - 1 || i == page || i == page + 1) {continue;}
        
        // If this Book is not null, then it will become null 
        ConsoleDocumentView *document = [_documents objectAtIndex:i];
        
        if ((NSNull*)document != [NSNull null]) {
            // if the book is a subview of another view then remove it 
            if (document.superview != nil ) {
                [document removeFromSuperview];
            }
            
            [self.documents replaceObjectAtIndex:i withObject:[NSNull null]];
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
    self.sliderPageControl = [[SliderPageControl  alloc] initWithFrame:CGRectMake(40, 870, 600, 40)];
    [self.sliderPageControl addTarget:self action:@selector(onPageChanged:) forControlEvents:UIControlEventValueChanged];
    [self.sliderPageControl setDelegate:self];
    [self.sliderPageControl setShowsHint:YES];
    [self.view addSubview:self.sliderPageControl];
    
    [self.sliderPageControl setNumberOfPages:[self.sightings count]];
}


/* Returns the Title for the OverlayView when Choosing by SlideControl */
- (NSString *)sliderPageController:(id)controller hintTitleForPage:(NSInteger)page
{    
    Sighting *currentSighting = [self.sightings objectAtIndex:page];
    return [self.df stringFromDate:currentSighting.sightedAt];
}


- (void)onPageChanged:(id)sender
{
	pageControlUsed = YES;
	[self changeToPage:[self currentPage] animated:YES];	
}


- (void)slideToCurrentPage:(bool)animated 
{
	int page = self.sliderPageControl.currentPage;
	
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:animated]; 
}


- (void)changeToPage:(int)page animated:(BOOL)animated
{
    [self loadScrollViewWithPage:page];
	[self.sliderPageControl setCurrentPage:page animated:YES];
   
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
    if(loadingText.length < 12){
        loadingText = [loadingText stringByAppendingString:@"."];
    } else {
        loadingText = @"LOADING";
    }
    self.loadingLabel.text = loadingText;
}


- (void)hideLoadingView
{
    [self.loadingView removeFromSuperview];
    [self.loadingTimer invalidate];
}

@end
