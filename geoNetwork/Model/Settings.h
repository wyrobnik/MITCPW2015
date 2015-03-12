//
//  Settings.h
//  townbilly
//
//  Created by David Wyrobnik on 1/21/15.
//  Copyright (c) 2015 townbilly. All rights reserved.
//

#import <Foundation/Foundation.h>

//Singleton
@interface Settings : NSObject

@property (strong, nonatomic) NSString *townbillyUserId;

+(Settings*)sharedInstance;

@end
