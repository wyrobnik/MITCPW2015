//
//  SingleEventMapViewController.h
//  townbilly
//
//  Created by David Wyrobnik on 1/8/15.
//  Copyright (c) 2015 townbilly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Event.h"

@interface SingleEventMapViewController : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) Event *event;

@end
