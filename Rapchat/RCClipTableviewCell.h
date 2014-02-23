//
//  RCClipTableviewCell.h
//  Rapchat
//
//  Created by Michael Paris on 1/12/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCClip.h"

@protocol RCClipCellProtocol <NSObject>

- (void)playVideoInCell:(UITableViewCell *)sender;

@end

@interface RCClipTableviewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UIButton *playVideoButton;
@property (weak, nonatomic) id delegate;

- (void) setCellClip:(RCClip *)clip;
- (RCClip *)getCellClip;

@end
