//
//  RCProfileFriendTableViewCell.m
//  Rapchat
//
//  Created by Michael Paris on 12/13/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import "RCFriendTableViewCell.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

@interface RCFriendTableViewCell ()

@property NSString *friendUsername;

@end

@implementation RCFriendTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Call delegate method to go to profile
    if ([self.delegate respondsToSelector:@selector(gotoProfile:)] && selected) {
        [self.delegate gotoProfile:self.usernameLabel.text];
    }
}

#pragma mark - Actions
- (IBAction)battleButtonClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(startBattleWithUsername:)]) {
        [self.delegate startBattleWithUsername:self.friendUsername];
    }
}


#pragma mark - public api
- (void)setFriend:(RCProfile *)friend
{
    [self.usernameLabel setText:friend.user.username];
    self.friendUsername = friend.user.username;
    [self.fullNameLabel setText:[NSString stringWithFormat:@"%@ %@", friend.user.firstName, friend.user.lastName]];
    if (friend.profilePictureURL) {
        [self.profilePictureImageView setImageWithURL:friend.profilePictureURL
                          usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    } else {
        [self.profilePictureImageView setImage:[UIImage imageNamed:@"ic_profile"]];
    }
}

- (NSString *)getFriendsUsername
{
    return self.usernameLabel.text;
}

@end
