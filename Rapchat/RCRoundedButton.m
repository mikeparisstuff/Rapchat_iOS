//
//  RCRoundedButton.m
//  Rapchat
//
//  Created by Michael Paris on 6/19/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCRoundedButton.h"

@implementation RCRoundedButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void) awakeFromNib
{
    [self setup];
}

- (void)setup
{
    //    self.layer.cornerRadius  = 5.0;
    self.layer.cornerRadius = self.frame.size.width/2;
    self.layer.masksToBounds = YES;
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
