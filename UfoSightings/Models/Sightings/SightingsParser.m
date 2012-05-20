//
//  SightingsParser.m
//  UfoSightings
//
//  Created by Richard Kirk on 5/19/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import "SightingsParser.h"
#import "Sighting.h"
#import "AppDelegate.h"
#import "NSString+HTML.h"


@implementation SightingsParser
@synthesize managedObjectContext;



-(void)createDatabase
{
    
    
    NSURL* FileURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ufo.json" isDirectory:NO];
    
    
    NSData* JSONData = [NSData dataWithContentsOfURL:FileURL];
    NSDictionary* JSONObject = [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:nil];
    
    NSArray* reports = [JSONObject objectForKey:@"reports"];
    
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyyMMdd"];
    
    
    
    NSMutableString* report = [[NSMutableString alloc]init];
    NSUInteger i = 1;
    for (NSDictionary* sighting in reports)
    {
        [report appendFormat:@"%d: ", i];
        
        Sighting*           newSighting = [NSEntityDescription insertNewObjectForEntityForName:@"Sighting" 
                                                                        inManagedObjectContext:self.managedObjectContext];
        [newSighting setSightingId:[NSNumber numberWithUnsignedInteger:i]];
        [newSighting setReport:[[sighting objectForKey:@"description"] kv_decodeHTMLCharacterEntities]];
        [newSighting setReportLength:[NSNumber numberWithUnsignedInteger:[[sighting objectForKey:@"description"] length]]];
        [newSighting setDuration:[[sighting objectForKey:@"duration"] kv_decodeHTMLCharacterEntities]];
        
        NSString* shapeString = [[sighting objectForKey:@"shape"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if(shapeString)
            [newSighting setShape:shapeString];
        else
        {
            [report appendFormat:@"nilShape"];
            [newSighting setShape:@""];
        }
        
        id reportedAt = [sighting objectForKey:@"reported_at"];
        NSDate* reportedDate = [df dateFromString:(NSString*)reportedAt];
        id sightedAt = [sighting objectForKey:@"sighted_at"];
        NSDate* sightedDate = [df dateFromString:(NSString*)sightedAt];
        
        
        if(sightedDate == nil && reportedDate != nil){
            newSighting.reportedAt = [df dateFromString:(NSString*)reportedAt];
            newSighting.sightedAt = [df dateFromString:(NSString*)reportedAt];
            NSLog(@"s:%@",(NSString*)sightedAt);
        }        
        else if (reportedDate == nil && sightedDate != nil) {
            [newSighting setSightedAt:[df dateFromString:(NSString*)sightedAt]];
            [newSighting setReportedAt:[df dateFromString:(NSString*)sightedAt]];
            NSLog(@"r:%@", (NSString*)reportedAt);
        }
        else if (reportedDate == nil && sightedDate == nil) {
            NSLog(@"r:%@s:%@", (NSString*)reportedAt, (NSString*)sightedAt);
        }
        
        
        [newSighting setReportedAt:reportedDate];
        
        [report appendFormat:@"RD:%@ ", reportedDate];
        
        
        
        
        [newSighting setSightedAt:sightedDate];
        [report appendFormat:@"SD:%@",sightedDate];
        
        
        
        if (!newSighting.sightedAt && newSighting.reportedAt) {
            newSighting.sightedAt = newSighting.reportedAt;
        }
        else if (newSighting.sightedAt && !newSighting.reportedAt) {
            newSighting.reportedAt = newSighting.sightedAt;
        }
        else if (!newSighting.sightedAt && !newSighting.reportedAt) {
            NSLog(@"%@",[NSString stringWithFormat:@"r:%@,s:%@",[sighting objectForKey:@"reported_at"], [sighting objectForKey:@"sighted_at"]]);
        }
        
        
        SightingLocation *newSightingLocation;
        NSNumber* sightingLat = [sighting objectForKey:@"lat"];
        NSNumber* sightingLng = [sighting objectForKey:@"lng"];
        NSString* sightingAddress = [sighting objectForKey:@"formatted_address"];
        
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"SightingLocation" inManagedObjectContext:self.managedObjectContext];
        [request setEntity:entity];
        
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.lat == %@ AND self.lng == %@ AND self.formattedAddress == %@", sightingLat, sightingLng , sightingAddress];
        [request setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        if (error) {
            [report appendString:[error description]];
        }
        
        
        if ([array count] != 0) {
            [report appendFormat:@"dupLoc "];
            newSightingLocation = [array lastObject];
            
        }
        else {
            [report appendFormat:@"newLoc "];
            newSightingLocation = [NSEntityDescription insertNewObjectForEntityForName:@"SightingLocation" inManagedObjectContext:self.managedObjectContext];
            newSightingLocation.lat = sightingLat;
            newSightingLocation.lng = sightingLng;
            newSightingLocation.formattedAddress = sightingAddress;
        }
        
        newSighting.location = newSightingLocation;
        i++;
    }
    
    // NSLog(@"%@",report);
    NSError* error = nil;
    [self.managedObjectContext save:&error];
    
    if(error)
        NSLog(@"%@",error);
    
    
}


// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
