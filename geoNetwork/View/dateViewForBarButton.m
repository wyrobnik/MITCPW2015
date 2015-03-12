//
//  dateViewForBarButton.m
//  townbilly
//
//  Created by David Wyrobnik on 1/28/15.
//  Copyright (c) 2015 townbilly. All rights reserved.
//

#import "DateViewForBarButton.h"
#import "UIColor_Extension.h"

@interface DateViewForBarButton ()


@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UIColor *textColor;

@end

@implementation DateViewForBarButton

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat borderWidth = 1.0f;
        self.frame = CGRectInset(self.frame, -3*borderWidth, -3*borderWidth);
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    self.textColor = [UIColor lightTextColor];
    [self setNeedsDisplay];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.textColor = [UIColor whiteColor];
        [self setNeedsDisplay];
    });
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.textColor = [UIColor whiteColor];
        [self setNeedsDisplay];
    });
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    [[UIColor appPrimaryColor] setFill];
    UIRectFill(self.bounds);
    
    CGFloat borderWidth = 1.0f;
    self.layer.borderColor = self.textColor.CGColor;
    self.layer.borderWidth = borderWidth;
    self.layer.cornerRadius = 3.0f;
    
    [self setDate:self.date];
}

- (void)setDate:(NSDate *)date
{
    _date = date;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"dd"];
    NSString *dayFormattedString = [dateFormatter stringFromDate:date];
    
    [dateFormatter setDateFormat:@"MMM"];
    NSString *monthFormattedString = [[dateFormatter stringFromDate:date] uppercaseString];
    
    NSMutableAttributedString *dateString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", dayFormattedString, monthFormattedString]];
    
    [dateString addAttributes:@{
                                NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:12],
                                NSForegroundColorAttributeName: self.textColor
                                }
                        range:NSMakeRange(0, dayFormattedString.length)];
    
    [dateString addAttributes:@{
                                NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:7],
                                NSForegroundColorAttributeName: self.textColor
                                }
                        range:NSMakeRange(dateString.string.length - monthFormattedString.length, monthFormattedString.length)];
    
    self.dateLabel.attributedText = dateString;
}

- (UILabel *)dateLabel
{
    if (!_dateLabel) {
        CGRect bounds = self.bounds;
        bounds.origin.y -= 4;
        bounds.size.height += 6;
        _dateLabel = [[UILabel alloc] initWithFrame:bounds];
        _dateLabel.numberOfLines = 2;
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_dateLabel];
    }
    
    return _dateLabel;
}

- (UIColor*)textColor {
    if (!_textColor)
        _textColor = [UIColor whiteColor];
    return _textColor;
}



@end
