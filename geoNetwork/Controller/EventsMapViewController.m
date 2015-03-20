//
//  EventsMapViewController.m
//  townbilly
//
//  Created by David Wyrobnik on 8/26/14.
//  Copyright (c) 2014 townbilly. All rights reserved.
//

#import "EventsMapViewController.h"
#import "LibraryAPI.h"
#import "CustomAnnotation.h"
#import "EventDetailViewController.h"

@interface EventsMapViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) LibraryAPI* api;
@property (nonatomic) int selectedHourInt;
@property (strong, nonatomic, readonly) NSDate *selectedHour;
@property (nonatomic) BOOL changingHour;

@end

@implementation EventsMapViewController

-(void)viewDidLoad {
//    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(42.357, -71.093), 1000, 2500)];
//    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.location.coordinate, 1000, 2500)];  //TODO: Will get user location in app general (global variable) and then use here

    [self setup];
}

-(void)setup {
    self.mapView.delegate = self;
    self.api = [LibraryAPI sharedInstance];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redrawEvents) name:@"EventsChangedNotification" object:nil];
    
    [self redrawEvents];
    //TODO: If no data/count 0, then handle
}

-(void)viewDidAppear:(BOOL)animated {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self redrawEvents];  //So annotations centered correctly
    });
}

#pragma mark - Slider logic

-(void)setHourSlider:(UISlider *)hourSlider {
    _hourSlider = hourSlider;
    [hourSlider addTarget:self action:@selector(scrollUsingSlider) forControlEvents:UIControlEventValueChanged];
    [hourSlider addTarget:self action:@selector(startScrollUsingSlider) forControlEvents:UIControlEventTouchDown];
    [hourSlider addTarget:self action:@selector(endScrollUsingSlider) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel)];
}

-(void)scrollUsingSlider {
    [self setSelectedHourInt:self.hourSlider.value];
}

-(void)startScrollUsingSlider {
    self.changingHour = YES;
    //Map include all events of day
    MKMapRect zoomRect = MKMapRectNull;
    for (Event *event in self.api.events)  //All events
    {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(CLLocationCoordinate2DMake(event.latitude, event.longitude));  //TODO reuse annotationPoint
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1); //TODO reuse pointRect
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    double inset = -zoomRect.size.height * 0.2;
    if ([self.mapView.annotations count] > 0)  //Avoid zooming in and out
        [self.mapView setVisibleMapRect:MKMapRectInset(zoomRect, inset, inset) animated:YES];
    
}

-(void)endScrollUsingSlider {
    self.changingHour = NO;
    [self redrawEvents];
}

/*
 * This redraws annotations and resizes map so that all are visible (removes old annotations and adds new ones)
 *
 */
//TODO: Add user location
-(void)redrawEvents {
    
    [self.mapView removeAnnotations:self.mapView.annotations]; //This also removes the user location pin!!!
    NSArray *eventsArray;
    if (self.api.eventClass == Discovery) {
        eventsArray = [self.api.eventSections objectForKey:self.selectedHour];
    } else {
        eventsArray = self.api.events;
    }
    
    if (!eventsArray) {
        return;
    }
    
    for (int i = 0; i < [eventsArray count]; i++) {
         if ([[self.api.events objectAtIndex:i] isKindOfClass:[Event class]]) {
             Event *event = [eventsArray objectAtIndex:i];
             
             // Annotations
             CustomAnnotation *annotation = [[CustomAnnotation alloc]
                                             initWithEvent:event];
            
             [self.mapView addAnnotation:annotation];
         } 
    }
    
    if (!self.changingHour) {
    // Center visibleMapRegion around annotations
        MKMapRect zoomRect = MKMapRectNull;
        for (id <MKAnnotation> annotation in self.mapView.annotations)
        {
            MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate); 
            MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
        double inset = -zoomRect.size.height * 0.2;
        if ([self.mapView.annotations count] > 0)  //Avoid zooming in and out
            [self.mapView setVisibleMapRect:MKMapRectInset(zoomRect, inset, inset) animated:YES];
    }
    
}


-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
//    static NSTimeInterval delayBetweenDrops = 0.0;
    if ([annotation isKindOfClass:[CustomAnnotation class]]) {
        CustomAnnotation *customAnnotion = (CustomAnnotation*)annotation;
        
        MKAnnotationView *annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomAnnotationView"];
        if (annotationView == nil) {
            annotationView = [customAnnotion annotationView];
        } else {
            annotationView.annotation = annotation;
        }
        
        //Animate drop
//        if (!customAnnotion.dropped) {
//            CGRect endFrame = annotationView.frame;
//            annotationView.frame = CGRectOffset(endFrame, 0, -600);
//            delayBetweenDrops += 0.05;
//            [UIView animateKeyframesWithDuration:0.5 delay:delayBetweenDrops options:UIViewAnimationCurveEaseInOut animations:^{
//                annotationView.frame = endFrame;
//            } completion:^(BOOL finished) {
//                customAnnotion.dropped = YES;
//            }];
//        }
        
        return annotationView;
    }
    return nil;

}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    [self performSegueWithIdentifier:@"singleEventSegueFromMap" sender:view.annotation];
}

-(void)setMapView:(MKMapView *)mapView {
    _mapView = mapView;
    // Get authorization
    CLLocationManager *manager = [LibraryAPI sharedInstance].locationManager;
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
        [manager startUpdatingLocation];
    }
    self.mapView.showsUserLocation = YES;
}

-(void)setSelectedHourInt:(int)selectedHourInt {
    if (_selectedHourInt != selectedHourInt) {
        _selectedHourInt = selectedHourInt;
        [self redrawEvents];
    }
}

-(NSDate *)selectedHour {
    //Convert to date
    //Beginning of day
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self.api.eventsQueryConstraints.startTime];
    NSDate *dateToPass = [[NSCalendar currentCalendar] dateFromComponents:components];
    //Add hours
    NSTimeInterval selectedHoursToSeconds = self.selectedHourInt * 60 * 60; //Remember, slider has value from 6 to 30
    dateToPass = [dateToPass dateByAddingTimeInterval:selectedHoursToSeconds];
    return dateToPass;
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"singleEventSegueFromMap"]) {
        CustomAnnotation *annotation = sender;
        EventDetailViewController *destinationViewController = segue.destinationViewController;
        [destinationViewController setEvent:annotation.event];
        
    }

}


@end
