//
//  EventDetailViewController.h
//  townbilly
//
//  Created by David Wyrobnik on 12/1/14.
//  Copyright (c) 2014 townbilly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Event.h"

@interface EventDetailViewController : UITableViewController <MKMapViewDelegate>

@property (strong, nonatomic) Event *event;

@end
