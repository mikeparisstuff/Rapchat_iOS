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
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;

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
    
//    [self.thumbnailImageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:session.thumbnailUrl]]];
    
//    [self.thumbnailImageView setImageWithURL:session.thumbnailUrl placeholderImage:[UIImage imageNamed:@"session_placeholder"]];
    [self.thumbnailImageView setImageWithURL:session.thumbnailUrl usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.titleLabel.text = [session.title uppercaseString];
    self.dateLabel.text = [NSString stringWithFormat:@"%@ %@", [months objectAtIndex:[dateArray[0] intValue]], dateArray[1]];
    NSString *likeFormat = ([session.numberOfLikes intValue]==1)? @"  %@ like" : @"  %@ likes";
    self.likesLabel.text = [NSString stringWithFormat:likeFormat, session.numberOfLikes];
    NSString *format = ([session.comments count]==1)? @"  %lu comment" : @"  %lu comments";
    self.commentsLabel.text = [NSString stringWithFormat:format, (unsigned long)[session.comments count]];
    
    
//    // Set title label size
//    UIFont* titleFont = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
//    NSAttributedString *sessionTitle = [[NSAttributedString alloc] initWithString:session.title attributes:@{NSFontAttributeName: titleFont}];
//    CGRect titleFrame = [sessionTitle boundingRectWithSize:CGSizeMake(320, 50) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
//    self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x, self.titleLabel.frame.origin.y, titleFrame.size.width + 50, self.titleLabel.frame.size.height);
//    
//    // Set crowd label size
//    UIFont *crowdFont = [UIFont fontWithName:@"Helvetica Neue" size:14.0f];
//    NSAttributedString *crowdTitle = [[NSAttributedString alloc] initWithString:self.crowdTitleLabel.text attributes:@{NSFontAttributeName: crowdFont}];
//    CGRect crowdFrame = [crowdTitle boundingRectWithSize:CGSizeMake(320, 50) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
//    self.crowdTitleLabel.frame = CGRectMake(self.crowdTitleLabel.frame.origin.x, self.crowdTitleLabel.frame.origin.y, crowdFrame.size.width + 14, self.crowdTitleLabel.frame.size.height);
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
