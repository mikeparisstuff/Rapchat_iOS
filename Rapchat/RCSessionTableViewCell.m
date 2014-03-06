//
//  RCSessionCell.m
//  Rapchat
//
//  Created by Michael Paris on 12/12/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import "RCSessionTableViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

@interface RCSessionTableViewCell ()

@property (strong, nonatomic) RCSession* session;

// Freestyles
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UIView *freestyleHeaderView;
@property (weak, nonatomic) IBOutlet UILabel *freestyleDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *freestyleTitleLabel;

// Battles
@property (weak, nonatomic) IBOutlet UIView *battleHeaderView;
@property (weak, nonatomic) IBOutlet UIImageView *receiverProfilePicture;
@property (weak, nonatomic) IBOutlet UIImageView *creatorProfilePicture;
@property (weak, nonatomic) IBOutlet UILabel *battleDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *battleCreatorUsernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *battleReceiverUsernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *battleTitleLabel;

@end

@implementation RCSessionTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        // the space between the image and text
        CGFloat spacing = 6.0;
        
        // lower the text and push it left so it appears centered
        //  below the image
        CGSize imageSize = self.likeButton.imageView.frame.size;
        self.likeButton.titleEdgeInsets = UIEdgeInsetsMake(
                                                  0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
        
        // raise the image and push it right so it appears centered
        //  above the text
        CGSize titleSize = self.likeButton.titleLabel.frame.size;
        self.likeButton.imageEdgeInsets = UIEdgeInsetsMake(
                                                  - (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
        
        imageSize = self.commentButton.imageView.frame.size;
        self.commentButton.titleEdgeInsets = UIEdgeInsetsMake(
                                                           0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
        
        // raise the image and push it right so it appears centered
        //  above the text
        titleSize = self.commentButton.titleLabel.frame.size;
        self.commentButton.imageEdgeInsets = UIEdgeInsetsMake(
                                                              - (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);

    }
    return self;
}

- (RCSession *)getCellSession
{
    return self.session;
}

- (void)setFreestyleHeaderInfo
{
    // Set Date
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    NSArray *months = @[@"", @"Jan", @"Feb", @"March", @"Apr", @"May", @"June", @"July", @"Aug", @"Sep",  @"Oct", @"Nov", @"Dec"];
    [dateFormatter setDateFormat:@"MM/dd"];
    NSArray *dateArray = [[dateFormatter stringFromDate:self.session.created] componentsSeparatedByString:@"/"];
    self.freestyleDateLabel.text = [NSString stringWithFormat:@"%@ %@", [months objectAtIndex:[dateArray[0] intValue]], dateArray[1]];
    
    [self.freestyleHeaderView setHidden:NO];
    [self.battleHeaderView setHidden:YES];
    self.freestyleTitleLabel.text = [self.session.title uppercaseString];
}

- (void)setBattleHeaderInfo
{
    // Set Date
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    NSArray *months = @[@"", @"Jan", @"Feb", @"March", @"Apr", @"May", @"June", @"July", @"Aug", @"Sep",  @"Oct", @"Nov", @"Dec"];
    [dateFormatter setDateFormat:@"MM/dd"];
    NSArray *dateArray = [[dateFormatter stringFromDate:self.session.created] componentsSeparatedByString:@"/"];
    self.battleDateLabel.text = [NSString stringWithFormat:@"%@ %@", [months objectAtIndex:[dateArray[0] intValue]], dateArray[1]];
    
    // Set Appropriate View visable
    [self.freestyleHeaderView setHidden:YES];
    [self.battleHeaderView setHidden:NO];
    
    // Set Usernames
    [self.battleCreatorUsernameLabel setText:self.session.creator.user.username];
    [self.battleReceiverUsernameLabel setText:self.session.receiver.user.username];
    
    // Set Title
    [self.battleTitleLabel setText:[self.session.title uppercaseString]];
    
    // Set profile pictures
    [self.creatorProfilePicture setImageWithURL:self.session.creator.profilePictureURL usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.receiverProfilePicture setImageWithURL:self.session.receiver.profilePictureURL usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.creatorProfilePicture.layer.cornerRadius  = 5.0;
    self.creatorProfilePicture.layer.masksToBounds = YES;
    self.receiverProfilePicture.layer.cornerRadius  = 5.0;
    self.receiverProfilePicture.layer.masksToBounds = YES;
    
}

- (void)setCellSession:(RCSession *)session
{
    self.session = session;
    self.likeButton.titleLabel.text = session.title;
    
    NSLog(@"Setting Cell Session that is battle: %@", session.isBattle);
    if ([session.isBattle boolValue]) {
        [self setBattleHeaderInfo];
    } else {
        [self setFreestyleHeaderInfo];
    }

    

    [self.thumbnailImageView setImageWithURL:session.thumbnailUrl usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.thumbnailImageView.layer.cornerRadius  = 10.0;
    self.thumbnailImageView.layer.masksToBounds = YES;
    NSString *likeFormat = ([session.numberOfLikes intValue]==1)? @"  %@ like" : @"  %@ likes";
    self.likesLabel.text = [NSString stringWithFormat:likeFormat, session.numberOfLikes];
    NSString *format = ([session.comments count]==1)? @"  %lu comment" : @"  %lu comments";
    self.commentsLabel.text = [NSString stringWithFormat:format, (unsigned long)[session.comments count]];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark Actions
- (IBAction)videoThumbnailButtonClicked:(UIButton *)sender {
    if([[self delegate] respondsToSelector:@selector(playVideoInCell:)]) {
        [[self delegate] playVideoInCell:self];
    }
}

- (IBAction)likeButtonPressed {
    if([[self delegate] respondsToSelector:@selector(likeButtonPressedInCell:)]) {
        [[self delegate] likeButtonPressedInCell:self];
    }
}

- (IBAction)commentButtonPressed:(UIButton *)sender {
    if([[self delegate] respondsToSelector:@selector(commentButtonPressedInCell:)]) {
        [[self delegate] commentButtonPressedInCell:self];
    }
}



@end
