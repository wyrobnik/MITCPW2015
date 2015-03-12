//
//  Settings.m
//  townbilly
//
//  Created by David Wyrobnik on 1/21/15.
//  Copyright (c) 2015 townbilly. All rights reserved.
//

#import "Settings.h"
#import "ServerFetcher.h"


@implementation Settings

+(Settings*)sharedInstance {
    static Settings *_obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _obj = [[Settings alloc] init];
    });
    return _obj;
}

@end
