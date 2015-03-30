//
//  EventsViewController.m
//  townbilly
//
//  Created by David Wyrobnik on 8/17/14.
//  Copyright (c) 2014 townbilly. All rights reserved.
//

#import "EventsViewController.h"
#import "LibraryAPI.h"
#import "EventsMapViewController.h"
#import "EventsTableViewController.h"
#import "DIDatepicker.h"
#import "SISidebarTransitionObject.h"
#import "DateViewForBarButton.h"
#import "UIColor_Extension.h"
#import "HourSlider.h"

@interface EventsViewController ()

@property (nonatomic, strong) SISidebarTransitionObject *transitionObject;

//@property (weak, nonatomic) IBOutlet DateAndLocationButton *dateButton;
@property (strong, nonatomic) NSDate* selectedDate;
@property (strong, nonatomic) DIDatepicker *datepicker;
@property (strong, nonatomic) HourSlider *hourSlider;  //TODO make this a control
@property (nonatomic) BOOL datepickerOpen;
@property (strong, nonatomic) DateViewForBarButton *selectedDateView;

@property (strong, nonatomic) UIBarButtonItem *datepickerBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *sidebarBarButtonItem;

//container view properties
@property (strong, nonatomic) UIViewController *containerViewController;  //Container to hold table/map vc
@property (strong, nonatomic) EventsTableViewController *eventsTableVC;
@property (strong, nonatomic) EventsMapViewController *eventsMapVC;
@property (strong, nonatomic) UIViewController *currentVC;
@property (nonatomic) BOOL viewSwapInProgress;  //to disable while happening

@end

@implementation EventsViewController

#define CITY_AREA @"Boston Area"
#define TABLE_VC @"eventsTableVC"
#define MAP_VC @"eventsMapVC"
#define SIDEBAR_VC @"SidebarWithNav"

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor appPrimaryColor];
    [self setup];
}

-(void)setup {
//    [self setSelectedDate:[NSDate date]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //Container View Logic  //Sets table view as initial child vc
    //set size of containerFrame
    CGFloat belowNavigationBarY = self.navigationController.navigationBar.frame.origin.y +
    self.navigationController.navigationBar.frame.size.height;
    CGRect containerFrame = CGRectMake(0,
                                     belowNavigationBarY,
                                     [UIScreen mainScreen].bounds.size.width,
                                     [UIScreen mainScreen].bounds.size.height - belowNavigationBarY);
    self.containerViewController = [[UIViewController alloc] init];
    self.containerViewController.view.frame = containerFrame;
    [self addChildViewController:self.containerViewController];
    [self.view addSubview:self.containerViewController.view];
    
    self.eventsTableVC = [self.storyboard instantiateViewControllerWithIdentifier:TABLE_VC];
    self.eventsMapVC = [self.storyboard instantiateViewControllerWithIdentifier:MAP_VC];
    self.currentVC = self.eventsTableVC;
    //Add initial vc to this view
    self.eventsTableVC.view.frame = self.containerViewController.view.bounds;
    [self.containerViewController.view addSubview:self.currentVC.view];
    [self.containerViewController addChildViewController:self.currentVC];
    [self.currentVC didMoveToParentViewController:self.containerViewController];
    
    //Counteract inset of tableview
    [((UITableViewController*)self.eventsTableVC).tableView setContentInset:UIEdgeInsetsMake(-belowNavigationBarY, 0, 0, 0)];
    
    
    //Instantiate sidebarVC and the transitionObject that handles modally presenting the sidebar
    UIViewController *sidebarVC = [self.storyboard instantiateViewControllerWithIdentifier:SIDEBAR_VC];
//    UINavigationController *sidebarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SidebarNavigation"];
    self.transitionObject = [[SISidebarTransitionObject alloc] initWithParentViewController:self withSidebar:sidebarVC];
    
    //Left UIBarButtonItems
    self.sidebarBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"HamburgerIcon"]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(openSidebar:)];
    
    self.selectedDateView = [[DateViewForBarButton alloc] initWithFrame:CGRectMake(0,0,20,20)];
    [self.selectedDateView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(openDateAndLocationPickerViewController:)]];
    
    self.datepickerBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.selectedDateView];
    
    self.navigationItem.leftBarButtonItems = @[self.sidebarBarButtonItem, self.datepickerBarButtonItem];
    
    //Datepicker
    self.datepicker = [[DIDatepicker alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.origin.y, [UIScreen mainScreen].bounds.size.width, self.navigationController.navigationBar.frame.size.height)];
    
    [self.view addSubview:self.datepicker];
    
    [self.datepicker addTarget:self action:@selector(updateSelectedDate) forControlEvents:UIControlEventValueChanged];
    
    //UISlider for hour
    self.hourSlider = [HourSlider loadFromNib];
    self.hourSlider.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, self.navigationController.navigationBar.frame.size.height);
    [self.view addSubview:self.hourSlider];
    [self.eventsTableVC setHourSlider:self.hourSlider.slider]; // Pass pointer to table view
    [self.eventsMapVC setHourSlider:self.hourSlider.slider]; //Pass pointer to Map view
    
    //TODO hacky! Fix
    CGRect rect = self.hourSlider.slider.frame;
    self.hourSlider.slider.frame = CGRectMake(rect.origin.x, 7, [UIScreen mainScreen].bounds.size.width - 90 , rect.size.height);
    
    // Datepicker set dates
    //TODO cleaner
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustDatePicker) name:@"InitRequestReturned" object:nil];
    [self adjustDatePicker];
    
    
}

-(void)adjustDatePicker {
    
    NSDate *startDate;
    NSDate *endDate;
    
    if ([LibraryAPI sharedInstance].rangeStartDate) {
        startDate = [LibraryAPI sharedInstance].rangeStartDate;
        endDate = [LibraryAPI sharedInstance].rangeEndDate;
        
    } else {
        // CHANGE DATES HERE!  // gets adjusted based on server response
        //    [self.datepicker fillDatesFromCurrentDate:90];
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM-dd-yyyy"];
        
        // Testing
//        startDate = [dateFormatter dateFromString:@"04-10-2014"];
//        endDate = [dateFormatter dateFromString:@"04-13-2014"];
        
        // Production
        startDate = [dateFormatter dateFromString:@"04-16-2015"];
        endDate = [dateFormatter dateFromString:@"04-19-2015"];
    }
    
    
    NSDate *dateToday = [NSDate date];
    NSInteger totalDays = [[[NSCalendar currentCalendar] components:NSDayCalendarUnit
                                                           fromDate:startDate
                                                             toDate:endDate
                                                            options:0] day];
    NSInteger indexDay = [[[NSCalendar currentCalendar] components:NSDayCalendarUnit
                                                          fromDate:startDate
                                                            toDate:dateToday
                                                           options:0] day];
    [self.datepicker fillDatesFromDate:startDate numberOfDays:4];
    
    if (!(indexDay >= 0 && indexDay <= totalDays)) {
        indexDay = 0;
    }
    [self.datepicker selectDateAtIndex:indexDay];
    
}

-(void)updateSelectedDate {
    [self setSelectedDate:self.datepicker.selectedDate]; //TODO delete this function and make selector
}

-(void)viewWillAppear:(BOOL)animated {
    //Check whether to show date picker
    NSString *title;
    BOOL datePickingEnabled = YES;
    LibraryAPI *api = [LibraryAPI sharedInstance];
    
    title = [LibraryAPI convertToString:api.eventClass];
    if (api.eventClass == Bookmarked) {
        datePickingEnabled = NO;
    }
    
    self.navigationItem.title = title;
    
    if (!datePickingEnabled) {
        self.navigationItem.leftBarButtonItems = @[self.sidebarBarButtonItem];
        [self setDatepickerOpen:NO];
        self.datepicker.hidden = YES;
    } else {
        self.navigationItem.leftBarButtonItems = @[self.sidebarBarButtonItem, self.datepickerBarButtonItem];
        self.datepicker.hidden = NO;
    }
    
}

-(void)viewDidAppear:(BOOL)animated {
    self.transitionObject.statusBarBackgroundColor = [self.navigationController.navigationBar.barTintColor colorWithAlphaComponent:self.navigationController.navigationBar.alpha]; // [UIColor darkGrayColor];
  
}

- (IBAction)swapMapTableViews:(id)sender {
    if (!self.viewSwapInProgress) {
        self.viewSwapInProgress = YES;
        BOOL tableViewIsCurrent = [self.currentVC isEqual:self.eventsTableVC];
        [sender setImage:[UIImage imageNamed:(!tableViewIsCurrent ? @"MapButtonIcon" : @"ListButtonIcon")]];
        
        UIViewController *vcToDisplay = tableViewIsCurrent ? self.eventsMapVC : self.eventsTableVC;
        [self moveToNewController:vcToDisplay];
    }
}

-(void)moveToNewController:(UIViewController*) newController {
    [self.currentVC willMoveToParentViewController:nil];
    
    newController.view.frame = self.containerViewController.view.bounds;
    
    BOOL tableViewIsCurrent = [self.currentVC isEqual:self.eventsTableVC];
    [self.containerViewController addChildViewController:newController];
    [self.containerViewController transitionFromViewController:self.currentVC
                                              toViewController:newController
                                                      duration:0.5
                                                       options:!tableViewIsCurrent ? UIViewAnimationOptionTransitionFlipFromLeft : UIViewAnimationOptionTransitionFlipFromRight
                                                    animations:^(void) {}
                                                    completion:^(BOOL finished) {
                                                        [self.currentVC removeFromParentViewController];
                                                        [newController didMoveToParentViewController:self];
                                                        self.currentVC = newController;
                                                        self.viewSwapInProgress = NO;
                                                    }];
}

@synthesize selectedDate = _selectedDate;


-(void)setSelectedDate:(NSDate *)selectedDate {
    _selectedDate = selectedDate;
    
    [self.selectedDateView setDate:selectedDate];
    
    if (selectedDate) {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM, dd"];

        NSInteger numberOfDays = [EventsViewController daysBetweenDate:[NSDate date] andDate:_selectedDate];
        
        NSString *dateToDisplay;
        switch (numberOfDays) {
            case -1:
                dateToDisplay = @"Yesterday";
                break;
            case 0:
                dateToDisplay = @"Today";
                break;
            case 1:
                dateToDisplay = @"Tomorrow";
                break;
            default:
                dateToDisplay = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:_selectedDate]];
                break;
        }
        
//        self.dateButton.date = dateToDisplay;
//        self.dateButton.location = CITY_AREA;
//        [self.dateButton setNeedsDisplay];
        
        //Set date constraints for events
        //Set startTime
        LibraryAPI *api = [LibraryAPI sharedInstance];
        NSCalendar* calendar = [NSCalendar currentCalendar];
        if (numberOfDays == 0) {  //If date is today
            api.eventsQueryConstraints.startTime = [NSDate date]; //Now
        } else { //If date sometime in the future
            NSDateComponents *selectedDateAt6AMComponents = [calendar components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:selectedDate];
            [selectedDateAt6AMComponents setHour:6];
            NSDate *selectedDateAt6AM = [calendar dateFromComponents:selectedDateAt6AMComponents];
            api.eventsQueryConstraints.startTime = selectedDateAt6AM;
        }
        
        //Set endTime for nextDat at 6AM
        NSDateComponents* nextDayComponents = [NSDateComponents new] ;
        nextDayComponents.day = 1 ;
        NSDate* nextDay = [calendar dateByAddingComponents:nextDayComponents toDate:selectedDate options:0] ;
        
        NSDateComponents* nextDayAt6AMComponents = [calendar components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:nextDay] ;
        nextDayAt6AMComponents.hour = 6;
        NSDate* nextDayAt6AM = [calendar dateFromComponents:nextDayAt6AMComponents] ;
        api.eventsQueryConstraints.endTime = nextDayAt6AM;
        
        [api reloadEventsWithErrorHandler:self selector:@selector(handleConnectionError:)];

    }
}

-(void)handleConnectionError:(NSError*)error {
    NSLog(@"%@", error);
    //TODO
//    UIView *errorView = [[UIView alloc] initWithFrame:self.view.frame];
//    errorView.backgroundColor = [UIColor grayColor];
//    [self.view addSubview:[[AlertView alloc] initWithFrame:self.view.frame]];
}

//Copied from stackoverflow
+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}


-(NSDate*)selectedDate {
    if (!_selectedDate) {
        _selectedDate = [NSDate date];
    }
    return _selectedDate;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)openSidebar:(id)sender {
    [self.transitionObject showSidebar];
}

- (IBAction)openDateAndLocationPickerViewController:(id)sender {
    self.datepickerOpen = !self.datepickerOpen;
}

-(void)setDatepickerOpen:(BOOL)datepickerOpen {
    _datepickerOpen = datepickerOpen;
    [UIView animateWithDuration:0.2 animations:^{
        [self.datepicker setCenter:CGPointMake(self.datepicker.center.x,
                                                       self.navigationController.navigationBar.frame.origin.y +
                                               self.datepicker.frame.size.height/2 +(datepickerOpen)*44)];
        
        [self.hourSlider setCenter:CGPointMake(self.hourSlider.center.x,
                                               [UIScreen mainScreen].bounds.size.height +
                                               self.hourSlider.frame.size.height/2 -(datepickerOpen)*44)];
        
        CGRect containerFrame = self.containerViewController.view.frame;
        containerFrame = CGRectMake(0,
//                                    containerFrame.origin.y + (-1+2*datepickerOpen)*44,
                                    self.navigationController.navigationBar.frame.origin.y +
                                    self.datepicker.frame.size.height +(datepickerOpen)*44,
                                    containerFrame.size.width,
                                    containerFrame.size.height - 2*(-1+2*datepickerOpen)*44
                                    );
        self.containerViewController.view.frame = containerFrame;
        self.currentVC.view.frame = self.containerViewController.view.bounds;
        
    }];
}

#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}
 */

//-(UIStatusBarStyle)preferredStatusBarStyle {
//    return UIStatusBarStyleLightContent;
//}
//
//-(BOOL)prefersStatusBarHidden {
//    return NO;
//}


@end
