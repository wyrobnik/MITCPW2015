//
//  SingleEventMapViewController.m
//  townbilly
//
//  Created by David Wyrobnik on 1/8/15.
//  Copyright (c) 2015 townbilly. All rights reserved.
//

#import "SingleEventMapViewController.h"
#import "LibraryAPI.h"

@interface SingleEventMapViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation SingleEventMapViewController


-(void)viewDidLoad {
    self.mapView.delegate = self;
    
    // Get authorization
    CLLocationManager *manager = [LibraryAPI sharedInstance].locationManager;
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
        [manager startUpdatingLocation];
    }
    self.mapView.showsUserLocation = YES;
    
//    [self.mapView removeAnnotation:[self.mapView.annotations objectAtIndex:0]];
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(self.event.latitude, self.event.longitude);
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:coord];
    [self.mapView addAnnotation:annotation];
    
    //Set region
    MKCoordinateSpan span = MKCoordinateSpanMake(0.03, 0.03);
    MKCoordinateRegion region = {coord, span};
    [self.mapView setRegion:region];
    
    //add left button to open maps
    UIBarButtonItem *openInMapsButton = [[UIBarButtonItem alloc] initWithTitle:@"Directions" style:UIBarButtonItemStylePlain target:self action:@selector(openInMaps:)];
    self.navigationItem.rightBarButtonItem = openInMapsButton;
}

-(IBAction)openInMaps:(id)sender {
    UIAlertController *confirmOpenMapsAlertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *openInMapsAlertAction = [UIAlertAction actionWithTitle:@"Open in Maps" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        //Alternative could to latitude and longitude with query ll=
//        NSString *addressQueryString = [NSString stringWithFormat:@"%@, %@, %@, %@",
//                                        self.event.street_address,
//                                        self.event.city,
//                                        self.event.state,
//                                        self.event.zip];
        NSString *addressQueryString = [NSString stringWithFormat:@"%f, %f", self.event.latitude, self.event.longitude];
        addressQueryString = [addressQueryString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSString *addressString = [NSString stringWithFormat:@"http://maps.apple.com/?q=%@", addressQueryString];
        
        //    NSString *addressString = [NSString stringWithFormat:@"http://maps.apple.com/?ll=%f,%f", self.event.latitude, self.event.longitude];
        
        NSURL *url = [NSURL URLWithString:addressString];
        [[UIApplication sharedApplication] openURL:url];
    }];
    
    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}];
    
    [confirmOpenMapsAlertController addAction:openInMapsAlertAction];
    [confirmOpenMapsAlertController addAction:cancelButton];
    
    [self presentViewController:confirmOpenMapsAlertController animated:YES completion:nil];
}


@end
