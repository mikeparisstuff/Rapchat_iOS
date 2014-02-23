//
//  RCFriendRequestTableViewCell.h
//  Rapchat
//
//  Created by Michael Paris on 1/1/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCFriendRequest.h"

@interface RCFriendRequestTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;


- (void)setFriendRequest:(RCFriendRequest *)request;
@end
