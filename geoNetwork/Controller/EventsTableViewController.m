//
//  EventsTableViewController.m
//  geoNetwork
//
//  Created by David Wyrobnik on 8/17/14.
//  Copyright (c) 2014 townbilly. All rights reserved.
//

#import "EventsTableViewController.h"
#import "LibraryAPI.h"
#import "EventTableViewCell.h"
#import "EventDetailViewController.h"

@interface EventsTableViewController ()

//TODO single dateformatter for better performance/memory

@property (strong, nonatomic) LibraryAPI* api;
//HACKY solution
@property (nonatomic) BOOL userIsScrollingTable;
@property (nonatomic) BOOL userUsedSlider;


@end

@implementation EventsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)setup {
    self.tableView.delegate = self;
    
    //Handle inset issues
    [self.tableView setContentOffset:CGPointMake(0, 200)]; //TODO this is not clean
    
    self.api = [LibraryAPI sharedInstance];
    //When reload gets called in LibraryAPI, get's notified and reloads data in tableview (observer pattern with notification)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"EventsChangedNotification" object:nil];
    //TODO: If no data/count 0, then handle
}

-(void)setHourSlider:(UISlider *)hourSlider {
    _hourSlider = hourSlider;
    [hourSlider addTarget:self action:@selector(scrollUsingSlider) forControlEvents:UIControlEventValueChanged];
    [hourSlider addTarget:self action:@selector(startScrollUsingSlider) forControlEvents:UIControlEventTouchDown];
}

-(void)startScrollUsingSlider {
    [self.tableView setContentOffset:self.tableView.contentOffset animated:NO];  //Stops scrolling
}

-(void)scrollUsingSlider {
    if (!self.userIsScrollingTable) {
        self.userUsedSlider = YES;
        //Convert to date
        //Beginning of day
        NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self.api.eventsQueryConstraints.startTime];
        NSDate *dateToPass = [[NSCalendar currentCalendar] dateFromComponents:components];
        //Add hours
        NSTimeInterval selectedHoursToSeconds = ((int)self.hourSlider.value) * 60 * 60; //Remember, slider has value from 6 to 30
        dateToPass = [dateToPass dateByAddingTimeInterval:selectedHoursToSeconds];
        
        //Get Section number
        NSInteger sectionIndex = [self.api.sortedEventSections indexOfObject:dateToPass];
        if (sectionIndex >= 0 && sectionIndex < [self.api.sortedEventSections count]) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionIndex] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        self.userUsedSlider = NO;
    }
}

//This is called when class is notified of reloaded event data
-(void)reloadData {
    //Hacky
    [UIView animateWithDuration:0 animations:^{
        [self.tableView reloadData];
    } completion:^(BOOL finished) {
        [self scrollViewDidScroll:self.tableView]; //To set slide to correct value
        self.userIsScrollingTable = NO;
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [LibraryAPI sharedInstance].sortedEventSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSDate *key = [self.api.sortedEventSections objectAtIndex:section];
    NSArray *eventsArray = [self.api.eventSections objectForKey:key];
    return [eventsArray count];
    
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormatter setDateFormat:@"EEE hh:mm a"];
    return [dateFormatter stringFromDate:[[LibraryAPI sharedInstance].sortedEventSections objectAtIndex:section]];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    // Background color
    view.tintColor = [UIColor blackColor];
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *eventsTableCellIdentifier = @"Events_Table_Cell";
    
    EventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:eventsTableCellIdentifier];
    
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"EventTableViewCell" bundle:nil] forCellReuseIdentifier:eventsTableCellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:eventsTableCellIdentifier];
    }
    
    NSDate *key = [self.api.sortedEventSections objectAtIndex:indexPath.section];
    NSArray *eventsArray = [self.api.eventSections objectForKey:key];
    Event *event = [eventsArray objectAtIndex:indexPath.row];
    
    cell.title.text = event.title;
    cell.filterTags.text = [event.filters componentsJoinedByString:@", "];
    cell.address.text = event.venue;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString *startTime = [dateFormatter stringFromDate:event.startTime];

    //Compare dates
    NSDate *startDate;
    NSDate *endDate;
    [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&startDate interval:NULL forDate:event.startTime];
    [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&endDate interval:NULL forDate:event.endTime];
    if ([startDate compare:endDate] != NSOrderedSame) {
        [dateFormatter setDateFormat:@"EEE hh:mm a"];
    }
    
    NSString *endTime = [dateFormatter stringFromDate:event.endTime];
    
    cell.timeLable.text = [NSString stringWithFormat:@"%@ - %@", startTime, endTime];
    
    // Color of row if featured
    if ([cell.filterTags.text rangeOfString:@"Featured"].location != NSNotFound) {
        cell.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"segueSingleEvent" sender:indexPath];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //Set UISlider hours
    if (!self.userUsedSlider) {
        [self setUserIsScrollingTable:YES];
        if ([LibraryAPI sharedInstance].eventClass == Discovery  ) {
            NSArray *visibleCells = [self.tableView visibleCells];
            if (!([visibleCells count] > 0)) {
                return;
            }
            NSUInteger sectionNumber = [[self.tableView indexPathForCell:[visibleCells objectAtIndex:0]] section];
            NSDate *sectionDate = [self.api.sortedEventSections objectAtIndex:sectionNumber];
            
            NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self.api.eventsQueryConstraints.startTime];
            NSDate *selectedDate = [[NSCalendar currentCalendar] dateFromComponents:components];
            
            int hoursDifference = (int)[[[NSCalendar currentCalendar] components:NSHourCalendarUnit fromDate:selectedDate toDate:sectionDate options:0] hour];
            
            if (hoursDifference >= 6 && hoursDifference < 30) {
                self.hourSlider.value = hoursDifference;
                [self.hourSlider sendActionsForControlEvents:UIControlEventValueChanged];
            }
        }
    }
}

//To avoid conflicting messages!!! See scrollViewDidScroll the line [self.hourSlider sendActionsForControlEvents:UIControlEventValueChanged];
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self setUserIsScrollingTable:NO];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self setUserIsScrollingTable:NO];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"segueSingleEvent"]) {
        if ([sender isMemberOfClass:[NSIndexPath class]]) {
            NSIndexPath *indexPath = sender;
            EventDetailViewController *destinationViewController = segue.destinationViewController;
            NSDate *key = [self.api.sortedEventSections objectAtIndex:indexPath.section];
            NSArray *eventsArray = [self.api.eventSections objectForKey:key];
            Event *event = [eventsArray objectAtIndex:indexPath.row];
            [destinationViewController setEvent:event];
        }
    }
    
}


@end
