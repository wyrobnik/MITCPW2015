//
//  Event.h
//  townbilly
//
//  Created by David Wyrobnik on 11/23/14.
//  Copyright (c) 2014 townbilly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Event : NSObject

-(instancetype)initWithJSONEvent:(NSDictionary*)jsonEvent;

@property (strong, nonatomic, readonly) NSDictionary* jsonEvent;

#pragma mark - Event
@property (strong, nonatomic, readonly) NSString *event_id;
@property (strong, nonatomic, readonly) NSString *title;
@property (strong, nonatomic, readonly) NSString *description_event;
@property (strong, nonatomic, readonly) NSURL *icon_url;
@property (strong, nonatomic, readonly) NSDate *startTime;
@property (strong, nonatomic, readonly) NSDate *endTime;

@property (strong, nonatomic, readonly) NSArray *filters;
@property (nonatomic, readonly) BOOL free;

#pragma mark - Business
@property (strong, nonatomic, readonly) NSString *business_id;
@property (strong, nonatomic, readonly) NSString *business_name;
@property (strong, nonatomic, readonly) NSString *phoneNumber;
@property (strong, nonatomic, readonly) NSURL *website_url;

#pragma mark - Location
@property (nonatomic, readonly) double longitude;
@property (nonatomic, readonly) double latitude;
@property (strong, nonatomic, readonly) NSString *venue;
@property (strong, nonatomic, readonly) NSString *street_address;
@property (strong, nonatomic, readonly) NSString *city;
@property (strong, nonatomic, readonly) NSString *state;
@property (strong, nonatomic, readonly) NSString *zip;

@end