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

@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UILabel *commentsLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) id delegate;

- (void) setCellSession:(RCSession *)session;
- (RCSession *)getCellSession;

@end
