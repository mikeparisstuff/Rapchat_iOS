//
//  RCProgressView.m
//  Rapchat
//
//  Created by Michael Paris on 12/17/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import "RCProgressView.h"

#define fillOffsetX 0
#define fillOffsetTopY 0
#define fillOffsetBottomY 0

@implementation RCProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.progressViewStyle = UIProgressViewStyleBar;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
//    CGSize backgroundStretchPoints = {10, 10};
    CGSize fillStretchPoints = {7, 7};
    
    // Initialize the stretchable images.
//    UIImage *background = [[UIImage imageNamed:@"ic_progress_view_bg"] stretchableImageWithLeftCapWidth:backgroundStretchPoints.width
//                                                                                       topCapHeight:backgroundStretchPoints.height];
    
    UIImage *fill = [[UIImage imageNamed:@"ic_progress_view_top"] stretchableImageWithLeftCapWidth:fillStretchPoints.width
                                                                               topCapHeight:fillStretchPoints.height];
    
    // Draw the background in the current rect
//    [background drawInRect:rect];
    
    // Compute the max width in pixels for the fill.  Max width being how
    // wide the fill should be at 100% progress.
    NSInteger maxWidth = rect.size.width - (2 * fillOffsetX);
    
    // Compute the width for the current progress value, 0.0 - 1.0 corresponding
    // to 0% and 100% respectively.
    NSInteger curWidth = floor([self progress] * maxWidth);
    
    // Create the rectangle for our fill image accounting for the position offsets,
    // 1 in the X direction and 1, 3 on the top and bottom for the Y.
    CGRect fillRect = CGRectMake(rect.origin.x + fillOffsetX,
                                 rect.origin.y + fillOffsetTopY,
                                 curWidth,
                                 rect.size.height - fillOffsetBottomY);
    
    // Draw the fill
    [fill drawInRect:fillRect];
}


@end
