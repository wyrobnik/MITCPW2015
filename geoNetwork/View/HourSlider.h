//
//  HourSlider.h
//  MIT CPW 2015
//
//  Created by David Wyrobnik on 3/16/15.
//  Copyright (c) 2015 townbilly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HourSlider : UIView

@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (strong, nonatomic) NSString *valueTime;

+ (instancetype)loadFromNib;

@end
