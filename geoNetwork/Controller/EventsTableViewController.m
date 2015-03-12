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
#import "UIImageView+WebCache.h"
#import "EventDetailViewController.h"

@interface EventsTableViewController ()

@property (strong, nonatomic) LibraryAPI* api;

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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.api.events count];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *eventsTableCellIdentifier = @"Events_Table_Cell";
    
    EventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:eventsTableCellIdentifier];
    
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"EventTableViewCell" bundle:nil] forCellReuseIdentifier:eventsTableCellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:eventsTableCellIdentifier];
    }
    
    if ([[self.api.events objectAtIndex:indexPath.row] isKindOfClass:[Event class]]) {
        Event *event = [self.api.events objectAtIndex:indexPath.row];
        
        cell.title.text = event.title;
        cell.filterTags.text = [event.filters componentsJoinedByString:@", "];
        cell.address.text = event.venue;
        [cell.imageView sd_setImageWithURL:event.icon_url placeholderImage:[UIImage imageNamed:@"MITEngineersLogo"]];
    }
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
