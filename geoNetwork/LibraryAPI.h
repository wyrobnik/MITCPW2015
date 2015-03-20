//
//  LibraryAPI.h
//  townbilly
//
//  Created by David Wyrobnik on 11/22/14.
//  Copyright (c) 2014 townbilly. All rights reserved.
//

//  Fascade Pattern. Use this library to hide away many API objects (such as ServerFetcher)
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Event.h"
#import "EventsQueryConstraints.h"

typedef enum {Discovery, Bookmarked} EventsDiscoveryBookmarkedFollowed;

@interface LibraryAPI : NSObject<CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) NSDate *rangeStartDate;
@property (strong, nonatomic) NSDate *rangeEndDate;

@property (nonatomic) EventsDiscoveryBookmarkedFollowed eventClass;

//Event (depends on eventClass selected)
@property (strong, nonatomic, readonly) NSArray* events;

@property (strong, nonatomic, readonly) NSMutableDictionary* eventSections;
@property (strong, nonatomic, readonly) NSArray *sortedEventSections;

@property (strong, nonatomic) EventsQueryConstraints* eventsQueryConstraints;

//Bookmarked Events (stored on device)
@property (strong, nonatomic, readonly) NSMutableDictionary* bookmarkedEvents;  //jsonEvents

-(void)reloadEventsWithErrorHandler:(id)target selector:(SEL)selector;  //Reload the events. If error, calls selector

-(void)addBookmarkedEventsObject:(Event *)event;
-(void)removeBookmarkedEventsObject:(Event *)event;

+(LibraryAPI*)sharedInstance;


//Convert Enum to string
+(NSString *)convertToString:(EventsDiscoveryBookmarkedFollowed)eventClass;
-(void)setEventClass:(EventsDiscoveryBookmarkedFollowed)eventClass withErrorHandler:(id)target selector:(SEL)selector;




@end
