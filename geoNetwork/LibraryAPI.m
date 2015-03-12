//
//  LibraryAPI.m
//  townbilly
//
//  Created by David Wyrobnik on 11/22/14.
//  Copyright (c) 2014 townbilly. All rights reserved.
//

#import "LibraryAPI.h"
#import "ServerFetcher.h"

#define EVENTS_KEY @"events"
#define BOOKMARKED_EVENTS_KEY @"bookmarkedEvents"
#define STATUS_KEY @"status"

#define BUSINESSID_KEY @"business_id"

@interface LibraryAPI ()

@property (strong, nonatomic, readwrite) NSArray *events;

//For quick switch!
@property (strong, nonatomic) NSArray *discoverEventsArray;
@property (strong, nonatomic) NSArray *bookmarkedEventsArray;

@end

@implementation LibraryAPI {
    NSDictionary* categoryTranslateDictionary;  //Edit this to change the translation of short notation categories
}

+(LibraryAPI*)sharedInstance {
    static LibraryAPI *_obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _obj = [[LibraryAPI alloc] init];
    });
    return _obj;
}

+(NSString*)convertToString:(EventsDiscoveryBookmarkedFollowed)eventClass {
    NSString *result = nil;
        switch (eventClass) {
    case Discovery:
        result = @"Discover";
        break;
    case Bookmarked:
        result = @"Bookmarked";
        break;
    default:
        result = @"unknown";
        break;
    }
    return result;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _eventsQueryConstraints = [[EventsQueryConstraints alloc] init];
        _eventClass = Discovery;
    }
    return self;
}

# pragma mark - Bookmarked events logic

@synthesize bookmarkedEvents = _bookmarkedEvents;

-(NSMutableDictionary*)bookmarkedEvents {
    if (!_bookmarkedEvents) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:BOOKMARKED_EVENTS_KEY];
        if (data) {
            _bookmarkedEvents = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        } else {  // If no data
            _bookmarkedEvents = [[NSMutableDictionary alloc] init];
        }
    }
    return _bookmarkedEvents;
}

//Add event in sorted order (by startTime) in ascending order (first is oldest event) [Because ususally new events will be newer, less moving around of objects in array]
-(void)addBookmarkedEventsObject:(Event *)event {
    [self.bookmarkedEvents setObject:event.jsonEvent forKey:event.event_id];
    
    [self storeBookmarkedEventsPersistent];
    
}

-(void)removeBookmarkedEventsObject:(Event *)event {
    [self.bookmarkedEvents removeObjectForKey:event.event_id];
 
    [self storeBookmarkedEventsPersistent];
    
}

-(void)storeBookmarkedEventsPersistent {
    self.bookmarkedEventsArray = [self convertArrayElementsToEvents:[self.bookmarkedEvents allValues]];
    if (self.eventClass == Bookmarked)
        self.events = self.bookmarkedEventsArray;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //Archive data
    NSData *data = nil;
    if (self.bookmarkedEvents) {
        data = [NSKeyedArchiver archivedDataWithRootObject:self.bookmarkedEvents];
    }
    [userDefaults setObject:data forKey:BOOKMARKED_EVENTS_KEY];
    [userDefaults synchronize];
}


-(NSMutableArray*)extractArrayOfBusinessIds:(NSArray*)arrayOfJsonBusinesses {
    NSMutableArray *arrayOfBusinesses = [[NSMutableArray alloc] initWithCapacity:[arrayOfJsonBusinesses count]];
    for (NSUInteger i = 0; i < [arrayOfJsonBusinesses count]; i++) {
        id businessId = [[arrayOfJsonBusinesses objectAtIndex:i] valueForKey:BUSINESSID_KEY];
        [arrayOfBusinesses addObject:[NSString stringWithFormat:@"%@",businessId]]; //Make sure it is string
    }
    return arrayOfBusinesses;
}


-(NSArray*)convertArrayElementsToEvents:(NSArray*)arrayOfJsonEvents {
    NSMutableArray *arrayOfEvents = [[NSMutableArray alloc] initWithCapacity:[arrayOfJsonEvents count]];
    for (NSUInteger i = 0; i < [arrayOfJsonEvents count]; i++) {
        [arrayOfEvents addObject:[[Event alloc] initWithJSONEvent:[arrayOfJsonEvents objectAtIndex:i]]];
    }
    return arrayOfEvents;
}


/*
 * Reload events data (with set parameters)
 */
-(void)reloadEventsWithErrorHandler:(id)target selector:(SEL)selector {
    void (^discoverCallback)(NSData *data, NSURLResponse *response, NSError *error) =
        ^void(NSData *data, NSURLResponse *response, NSError *error) {
            if(error) {
                if ([target respondsToSelector:selector]) {
                    [target performSelector:selector withObject:error afterDelay:0.0];
                }
                return;
            }
            id eventsData = [[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] valueForKey:EVENTS_KEY];
            NSLog(@"Discover Data = %@",eventsData);
            if ([eventsData isKindOfClass:[NSArray class]])
                self.discoverEventsArray = [self convertArrayElementsToEvents:eventsData];
            self.events = self.discoverEventsArray;
            
        };
    
    switch (self.eventClass) {
        case Discovery:
            [ServerFetcher fetchEventsArrayWithConstraints:[self.eventsQueryConstraints eventConstraintDictionary] withCallback:discoverCallback];
            break;
        case Bookmarked:
            //TODO reload events data, after time period!!!!
            self.bookmarkedEventsArray = [self convertArrayElementsToEvents:[self.bookmarkedEvents allValues]];
            self.events = self.bookmarkedEventsArray;
            break;
        default:
            break;
    }
}

@synthesize events = _events;

-(NSArray*)events {
    if (!_events) {
        _events = [[NSArray alloc] init];
        //        [self reloadEvents];
    }
    return _events;
}

-(void)setEvents:(NSArray *)events {
    _events = events;
    //Notify observers of events changed!
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EventsChangedNotification" object:self];
}

-(void)setEventClass:(EventsDiscoveryBookmarkedFollowed)eventClass {
    [self setEventClass:eventClass withErrorHandler:nil selector:nil];
}

-(void)setEventClass:(EventsDiscoveryBookmarkedFollowed)eventClass withErrorHandler:(id)target selector:(SEL)selector {
    _eventClass = eventClass;
    switch (eventClass) {
        case Discovery:
            self.events = self.discoverEventsArray;
            break;
        case Bookmarked:
            self.events = self.bookmarkedEventsArray;
            break;
        default:
            break;
    }
    [self reloadEventsWithErrorHandler:target selector:selector];  //TODO: Reload discovery and following after time period
                                                            // TODO handle error connection
}

@end
