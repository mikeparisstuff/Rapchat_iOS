//
//  RCSendFriendRequestCell.h
//  Rapchat
//
//  Created by Michael Paris on 1/5/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCSendFriendRequestCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *completeButton;
@property (weak, nonatomic) IBOutlet UIButton *sendFriendRequestButton;
@property (weak, nonatomic) IBOutlet UILabel *fullnameLabel;
@property (weak, nonatomic) IBOutlet UILabel *pendingRequestLabel;

- (IBAction)sendFriendRequest:(UIButton *)sender;

@end
