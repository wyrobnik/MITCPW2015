//
//  EventDetailViewController.m
//  townbilly
//
//  Created by David Wyrobnik on 12/1/14.
//  Copyright (c) 2014 townbilly. All rights reserved.
//

#import "EventDetailViewController.h"
#import "SingleEventMapViewController.h"
#import "LibraryAPI.h"

@interface EventDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *eventTitle;
@property (weak, nonatomic) IBOutlet UITableViewCell *startTimeCell;
@property (weak, nonatomic) IBOutlet UILabel *filterLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UITextView *eventDescription;
@property (weak, nonatomic) IBOutlet UILabel *eventAddress;

@end

@implementation EventDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.eventTitle.text = self.event.title;
    
    //TextView adjust size
    NSAttributedString *description = [[NSAttributedString alloc] initWithString:self.event.description_event
                                                                      attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14.0f]}];
    [self.eventDescription setAttributedText:description];
    CGFloat neededHeight = [self.eventDescription sizeThatFits:CGSizeMake(self.view.frame.size.width, FLT_MAX)].height;
    CGRect textViewFrame = self.eventDescription.frame;
    textViewFrame.size.height = neededHeight + 20.0f;  // + buffer
    self.eventDescription.frame = textViewFrame;
    
    
    self.eventAddress.text = self.event.venue;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormatter setDateFormat:@"EEEE hh:mm a"];
    NSString *startTime = [dateFormatter stringFromDate:self.event.startTime];
    
    NSDate *startDate;
    NSDate *endDate;
    [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&startDate interval:NULL forDate:self.event.startTime];
    [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&endDate interval:NULL forDate:self.event.endTime];
    if ([startDate compare:endDate] == NSOrderedSame) {
        [dateFormatter setDateFormat:@"hh:mm a"];
    }
    
    NSString *endTime = [dateFormatter stringFromDate:self.event.endTime];
    
    self.startTimeCell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", startTime, endTime];
    //    [NSDateFormatter localizedStringFromDate:self.event.startTime dateStyle:NSDateFormatterFullStyle timeStyle:NSDateFormatterShortStyle];

    //Filters
    self.filterLabel.text = [self.event.filters componentsJoinedByString:@", "];
    
    
    
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
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat output;
    switch (indexPath.section) {
        case 0:
            output = 60.0f;
            break;
        case 1:
        case 2:
            output = 44.0f;
            break;
        case 3:
            output = self.eventDescription.frame.size.height;
            break;
        case 4:
            if (indexPath.row == 0)
                output = 128.0f;
            else
                output = 44.0f;
            break;
        default:
            output = 44.0f;
            break;
    }
    return output;
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
