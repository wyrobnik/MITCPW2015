//
//  EventTableViewCell.m
//  townbilly
//
//  Created by David Wyrobnik on 11/8/14.
//  Copyright (c) 2014 townbilly. All rights reserved.
//

#import "EventTableViewCell.h"

@implementation EventTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@synthesize title = _title;
@synthesize filterTags = _filterTags;
@synthesize address = _address;



@end
