//
//  RCRoundedImageView.m
//  Rapchat
//
//  Created by Michael Paris on 5/31/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCRoundedImageView.h"

@implementation RCRoundedImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)setup
{
//    self.layer.cornerRadius  = 5.0;
    self.layer.cornerRadius = self.frame.size.width/5;
    self.layer.masksToBounds = YES;
}

- (void)awakeFromNib
{
    [self setup];
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
