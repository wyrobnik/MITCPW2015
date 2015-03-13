//
//  EventDetailViewController.m
//  townbilly
//
//  Created by David Wyrobnik on 12/1/14.
//  Copyright (c) 2014 townbilly. All rights reserved.
//

#import "EventDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "SingleEventMapViewController.h"
#import "LibraryAPI.h"

@interface EventDetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *eventIcon;
@property (weak, nonatomic) IBOutlet UILabel *eventTitle;
@property (weak, nonatomic) IBOutlet UITableViewCell *startTimeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *endTimeCell;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UITextView *eventDescription;
@property (weak, nonatomic) IBOutlet UILabel *eventAddress;
@property (weak, nonatomic) IBOutlet UITableViewCell *businessPhone;

@end

@implementation EventDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.eventTitle.text = self.event.title;
//    self.eventStartTime.text = self.event.startTime;
//    self.eventEndTime.text = self.event.endTime;
    self.eventDescription.text = self.event.description_event;
    self.eventAddress.text = self.event.venue;
    [self.eventIcon sd_setImageWithURL:self.event.icon_url placeholderImage:[UIImage imageNamed:@"MITEngineersLogo"]];
    
    self.businessPhone.textLabel.text = self.event.phoneNumber;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"EEEEdMMMhhmm" options:0 locale:dateFormatter.locale];
    self.startTimeCell.textLabel.text = [NSString stringWithFormat:@"Start: %@", [dateFormatter stringFromDate:self.event.startTime]];
    self.endTimeCell.textLabel.text = [NSString stringWithFormat:@"End:  %@",[dateFormatter stringFromDate:self.event.endTime]];
//    [NSDateFormatter localizedStringFromDate:self.event.startTime dateStyle:NSDateFormatterFullStyle timeStyle:NSDateFormatterShortStyle];

    
    
    
    //Border around ImageView
    self.eventIcon.layer.cornerRadius = 9;
    self.eventIcon.layer.masksToBounds = YES;
    self.eventIcon.layer.borderColor = [[UIColor blackColor] CGColor];
    self.eventIcon.layer.borderWidth = 1.0;

    //Setup map
    self.mapView.delegate = self;
    self.mapView.userInteractionEnabled = NO;
    // Map View with pin of address
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(self.event.latitude, self.event.longitude);
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:coord];
    [self.mapView addAnnotation:annotation];
    //Set region
    MKCoordinateSpan span = MKCoordinateSpanMake(0.005, 0.005);
    MKCoordinateRegion region = {coord, span};
    [self.mapView setRegion:region];

    
    //Setup Bookmark UIBarButton
    UIImage *bookmarkIcon = [UIImage imageNamed:([[LibraryAPI sharedInstance].bookmarkedEvents objectForKey:self.event.event_id] ? @"Bookmark-filled" : @"Bookmark")];
    UIBarButtonItem *bookmarkButton = [[UIBarButtonItem alloc] initWithImage:bookmarkIcon style:UIBarButtonItemStylePlain target:self action:@selector(toggleBookmarkEvent)];
    
    self.navigationItem.rightBarButtonItems = @[bookmarkButton];
    
}

-(void)toggleBookmarkEvent {
    LibraryAPI *api = [LibraryAPI sharedInstance];
    UIImage *bookmarkIcon;
    if ([api.bookmarkedEvents objectForKey:self.event.event_id]) {
        [api removeBookmarkedEventsObject:self.event];
        bookmarkIcon = [UIImage imageNamed:@"Bookmark"];
    } else {
        [api addBookmarkedEventsObject:self.event];
        bookmarkIcon = [UIImage imageNamed:@"Bookmark-filled"];
    }
    self.navigationItem.rightBarButtonItem.image = bookmarkIcon;
}

//- (void)viewWillAppear:(BOOL)animated {
//    CGFloat yCoordinate = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height;
//    
//    CGRect viewFrame = CGRectMake(0, yCoordinate, self.parentViewController.view.frame.size.width, self.parentViewController.view.frame.size.height - yCoordinate);
//    
//    self.view.frame = viewFrame;
//    CGRect viewFrame2 = self.view.frame;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Phone call
    if ([indexPath isEqual:[tableView indexPathForCell:self.businessPhone]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", self.event.phoneNumber]]];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"eventDetailMapVC1"] ||
        [segue.identifier isEqualToString:@"eventDetailMapVC2"]) {
        SingleEventMapViewController *vc = segue.destinationViewController;
        vc.event = self.event;
    }
    
}


@end
