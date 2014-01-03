//
//  RCFriendRequestTableViewCell.m
//  Rapchat
//
//  Created by Michael Paris on 1/1/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCFriendRequestTableViewCell.h"
#import "RCUrlPaths.h"

@implementation RCFriendRequestTableViewCell

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

- (IBAction)acceptFriendRequest:(UIButton *)sender {
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager postObject:nil
                         path:replyToFriendRequestEndpoint
                   parameters:@{@"username": self.usernameLabel.text, @"accepted": @YES}
                                success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                    NSLog(@"Successfully accepted friend request");
                                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                    NSLog(@"Could not accept that friend request");
                                }];
}

- (IBAction)declineFriendRequest:(UIButton *)sender {
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager postObject:nil
                         path:replyToFriendRequestEndpoint
                   parameters:@{@"username": self.usernameLabel.text, @"accepted": @NO}
                      success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                          NSLog(@"Successfully declined friend request");
                      } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                          NSLog(@"Could not accept that friend request");
                      }];
}
@end
