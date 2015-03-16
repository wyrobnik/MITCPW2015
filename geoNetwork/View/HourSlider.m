//
//  HourSlider.m
//  MIT CPW 2015
//
//  Created by David Wyrobnik on 3/16/15.
//  Copyright (c) 2015 townbilly. All rights reserved.
//

#import "HourSlider.h"
@interface HourSlider ()
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation HourSlider

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (instancetype)loadFromNib {
    HourSlider *view = nil;
    NSArray *arr = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    if ([arr count] > 0) {
        view = arr[0];
    
        //TODO fix, hacky!
        CGRect rect = view.label.frame;
        view.label.frame = CGRectMake(rect.origin.x, 13, rect.size.width, rect.size.height);
        
        [view.slider addTarget:view action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
        [view sliderValueChanged]; //init
    }
    return view;
}
         
 -(void)sliderValueChanged {
     NSString *amOrPm;
     if ((int)self.slider.value >= 12 && (int)self.slider.value < 24) {
         amOrPm = @"PM";
     } else {
         amOrPm = @"AM";
     }
     int hour = (int)self.slider.value%12;
     hour = hour == 0 ? 12 : hour;  //So that 12 am and pm is displayed correctly
     
     [self setValueTime:[NSString stringWithFormat:@"%i:00 %@", hour, amOrPm]];
 }

-(void)setValueTime:(NSString *)valueTime {
    _valueTime = valueTime;
    self.label.text = _valueTime;
}


@end
