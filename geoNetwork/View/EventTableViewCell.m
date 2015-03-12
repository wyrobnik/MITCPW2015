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

@synthesize imageView = _imageView;
@synthesize title = _title;
@synthesize filterTags = _filterTags;
@synthesize address = _address;


-(UIImageView*)imageView {
    //Allocated from storyboard, don't need to allocate here
    _imageView.layer.cornerRadius = 9;
    _imageView.layer.masksToBounds = YES;
    _imageView.layer.borderColor = [[UIColor blackColor] CGColor];
    _imageView.layer.borderWidth = 1.0;
    
    return _imageView;
}


@end
