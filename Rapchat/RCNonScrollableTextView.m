//
//  RCNonScrollableTextView.m
//  Rapchat
//
//  Created by Michael Paris on 12/30/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import "RCNonScrollableTextView.h"

@implementation RCNonScrollableTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setScrollEnabled:NO];
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

- (void)scrollViewDidScroll:(id)scrollView
{
    CGPoint origin = [scrollView contentOffset];
    [scrollView setContentOffset:CGPointMake(origin.x, 0.0)];
}

@end
