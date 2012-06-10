//
//  SightingAnnotation.m
//  UfoSightings
//
//  Created by Richard Kirk on 6/6/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import "SightingAnnotation.h"

@implementation SightingAnnotation
@synthesize coordinate, title;
@synthesize containedAnnotations;

-(NSString*)title
{
    return @" ";
}

-(NSString*)buildTitle
{
    if(!containedAnnotations)
    {

    }
    
    return @"";
    
}




@end
