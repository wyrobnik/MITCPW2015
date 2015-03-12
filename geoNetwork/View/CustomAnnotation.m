//
//  CustomAnnotation.m
//  townbilly
//
//  Created by David Wyrobnik on 11/14/14.
//  Copyright (c) 2014 townbilly. All rights reserved.
//

#import "CustomAnnotation.h"
@implementation CustomAnnotation

-(id)initWithEvent:(Event *)event {
    self = [super init];
    if (self) {
        _event = event;
        _title = event.title;
        _coordinate = CLLocationCoordinate2DMake(event.latitude, event.longitude);
//        _dropped = NO;
    }
    return self;
}

-(MKAnnotationView*)annotationView {
    //If want custom image, change to MKAnnotationView and edit annotationView.image
    MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"CustomAnnotationView"];
    
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return annotationView;
    
}

@end
