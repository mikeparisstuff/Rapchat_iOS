//
//  RCSegmentedControl.m
//  Rapchat
//
//  Created by Michael Paris on 1/5/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCSegmentedControl.h"

@implementation RCSegmentedControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

    }
    return self;
}

- (id)initWithItems:(NSArray *)items
{
    self = [super initWithItems:items];
    if (self) {
        // Image between two unselected segments.
        [self setDividerImage:[UIImage imageNamed:@"ic_segment_divider"] forLeftSegmentState:UIControlStateNormal
            rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        // Image between segment selected on the left and unselected on the right.
        [self setDividerImage:[UIImage imageNamed:@"ic_segment_divider"] forLeftSegmentState:UIControlStateSelected
            rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        // Image between segment selected on the right and unselected on the right.
        [self setDividerImage:[UIImage imageNamed:@"ic_segment_divider"] forLeftSegmentState:UIControlStateNormal
            rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(36, 36), NO, 0.0);
        UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [self setBackgroundImage:blank
                        forState:UIControlStateNormal
                      barMetrics:UIBarMetricsDefault];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
