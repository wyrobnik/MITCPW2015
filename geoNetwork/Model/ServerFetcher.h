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

+(void)updateTownbillyUserIdFromFbUserId:(NSString*)fbUserId;


+(void)followBusiness:(NSString*)businessId withCallback:(void (^)(NSData *data, NSURLResponse *response, NSError *error))callback;
+(void)unfollowBusiness:(NSString*)businessId withCallback:(void (^)(NSData *data, NSURLResponse *response, NSError *error))callback;
+(void)fetchAllFollowedBusinessesEventsWithCallback:(void (^)(NSData *, NSURLResponse *, NSError *))callback;
+(void)fetchFollowedBusinessesWithCallback:(void (^)(NSData *data, NSURLResponse *response, NSError *error))callback;

@end