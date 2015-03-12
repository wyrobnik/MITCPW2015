//
//  EventsQueryConstraints.m
//  townbilly
//
//  Created by David Wyrobnik on 12/25/14.
//  Copyright (c) 2014 townbilly. All rights reserved.
//

#import "EventsQueryConstraints.h"

#define DICTIONARY_ENTRIES 4
#define START_TIME @"start_time"
#define END_TIME @"end_time"
#define CATEGORIES @"categories"

#define DISTANCE_FROM_LOCATION @"distance_from_location"
#define LONGITUDE @"longitude"
#define LATITUDE @"latiude"
#define DISTANCE_KM @"distance_km"

@implementation EventsQueryConstraints


+(NSArray*)filterTags {
    static NSArray *output;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        output = @[@"Free",
                   @"Outdoors & Public Events",
                   @"Live Shows",
                   @"Exhibits/Educational",
                   @"Foody",
                   @"Bars",
                   @"Clubs & Concerts"];
    });
    return output;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self resetConstraints];
    }
    return self;
}

-(void)resetConstraints {
    self.startTime = nil;
    self.endTime = nil;
    self.categories = [[NSMutableArray alloc] initWithCapacity:[[EventsQueryConstraints filterTags] count]];
    struct DistanceFromLocationStruct newStruct;
    newStruct.distance_km = 0.00f;
    self.distanceFromLocation = newStruct;
    
}

-(NSDictionary*)eventConstraintDictionary {
    
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    NSMutableDictionary *outputDictionary = [[NSMutableDictionary alloc] initWithCapacity:DICTIONARY_ENTRIES];
    
    if (self.startTime)
        [outputDictionary setObject:[NSString stringWithFormat:@"%@", [dateFormater stringFromDate:self.startTime]]
                             forKey:START_TIME];
    if (self.endTime)
        [outputDictionary setObject:[NSString stringWithFormat:@"%@", [dateFormater stringFromDate:self.endTime]]
                             forKey:END_TIME];
    if ([self.categories count] > 0)
        [outputDictionary setObject:[NSString stringWithFormat:@"%@", [self.categories componentsJoinedByString:@","]]
                             forKey:CATEGORIES];
    if (self.distanceFromLocation.distance_km > 0.00f)
        [outputDictionary setObject:@{
                                      LONGITUDE : [NSNumber numberWithDouble:self.distanceFromLocation.location.x],
                                      LATITUDE :  [NSNumber numberWithDouble:self.distanceFromLocation.location.y],
                                      DISTANCE_KM : [NSNumber numberWithDouble:self.distanceFromLocation.distance_km]
                                      }
                             forKey:DISTANCE_FROM_LOCATION];

        
    return outputDictionary;
}



@end
