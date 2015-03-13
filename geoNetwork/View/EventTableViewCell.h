//
//  EventTableViewCell.h
//  townbilly
//
//  Created by David Wyrobnik on 11/8/14.
//  Copyright (c) 2014 townbilly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *filterTags;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UILabel *timeLable;

@end
