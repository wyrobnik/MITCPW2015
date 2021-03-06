//
//  ServerFetcher.m
//  townBilly
//
//  Created by David Wyrobnik on 10/10/14.
//  Copyright (c) 2014 townbilly. All rights reserved.
//

#import "ServerFetcher.h"
#import "Settings.h"

#define EVENTS_LIST @"event_ids"

#define FACEBOOK_ID @"facebook_id"
#define TOWNBILLY_ID @"ID"

//#define TOWNBILLY_REQUEST_URL @"http://www.townbilly.com/app_requests_sdkfjhvfjvbakjsbfkryjouiewtvblk/"
#define TOWNBILLY_REQUEST_URL @"http://mit-cpw.herokuapp.com/app_requests_sdkfjhvfjvbakjsbfkryjouiewtvblk/"

@implementation ServerFetcher

//General function to make post request and on completion calls callback block
+(void)makeRequestWithUrlExtension:(NSString*)urlExtension isPost:(BOOL)isPost withPostDictionary:(NSDictionary*)postDictionary withCallback:(void (^)(NSData *data, NSURLResponse *response, NSError *error))callback {
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", TOWNBILLY_REQUEST_URL, urlExtension]];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    NSError *error = nil;
    if (isPost) {
        [urlRequest setHTTPMethod:@"POST"];
        
        NSData *post = [NSJSONSerialization dataWithJSONObject:postDictionary options:kNilOptions error:&error];
        [urlRequest setHTTPBody:post];
        
    } else {
        [urlRequest setHTTPMethod:@"GET"];
    }
    
    if (!error) {
        NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:urlRequest
                                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                                callback(data, response, error); //Callback
                                                            }];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [dataTask resume];
    }
}


// Init request (filters)
+(void)initRequestwithCallback:(void (^)(NSData *data, NSURLResponse *response, NSError *error))callback {
    NSString *urlExtension = @"init.php";
    [ServerFetcher makeRequestWithUrlExtension:urlExtension isPost:NO withPostDictionary:nil withCallback:callback];
}

#pragma mark - fetch Events

/**
 Fetches Events given constraints specified in constraints. This function start the request, but the actual assignment happens in the callback function
 @param constraints NSDictionary that specifies that constraints given in Documentation
 Example:
    @{
      @"start_time": @"2014-11-03 01:00:00",
      @"end_time": @"2014-11-04 2:00:00",
      @"distance_from_location":
          @{@"longitude": [NSNumber numberWithDouble:-71.890],
            @"latitude": [NSNumber numberWithDouble:0.00],
            @"distance_km": [NSNumber numberWithDouble:3.42]},
      @"categories": @"Nightlife"
      };
 @param callback. This is the callback block that gets called once the data has returned from the URLSession
 */
+(void)fetchEventsArrayWithConstraints:(NSDictionary*)constraints withCallback:(void (^)(NSData *data, NSURLResponse *response, NSError *error))callback {
    NSString *urlExtension = @"event_request.php";
    [ServerFetcher makeRequestWithUrlExtension:urlExtension isPost:YES withPostDictionary:constraints withCallback:callback];
    
}

//For bookmarked events (in app)
+(void)fetchListOfEvents:(NSSet *)eventIds withCallback:(void (^)(NSData *, NSURLResponse *, NSError *))callback {
    NSString *urlExtension = @"search_specific_events.php";
    NSDictionary *postDictionary = @{
                                     EVENTS_LIST : [[eventIds allObjects] componentsJoinedByString:@","]
                                     };
    [ServerFetcher makeRequestWithUrlExtension:urlExtension isPost:YES withPostDictionary:postDictionary withCallback:callback];
}



@end
