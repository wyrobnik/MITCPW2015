//
//  SidebarTableViewController.m
//  townbilly
//
//  Created by David Wyrobnik on 11/23/14.
//  Copyright (c) 2014 townbilly. All rights reserved.
//

#import "SidebarTableViewController.h"
#import "LibraryAPI.h"
#import "SidebarNavigationCustomView.h"
#import "SettingsViewController.h"
#import "EventsViewController.h"
#import "UIColor_Extension.h"

@interface SidebarTableViewController ()

@property (strong, nonatomic) NSMutableDictionary *tempEventsQueryConstraintsCategories;
@property (strong, nonatomic) NSMutableArray *globalEventsQueryConstraintsCategories;  //getter points to LibraryAPI

@property (strong, nonatomic) UIView *selectedMarkerBar;  // Green Bar that shows which eventClass LibraryAPI is in

@end


@implementation SidebarTableViewController

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self loadEventViewControllers];
    
//    self.navigationItem.title = @"townbilly";
    self.navigationController.navigationBarHidden = YES;
    SidebarNavigationCustomView *customNavigationBar =  [[[NSBundle mainBundle] loadNibNamed:@"SidebarNavigationCustomView"
                                                                                       owner:self.navigationController
                                                                                     options:nil]
                                                         objectAtIndex:0];
    [customNavigationBar setFrame:CGRectMake(0,
                                            0,
                                            customNavigationBar.frame.size.width,
                                            customNavigationBar.frame.size.height)];
    [self.navigationController.view addSubview:customNavigationBar];
    [customNavigationBar.settingsButton addTarget:self action:@selector(settingsButtonPressedInNavigationBar) forControlEvents:UIControlEventTouchUpInside];
    
    //Set tableview inset (custom navigation bar causes problems)
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [self.tableView setContentInset:UIEdgeInsetsMake(customNavigationBar.frame.size.height, 0, 0, 0)];
    
    [self.tableView setScrollEnabled:NO];
    
    
    // Uncomment the following line to preserve selection between presentations.
//     self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

//-(void)loadEventViewControllers {
//    EventsViewController *discoverVC = [[EventsViewController alloc] initFromMainStoryboardWithSidebar:self];
//    [[UIApplication sharedApplication].keyWindow setRootViewController:discoverVC.navigationController];
//    [[UIApplication sharedApplication].keyWindow addSubview:discoverVC.navigationController.view];
//    [self.view removeFromSuperview];
//}

-(void)viewWillAppear:(BOOL)animated {
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
//    [self setNeedsStatusBarAppearanceUpdate];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)settingsButtonPressedInNavigationBar {
    SettingsViewController *settingsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"settingsViewControllerNavigation"];
    
    CGRect settingsRect = settingsViewController.view.frame;
    settingsRect.origin.y += self.view.window.frame.size.height;
    settingsViewController.view.frame = settingsRect;
    
    [self.view.window addSubview:settingsViewController.view];
    //Transition done like this manually instead of presentViewController, because otherwise buggy 
    [UIView animateWithDuration:0.4f
                     animations:^{
                         CGRect settingsRect = settingsViewController.view.frame;
                         settingsRect.origin.y -= self.view.window.frame.size.height;
                         settingsViewController.view.frame = settingsRect;
                     } completion:^(BOOL finished) {
                         [self addChildViewController:settingsViewController];
                         [settingsViewController didMoveToParentViewController:self];
                     }];
    
//    [self presentViewController:settingsViewController animated:YES completion:^{
//        [[UIApplication sharedApplication] setStatusBarHidden:NO];
//    }];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return  [LibraryAPI sharedInstance].eventClass == Discovery ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:  //Filters
            return [[EventsQueryConstraints filterTags] count]; //+2;
            break;
        default:
            break;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return @"Filters";
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SidebarTableCell" forIndexPath:indexPath];
    
    // Configure the cell...
    if (indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.tintColor = [UIColor whiteColor];
        cell.textLabel.text = [LibraryAPI convertToString:(int)indexPath.row];  //Discover, Followed, Bookmarked
        
        if (indexPath.row == [[LibraryAPI sharedInstance] eventClass]) {
//            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            self.selectedMarkerBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4, cell.frame.size.height)];
            self.selectedMarkerBar.backgroundColor = [UIColor appPrimaryColor];
            [cell addSubview:self.selectedMarkerBar];
            //bold
            cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
        }
        
    }
    if (indexPath.section == 1) {
        NSArray *filterTags = [EventsQueryConstraints filterTags];
        
        if (indexPath.row < [filterTags count]) {
            NSString *filterTag = [filterTags objectAtIndex:indexPath.row];
            cell.textLabel.text = filterTag;
            cell.tintColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            // Assign Checkmark, if contained in eventConstraines (global)
            if ([self.globalEventsQueryConstraintsCategories containsObject:filterTag]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [self.tempEventsQueryConstraintsCategories setValue:@"1" forKey:filterTag];
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
                [self.tempEventsQueryConstraintsCategories setValue:@"0" forKey:filterTag];
            }
        }
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSIndexPath *previousIndexPath = [tableView indexPathForCell:(UITableViewCell*)[self.selectedMarkerBar superview]];
        [self.selectedMarkerBar removeFromSuperview];
        [cell addSubview:self.selectedMarkerBar];
        
        //Unbold
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:previousIndexPath];
        oldCell.textLabel.font = [UIFont systemFontOfSize:16.0];
        // bold new
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
        
        if (indexPath.row != [[LibraryAPI sharedInstance] eventClass]) {  //same button
            UINavigationController *navVC = (UINavigationController*)self.presentingViewController;
            [[LibraryAPI sharedInstance] setEventClass:(int)indexPath.row withErrorHandler:navVC.topViewController selector:@selector(handleConnectionError:)];
        }

        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (indexPath.section == 1) {
        if (indexPath.row < [[EventsQueryConstraints filterTags] count]) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            BOOL includeFilterTag = cell.accessoryType == UITableViewCellAccessoryNone;
            cell.accessoryType = includeFilterTag ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            cell.textLabel.font = includeFilterTag ? [UIFont boldSystemFontOfSize:16.0] : [UIFont systemFontOfSize:16.0];
            cell.tintColor = [UIColor whiteColor];//[UIColor appPrimaryColor];
            
            NSString *filterTag = [[EventsQueryConstraints filterTags] objectAtIndex:indexPath.row];
            //Add/remove filter
            if (includeFilterTag) {
                [self.tempEventsQueryConstraintsCategories setValue:@"1" forKey:filterTag];
            } else {
                [self.tempEventsQueryConstraintsCategories setValue:@"0" forKey:filterTag];
            }
            
            
            // Delayed filtering
            static dispatch_time_t staticChangedFilterTimestamp;
            double delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            staticChangedFilterTimestamp = popTime;
            dispatch_after(popTime, dispatch_get_main_queue(), ^{
                if (staticChangedFilterTimestamp == popTime) {
                    NSMutableArray *newFilters = [[NSMutableArray alloc] initWithCapacity:[[EventsQueryConstraints filterTags] count]];
                    for (NSString *key in self.tempEventsQueryConstraintsCategories) {
                        if ([[self.tempEventsQueryConstraintsCategories objectForKey:key] isEqualToString:@"1"]) {
                            [newFilters addObject:key];
                        }
                    }
                    if (![self.globalEventsQueryConstraintsCategories isEqualToArray:newFilters]) {
                        NSLog(@"Apply Filters");
                        self.globalEventsQueryConstraintsCategories = newFilters;
                        UINavigationController *navVC = (UINavigationController*)self.presentingViewController;
                        [[LibraryAPI sharedInstance] reloadEventsWithErrorHandler:navVC.topViewController selector:@selector(handleConnectionError:)];  //Ignore warning, selector gets checked in func!
                    }
                }
            });
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//-(BOOL)prefersStatusBarHidden {
////    return YES;
//    return NO;
//}

-(NSMutableDictionary*)tempEventsQueryConstraintsCategories {
    if (!_tempEventsQueryConstraintsCategories) {
        _tempEventsQueryConstraintsCategories = [[NSMutableDictionary alloc] init];
    }
    return _tempEventsQueryConstraintsCategories;
}

-(NSMutableArray*)globalEventsQueryConstraintsCategories {
    return [[LibraryAPI sharedInstance] eventsQueryConstraints].categories;
}

-(void)setGlobalEventsQueryConstraintsCategories:(NSMutableArray *)globalEventsQueryConstraintsCategories {
    [[LibraryAPI sharedInstance] eventsQueryConstraints].categories = globalEventsQueryConstraintsCategories;
}

@end
