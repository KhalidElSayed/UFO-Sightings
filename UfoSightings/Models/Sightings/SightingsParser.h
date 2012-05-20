//
//  SightingsParser.h
//  UfoSightings
//
//  Created by Richard Kirk on 5/19/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface SightingsParser : NSObject
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

-(void)createDatabase;


- (NSURL *)applicationDocumentsDirectory;
@end
