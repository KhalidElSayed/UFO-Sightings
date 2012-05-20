//
//  FilterViewController.h
//  UfoSightings
//
//  Created by Richard Kirk on 5/15/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterViewController : UITableViewController <UINavigationControllerDelegate>

@property(assign, nonatomic)id delegate;

-(NSCompoundPredicate*)predicate;
-(void)storePredicate:(NSPredicate*)predicate forKey:(NSString*)key;
@end


@protocol FilterControllerDelegate <NSObject>
-(void)filterViewController:(FilterViewController*)fvc didUpdatePredicate:(NSPredicate*)predicate;

@end

@protocol PredicateCreation <NSObject>

@required
@property (strong, nonatomic)NSString* predicateKey;
-(NSPredicate*)createPredicate;

@end
