//
//  RCProfileFriendTableViewCell.h
//  Rapchat
//
//  Created by Michael Paris on 12/13/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCProfile.h"

@protocol RCFriendCellProtocol <NSObject>

- (void)gotoProfile:(NSString *)username;
- (void)startBattleWithUsername:(NSString *)username;

@end

@interface RCFriendTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) id delegate;
@property (weak, nonatomic) IBOutlet UIButton *battleButton;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;

- (void)setFriend:(RCProfile *)friend;
- (NSString *)getFriendsUsername;
@end
