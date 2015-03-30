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
    
    //TODO cleaner
    [[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:@"InitRequestReturned" object:nil];
    
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
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return  [LibraryAPI sharedInstance].eventClass == Explore ? 2 : 1;
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
    UITableViewCell *cell;
    
    // Configure the cell...
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SidebarTableCell" forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.tintColor = [UIColor whiteColor];
        cell.textLabel.text = [LibraryAPI convertToString:(int)indexPath.row];  //Discover, Followed, Bookmarked
        
        if (indexPath.row == [[LibraryAPI sharedInstance] eventClass]) {
            if (!self.selectedMarkerBar) {
                self.selectedMarkerBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4, cell.frame.size.height)];
                self.selectedMarkerBar.backgroundColor = [UIColor appPrimaryColor];
                [cell addSubview:self.selectedMarkerBar];
            }
            //bold
            cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
        }
        
    }
    if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SidebarFilterTableCell" forIndexPath:indexPath];
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
