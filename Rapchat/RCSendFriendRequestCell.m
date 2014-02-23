//
//  RCSendFriendRequestCell.m
//  Rapchat
//
//  Created by Michael Paris on 1/5/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCSendFriendRequestCell.h"
#import "RCUrlPaths.h"

@interface RCSendFriendRequestCell ()

@end

@implementation RCSendFriendRequestCell

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
}

- (IBAction)sendFriendRequest:(UIButton *)sender {
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    [objectManager postObject:nil
                         path:myFriendRequestsEndpoint
                   parameters:@{@"username": self.usernameLabel.text}
                      success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                          [self.completeButton setHidden:NO];
                          [self.sendFriendRequestButton setHidden:YES];
                          NSLog(@"Successfully sent friend request");
                      } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                          NSLog(@"Failed to send friend request");
                      }];
}
@end
