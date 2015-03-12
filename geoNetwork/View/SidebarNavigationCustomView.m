//
//  SidebarNavigationCustomView.m
//  townbilly
//
//  Created by David Wyrobnik on 1/18/15.
//  Copyright (c) 2015 townbilly. All rights reserved.
//


#import "SidebarNavigationCustomView.h"
#import "Settings.h"
#import "UIColor_Extension.h"

//This class really is holding viewcontroller type of classes too! Breaking MVC!
@interface SidebarNavigationCustomView ()

@property (weak, nonatomic) IBOutlet UILabel *firstName;
@property (weak, nonatomic) IBOutlet UILabel *lastName;

@end

@implementation SidebarNavigationCustomView
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
}
*/

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

-(void)customInit {
    
    //add white border bottom
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.backgroundColor = [UIColor grayColor].CGColor;
    bottomBorder.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), 0.5f);
    [self.layer addSublayer:bottomBorder];
    
//    self.settingsButton.tintColor = [UIColor appPrimaryColor];
    
}

-(void)awakeFromNib {
    [self customInit];
}


@end
