//
//  Event.m
//  townbilly
//
//  Created by David Wyrobnik on 11/23/14.
//  Copyright (c) 2014 townbilly. All rights reserved.
//

#import "Event.h"

//Event
#define EVENT_ID @"id"
#define EVENT_TITLE @"title"
#define EVENT_DESCRIPTION @"description"
#define EVENT_ICON_URL @"icon_url"
#define EVENT_START_TIME @"start_time"
#define EVENT_END_TIME @"end_time"

#define EVENT_FILTER1 @"filter_1"
#define EVENT_FILTER2 @"filter_2"
#define EVENT_FREE @"free"

//Business
#define BUSINESS_ID @"business_id"
#define BUSINESS_NAME @"business_name"
#define BUSINESS_PHONE_NUMBER @"phone_number"
#define BUSINESS_WEBSITE_URL @"website_url"

//Location
#define LOCATION_LONGITUDE @"longitude"
#define LOCATION_LATITUDE @"latitude"
#define LOCATION_VENUE @"venue_name"
#define LOCATION_STREET @"address"
#define LOCATION_CITY @"city"
#define LOCATION_STATE @"state"
#define LOCATION_ZIP @"zip"

@implementation Event

id NSNullToNil(id object) {
    return (object == (id)[NSNull null]) ? @"" : object;
}

//void convertPhoneNumberString(id string) {
//    if ([string isKindOfClass:[NSString class]]) {
////        NSMutableString *tempString = [[NSMutableString alloc] initWithCapacity:([string count] + 5)];
//        //Assuming in Number is US number
//        switch ([string count]) {
//            case 10:
//                string = [NSString stringWithFormat:@"(%@) %@-%@"];
//                break;
//            case 14:
//            case 15:
//                break;
//            default:
//                break;
//        }
//    }
//}

-(instancetype)initWithJSONEvent:(NSDictionary *)jsonEvent {
    
    self = [super init];
    if (self) {
        @try {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            _jsonEvent = jsonEvent;
            
            _event_id = [NSString stringWithFormat:@"%@",[jsonEvent valueForKey:EVENT_ID]];
            _title = [jsonEvent valueForKey:EVENT_TITLE];
            _description_event = NSNullToNil([jsonEvent valueForKey:EVENT_DESCRIPTION]);
            _icon_url = [NSURL URLWithString:NSNullToNil([jsonEvent valueForKey:EVENT_ICON_URL])];
            _startTime = [dateFormatter dateFromString:[jsonEvent valueForKey:EVENT_START_TIME]];
            _endTime = [dateFormatter dateFromString:[jsonEvent valueForKey:EVENT_END_TIME]];
            
            _business_id = [NSString stringWithFormat:@"%@",[jsonEvent valueForKey:BUSINESS_ID]];
            _business_name = NSNullToNil([jsonEvent valueForKey:BUSINESS_NAME]);
            _phoneNumber = NSNullToNil([jsonEvent valueForKey:BUSINESS_PHONE_NUMBER]);
            _website_url = [NSURL URLWithString:NSNullToNil([jsonEvent valueForKey:BUSINESS_WEBSITE_URL])];
        
            _longitude = [[jsonEvent valueForKey:LOCATION_LONGITUDE] doubleValue];
            _latitude = [[jsonEvent valueForKey:LOCATION_LATITUDE] doubleValue];
            _venue = NSNullToNil([jsonEvent valueForKey:LOCATION_VENUE]);
            _street_address = NSNullToNil([jsonEvent valueForKey:LOCATION_STREET]);
            _city = NSNullToNil([jsonEvent valueForKey:LOCATION_CITY]);
            _state = NSNullToNil([jsonEvent valueForKey:LOCATION_STATE]);
            _zip = NSNullToNil([jsonEvent valueForKey:LOCATION_ZIP]);
            
            _filters = @[NSNullToNil([jsonEvent valueForKey:EVENT_FILTER1]),
                         NSNullToNil([jsonEvent valueForKey:EVENT_FILTER2])];
            _free = [NSNullToNil([jsonEvent valueForKey:EVENT_FREE]) isEqualToString:@"1"];
            
        } @catch(NSException *exception) {
            NSLog(@"Exception in forming event object: %@", exception);
        }
    }
    return self;
}

@end
