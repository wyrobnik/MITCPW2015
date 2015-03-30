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

#define FILTERS_KEY @"filters"

@interface LibraryAPI ()

@property (strong, nonatomic, readwrite) NSArray *events;
@property (strong, nonatomic, readwrite) NSMutableDictionary* eventSections;

//For quick switch!
@property (strong, nonatomic) NSArray *discoverEventsArray;
@property (strong, nonatomic) NSArray *bookmarkedEventsArray;
//TODO add dictionary for quick switch

@end

@implementation LibraryAPI {
    NSDictionary* categoryTranslateDictionary;  //Edit this to change the translation of short notation categories
}

+(LibraryAPI*)sharedInstance {
    static LibraryAPI *_obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _obj = [[LibraryAPI alloc] init];
        
        // Make server init call to get filter tags
        [ServerFetcher initRequestwithCallback:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            NSDictionary *initDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"Filters = %@", initDic);
            
            //Set date range 
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
            [_obj setRangeStartDate:[dateFormatter dateFromString:[initDic valueForKey:@"start_date"]]];
            [_obj setRangeEndDate:[dateFormatter dateFromString:[initDic valueForKey:@"end_date"]]];
            
            [EventsQueryConstraints setFilterTags:[[[initDic valueForKey:FILTERS_KEY] allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
            
            // TODO make this cleaner, or remove observers after seeing init notification
            [[NSNotificationCenter defaultCenter] postNotificationName:@"InitRequestReturned" object:self];
            
        }];
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


-(NSArray*)convertArrayElementsToEvents:(NSArray*)arrayOfJsonEvents {
    NSMutableArray *arrayOfEvents = [[NSMutableArray alloc] initWithCapacity:[arrayOfJsonEvents count]];
    for (NSUInteger i = 0; i < [arrayOfJsonEvents count]; i++) {
        [arrayOfEvents addObject:[[Event alloc] initWithJSONEvent:[arrayOfJsonEvents objectAtIndex:i]]];
    }
    return arrayOfEvents;
}

// This creates a dictionary of array of events, by starttime hour
-(NSMutableDictionary*)eventSectionsDictionaryFromSortedArray:(NSArray*)eventsArray {
    NSMutableDictionary *output = [[NSMutableDictionary alloc] init];
    
    for (Event *event in eventsArray) {
        NSDate *dateRepresentingThisHour = [self dateAtBeginningOfHourForDate:event.startTime];
    
        NSMutableArray *eventsOnThisDay = [output objectForKey:dateRepresentingThisHour];
        if (eventsOnThisDay == nil) {
            eventsOnThisDay = [NSMutableArray array];
            
            // Use the reduced date as dictionary key to later retrieve the event list this day
            [output setObject:eventsOnThisDay forKey:dateRepresentingThisHour];
        }
        
        // Add the event to the list for this day
        [eventsOnThisDay addObject:event];
        
    }
    
    return output;
}

-(NSDate*)dateAtBeginningOfHourForDate:(NSDate*)inputDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // Selectively convert the date components (year, month, day) of the input date
    NSDateComponents *dateComps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit fromDate:inputDate];
    [dateComps setMinute:0];
    [dateComps setSecond:0];
    
    NSDate *outputDate = [calendar dateFromComponents:dateComps];
    return outputDate;
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
    //set sections dictionary
    [self setEventSections:[self eventSectionsDictionaryFromSortedArray:_events]];
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

-(void)setEventSections:(NSMutableDictionary *)eventSections {
    _eventSections = eventSections;
    _sortedEventSections = [[_eventSections allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

-(CLLocationManager*)locationManager {
    if (!_locationManager) {
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;

        // Get Authorization
        CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
        if (!(authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusRestricted))
        {
            if (authorizationStatus == kCLAuthorizationStatusNotDetermined) {
                if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                    [_locationManager requestWhenInUseAuthorization];
                }
                authorizationStatus = [CLLocationManager authorizationStatus];
                [CLLocationManager locationServicesEnabled];
            }
        }
    }
    return _locationManager;
}

@end
