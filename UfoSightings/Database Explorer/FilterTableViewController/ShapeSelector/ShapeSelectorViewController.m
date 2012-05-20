//
//  ShapeSelectorViewController.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/16/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import "ShapeSelectorViewController.h"
#import "ShapeButton.h"


@interface ShapeSelectorViewController ()
-(void)loadShapeButtons;
-(NSPredicate*)createPredicate;
@end

@implementation ShapeSelectorViewController
@synthesize scrollView = _scrollView;
@synthesize shapes = _shapes;
@synthesize predicateKey;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
  [self.navigationController setNavigationBarHidden:NO];
    self.shapes =  [NSArray arrayWithObjects:@"changing", @"chevron", @"cigar", @"circle", @"cone", @"cross", @"cylinder", @"diamond", @"disk", @"egg", @"fireball", @"flash", @"formation", @"oval", @"other", @"rectangle", @"teardrop", @"triangle", nil];


}



-(void)viewWillDisappear:(BOOL)animated
{    
    NSPredicate* predicate = [self createPredicate];
    if (predicate) {
       
        FilterViewController *fvc = [self.navigationController.viewControllers objectAtIndex:0];
        [fvc storePredicate:predicate forKey:self.predicateKey];
        
    }
    
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


-(void)shapeButtonTapped:(UIButton*)button
{
  
    
    [button setSelected:!button.isSelected];
    
}

-(void)setShapes:(NSArray *)shapes
{
    _shapes = shapes;
    [self loadShapeButtons];
}

-(void)loadShapeButtons
{
    
    
  //  CGRect buttonFrame = CGRectMake(0, 0, 80, 80);
    
    NSArray* subviews = [self.scrollView subviews];
    if (subviews) {
        for (UIView* view in subviews) {
            [view removeFromSuperview];
        }
    }
    
    _scrollView.contentSize = CGSizeMake(280, (([_shapes count] / 3) * 100) + 100 );
    
    __block CGFloat padding = 0;
    __block int row = -1;
    __block int column = 0;
    [self.shapes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        
        if (idx  % 3 == 0) {
            padding = 0;
            row++;
            column = 0;
        }
        
        padding += 10.0f;
        
        CGRect buttonFrame = CGRectMake(padding + column * 80, row * 80.0f + 20.0f, 80, 80);        
        ShapeButton *shapeButton = [[ShapeButton alloc]initWithFrame:buttonFrame];
        //*************************************************************************
        [shapeButton setSelected:YES];
        //*************************************************************************
        
        [shapeButton addTarget:self action:@selector(shapeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [shapeButton setTag:idx];
        
        NSString* shapeString = (NSString* )obj;
        
        [shapeButton setShape:shapeString];
        
        for (UIGestureRecognizer* gest in shapeButton.gestureRecognizers) {
            [gest requireGestureRecognizerToFail:[self.scrollView.gestureRecognizers lastObject]];
        } 
        [self.scrollView addSubview:shapeButton];
        
        column++;
    

    } ];
    
    [self.view setNeedsLayout];
    
    
    
    
}



-(NSPredicate*)createPredicate
{
    
    NSMutableArray* selectedButtonPredicates = [[NSMutableArray alloc]initWithCapacity:_shapes.count];
    
    for (UIView* view in _scrollView.subviews) {
        if([view isKindOfClass:[ShapeButton class]] && ![(ShapeButton*)view isSelected])
        {
            NSPredicate* predicate = nil;
            if(view.tag == 3)
            {
                predicate = [NSPredicate predicateWithFormat:@"shape != \" circle\" AND shape != \" sphere\" AND shape != \"round\""];
            }
            else if(view.tag == 11)
            {
                predicate = [NSPredicate predicateWithFormat:@"shape != \" flash\" AND shape != \" light\""];
            }
            else if (view.tag == 14) {
                predicate = [NSPredicate predicateWithFormat:@"shape != \" unspecified\" AND shape != \" other\" AND shape != \"unknown \""];
            }
            else {
                predicate = [NSPredicate predicateWithFormat:@"shape != %@", [NSString stringWithFormat:@" %@",[_shapes objectAtIndex:view.tag]]];
            }
            [selectedButtonPredicates addObject:predicate];
            
        }
    }
        
    if (selectedButtonPredicates.count > 0) {
        return [[NSCompoundPredicate alloc]initWithType:NSAndPredicateType subpredicates:selectedButtonPredicates];
    }
    
    return  nil;
    
}




@end
