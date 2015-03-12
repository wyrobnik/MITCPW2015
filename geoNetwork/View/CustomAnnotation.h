//
//  CustomAnnotation.h
//  townbilly
//
//  Created by David Wyrobnik on 11/14/14.
//  Copyright (c) 2014 townbilly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Event.h"

@interface CustomAnnotation : NSObject<MKAnnotation>
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *title;
@property (nonatomic, strong) Event *event;
//@property (nonatomic) BOOL dropped;

-(id)initWithEvent:(Event*)event;
-(MKAnnotationView*)annotationView;

@end
