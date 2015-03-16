//
//  ServerFetcher.h
//  townBilly
//
//  Created by David Wyrobnik on 10/10/14.
//  Copyright (c) 2014 townbilly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerFetcher : NSObject

+(void)fetchEventsArrayWithConstraints:(NSDictionary*)constraints withCallback:(void (^)(NSData *data, NSURLResponse *response, NSError *error))callback;
+(void)fetchListOfEvents:(NSSet*)eventIds withCallback:(void (^)(NSData *data, NSURLResponse *response, NSError *error))callback;

+(void)initRequestwithCallback:(void (^)(NSData *data, NSURLResponse *response, NSError *error))callback;


@end