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
- (void)loadShapeButtons;
- (NSPredicate*)createPredicate;
@end

@implementation ShapeSelectorViewController
@synthesize scrollView = _scrollView;
@synthesize shapes = _shapes;
@synthesize predicateKey;
@synthesize filterDict;


- (id)init
{
    if ((self = [super self]))
    {
        self.predicateKey = @"shape";
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.shapes =  [self.filterDict objectForKey:@"shapes"];
}


- (void)viewDidUnload
{
    [self setScrollView:nil];
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
  
    if(self.navigationController)
    {
        CGRect frame = self.navigationController.view.frame;
        frame.size.height = _scrollView.contentSize.height;
        [UIView animateWithDuration:0.5 animations:^{
            self.navigationController.view.frame = frame;
        }];
    }
}


- (void)saveState
{
    NSMutableArray* shapesToFilter = [[NSMutableArray alloc]init];
    
    for (UIButton* button in self.scrollView.subviews) {
        if(!button.isSelected)
            [shapesToFilter addObject:[_shapes objectAtIndex:button.tag]];
    }
    
    NSMutableArray* filterCells = [self.filterDict objectForKey:@"filterCells"];
    NSMutableDictionary* cell;
    for (NSMutableDictionary* cellDict in filterCells) 
    {
        if([(NSString*)[cellDict objectForKey:@"predicateKey"] compare:self.predicateKey] == 0)
        {
            cell = cellDict;
            break;
        }
    }
    
    
    bool filters = shapesToFilter.count > 0;
    [cell setObject:[NSNumber numberWithBool:filters] forKey:@"hasFilters"];
    
    if (filters) {
        NSDictionary* badShapeNamesDict = [self.filterDict objectForKey:@"badShapeMatching"];
        NSMutableString* subtitle = [[NSMutableString alloc]init];
        
        for (NSString* string in shapesToFilter) {
            [subtitle appendFormat:@"%@, ",string];
            
            if([badShapeNamesDict allKeysForObject:string].count > 0)
            {
                for (NSString* badShapeName in [badShapeNamesDict allKeysForObject:string]) {
                    [subtitle appendFormat:@"%@, ",badShapeName];
                }
            }
            
            
        }
        
        [subtitle deleteCharactersInRange:NSMakeRange(subtitle.length -2, 2)];
        [cell setObject:subtitle forKey:@"subtitle"];
    }
    
    [self.filterDict setObject:shapesToFilter forKey:@"shapesToFilter"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


- (void)shapeButtonTapped:(UIButton*)button
{
  
    [button setSelected:!button.isSelected];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FilterChoiceChanged" object:self];
}

- (void)setShapes:(NSArray *)shapes
{
    _shapes = shapes;
    [self loadShapeButtons];
}

- (void)loadShapeButtons
{
    
    NSArray* selectedShapes = [self.filterDict objectForKey:@"shapesToFilter"];
  //  CGRect buttonFrame = CGRectMake(0, 0, 80, 80);
    
    NSArray* subviews = [self.scrollView subviews];
    if (subviews.count > 0) {
        for (UIView* view in subviews) {
            [view removeFromSuperview];
        }
    }
    
    int rows = [_shapes count] / 3;
    if([_shapes count] % 3 != 0)
        rows++;
    
    
    _scrollView.contentSize = CGSizeMake(280, rows * 85);
    
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
       NSString* shapeString = (NSString* )obj;
        [shapeButton setSelected:![selectedShapes containsObject:shapeString]];
        //*************************************************************************
        
        [shapeButton addTarget:self action:@selector(shapeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [shapeButton setTag:idx];
        
        
        
        [shapeButton setShape:shapeString];
        
        for (UIGestureRecognizer* gest in shapeButton.gestureRecognizers) {
            [gest requireGestureRecognizerToFail:[self.scrollView.gestureRecognizers lastObject]];
        } 
        [self.scrollView addSubview:shapeButton];
        
        column++;
    

    } ];
    
    [self.view setNeedsLayout];
    
    
    
    
}


- (BOOL)canReset
{
    BOOL hasChosenShapes = NO;
    for (UIButton* shapeButton in _scrollView.subviews) {
        if (!shapeButton.isSelected)
        {
            hasChosenShapes = YES;
            break;
        }
    }
    return hasChosenShapes;
}


- (void)reset
{
    for (UIButton* shapeButton in _scrollView.subviews) {
        [shapeButton setSelected:YES];
    }
}



- (NSPredicate*)createPredicate
{
    
    NSMutableArray* selectedButtonPredicates = [[NSMutableArray alloc]initWithCapacity:_shapes.count];
    
    for (UIView* view in _scrollView.subviews) {
        if([view isKindOfClass:[ShapeButton class]] && ![(ShapeButton*)view isSelected])
        {
            NSPredicate* predicate = nil;
            if(view.tag == 3)
            {
                predicate = [NSPredicate predicateWithFormat:@"shape != \"circle\" AND shape != \"sphere\" AND shape != \"round\" AND shape != \"dome\""];
            }
            else if(view.tag == 11)
            {
                predicate = [NSPredicate predicateWithFormat:@"shape != \"flash\" AND shape != \"light\""];
            }
            else if (view.tag == 12) {
                predicate = [NSPredicate predicateWithFormat:@"shape != \"formation\" AND shape != \"hexagon\" "];
            }
            else if (view.tag == 14) {
                predicate = [NSPredicate predicateWithFormat:@"shape != \"unspecified\" AND shape != \"other\" AND shape != \"unknown\" AND shape != \"cresent\""];
            }
            else if (view.tag == 17) {
                predicate = [NSPredicate predicateWithFormat:@"shape != \"triangle\" AND shape != \"other\" AND shape != \"pyramid\""];
            }
            else {
                predicate = [NSPredicate predicateWithFormat:@"shape != %@", [NSString stringWithFormat:@"%@",[_shapes objectAtIndex:view.tag]]];
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
