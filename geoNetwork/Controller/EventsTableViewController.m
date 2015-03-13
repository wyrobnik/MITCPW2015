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

@property (strong, nonatomic) LibraryAPI* api;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

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
    self.api = [LibraryAPI sharedInstance];
    //When reload gets called in LibraryAPI, get's notified and reloads data in tableview (observer pattern with notification)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"EventsChangedNotification" object:nil];
    //TODO: If no data/count 0, then handle
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"EEE hh:mm aaa"];
}

//This is called when class is notified of reloaded event data
-(void)reloadData {
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return [self.dateFormatter stringFromDate:[[LibraryAPI sharedInstance].sortedEventSections objectAtIndex:section]];
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
    
    cell.timeLable.text = [NSString stringWithFormat:@"%@ - %@", [self.dateFormatter stringFromDate:event.startTime], [self.dateFormatter stringFromDate:event.endTime]];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"segueSingleEvent" sender:indexPath];
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
            NSIndexPath *indexPathSender = sender;
            EventDetailViewController *destinationViewController = segue.destinationViewController;
            [destinationViewController setEvent:[self.api.events objectAtIndex:indexPathSender.row]];
        }
    }
    
}


@end
