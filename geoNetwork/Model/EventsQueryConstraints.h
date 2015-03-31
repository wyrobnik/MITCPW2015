//
//  EventsQueryConstraints.h
//  townbilly
//
//  Created by David Wyrobnik on 12/25/14.
//  Copyright (c) 2014 townbilly. All rights reserved.
//

#import <Foundation/Foundation.h>

struct DistanceFromLocationStruct {
    CGPoint location;
    CGFloat distance_km;
};

//#define CATEGORY_OPTIONS 3
//#define CATEGORY_ENTERTAINMENT @"Entertainment"
//#define CATEGORY_CULTURE @"Culture"
//#define CATEGORY_NIGHTLIFE @"Nightlife"
//#define FILTERS [NSArray arrayWithObjects:@"Free", @"Outdoors & Public Events", @"Live Shows", @"Exhibits/Educational", @"Foody",@"Bars",@"Clubs & Concerts", nil]

@interface EventsQueryConstraints : NSObject

@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) NSDate *endTime;
@property (strong, nonatomic) NSMutableArray *categories;
@property (nonatomic) struct DistanceFromLocationStruct distanceFromLocation;

+(NSArray*)filterTags;
+(void)setFilterTags:(NSArray*)filterTags;

-(NSDictionary*)eventConstraintDictionary;
-(NSDictionary*)eventConstraintDictionaryRightNow;

-(void)resetConstraints;

@end
