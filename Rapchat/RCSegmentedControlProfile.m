//
//  RCSegmentedControlProfile.m
//  Rapchat
//
//  Created by Michael Paris on 1/1/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCSegmentedControlProfile.h"

@implementation RCSegmentedControlProfile

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithItems:(NSArray *)items {
    self = [super initWithItems:items];
    if (self) {
        // Initialization code
        
        // Set divider images
        [self setDividerImage:[UIImage imageNamed:@"segment_divider.png"]
          forLeftSegmentState:UIControlStateNormal
            rightSegmentState:UIControlStateNormal
                   barMetrics:UIBarMetricsDefault];
//        [self setDividerImage:[UIImage imageNamed:@"segment_divider.png"]
//          forLeftSegmentState:UIControlStateSelected
//            rightSegmentState:UIControlStateNormal
//                   barMetrics:UIBarMetricsDefault];
//        [self setDividerImage:[UIImage imageNamed:@"segment_divider.png"]
//          forLeftSegmentState:UIControlStateNormal
//            rightSegmentState:UIControlStateSelected
//                   barMetrics:UIBarMetricsDefault];
        
        // Set background images
//        UIImage *normalBackgroundImage = [UIImage imageNamed:@"mySegCtrl-normal-bkgd.png"];
//        [self setBackgroundImage:normalBackgroundImage
//                        forState:UIControlStateNormal
//                      barMetrics:UIBarMetricsDefault];
//        UIImage *selectedBackgroundImage = [UIImage imageNamed:@"mySegCtrl-selected-bkgd.png"];
//        [self setBackgroundImage:selectedBackgroundImage
//                        forState:UIControlStateSelected
//                      barMetrics:UIBarMetricsDefault];
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
