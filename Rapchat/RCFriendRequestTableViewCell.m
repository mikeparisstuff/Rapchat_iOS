//
//  RCFriendRequestTableViewCell.m
//  Rapchat
//
//  Created by Michael Paris on 1/1/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCFriendRequestTableViewCell.h"
#import "RCUrlPaths.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

@interface RCFriendRequestTableViewCell ()  
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (weak, nonatomic) IBOutlet UIButton *completeButton;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *declineButton;

@end

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

- (void)setFriendRequest:(RCFriendRequest *)request
{
    [self.usernameLabel setText:request.sender.username];
    [self.fullNameLabel setText:[NSString stringWithFormat:@"%@ %@", request.sender.firstName, request.sender.lastName]];
    if (request.sender.profilePictureURL) {
        [self.profilePictureImageView setImageWithURL:request.sender.profilePictureURL
                          usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    [self.completeButton setHidden:YES];
    [self.acceptButton setHidden:NO];
    [self.declineButton setHidden:NO];
}

- (IBAction)acceptFriendRequest:(UIButton *)sender {
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager postObject:nil
                         path:replyToFriendRequestEndpoint
                   parameters:@{@"username": self.usernameLabel.text, @"accepted": @YES}
                                success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                    [self.completeButton setImage:[UIImage imageNamed:@"ic_checkbox_green"] forState:UIControlStateNormal];
                                    [self.completeButton setHidden:NO];
                                    [self.acceptButton setHidden:YES];
                                    [self.declineButton setHidden:YES];
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
                          [self.completeButton setImage:[UIImage imageNamed:@"ic_checkbox_red"] forState:UIControlStateNormal];
                          [self.completeButton setHidden:NO];
                          [self.acceptButton setHidden:YES];
                          [self.declineButton setHidden:YES];
                          NSLog(@"Successfully declined friend request");
                      } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                          NSLog(@"Could not accept that friend request");
                      }];
}
@end
