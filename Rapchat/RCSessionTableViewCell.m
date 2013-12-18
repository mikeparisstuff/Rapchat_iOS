//
//  RCSessionCell.m
//  Rapchat
//
//  Created by Michael Paris on 12/12/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import "RCSessionTableViewCell.h"

@interface RCSessionTableViewCell ()

@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UILabel *commentsLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (strong, nonatomic) RCSession* session;

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

- (void)setCellSession:(RCSession *)session
{
    self.session = session;
    self.likeButton.titleLabel.text = session.title;
    
    // Set Date
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    NSArray *months = @[@"", @"Jan", @"Feb", @"March", @"Apr", @"May", @"June", @"July", @"Aug", @"Sep",  @"Oct", @"Nov", @"Dec"];
    [dateFormatter setDateFormat:@"MM/dd"];
    NSArray *dateArray = [[dateFormatter stringFromDate:session.created] componentsSeparatedByString:@"/"];
    
    self.titleLabel.text = session.title;
    self.dateLabel.text = [NSString stringWithFormat:@"%@ %@", [months objectAtIndex:[dateArray[0] intValue]], dateArray[1]];
    self.numberOfMembersLabel.text = [NSString stringWithFormat:@"%d members", (int)[session.crowd.members count]];
    self.crowdTitleLabel.text = [NSString stringWithFormat:@"Crowd: %@", session.crowd.title];
    self.likesLabel.text = [NSString stringWithFormat:@"  %@ likes", session.numberOfLikes];
    self.commentsLabel.text = [NSString stringWithFormat:@"  %lu comments", (unsigned long)[session.comments count]];
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
