//
//  RCSessionCell.h
//  Rapchat
//
//  Created by Michael Paris on 12/12/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCSession.h"

@protocol RCSessionCellProtocol <NSObject>

- (void)likeButtonPressedInCell:(UITableViewCell *)sender;
- (void)commentButtonPressedInCell:(UITableViewCell *)sender;
- (void)playVideoInCell:(UITableViewCell *)sender;

@end

@interface RCSessionTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfMembersLabel;
@property (weak, nonatomic) IBOutlet UILabel *crowdTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *likesButton;
@property (weak, nonatomic) IBOutlet UIButton *commentsButton;
@property (weak, nonatomic) id delegate;

- (void) setCellSession:(RCSession *)session;
- (RCSession *)getCellSession;

@end
