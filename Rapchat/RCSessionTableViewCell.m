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

// Complete Sessions
//@property (weak, nonatomic) IBOutlet UIImageView *topLeftThumbnail;
//@property (weak, nonatomic) IBOutlet UIImageView *topRightThumbnail;
//@property (weak, nonatomic) IBOutlet UIImageView *bottomLeftThumbnail;
//@property (weak, nonatomic) IBOutlet UIImageView *bottomRightThumbnail;


@property (weak, nonatomic) IBOutlet UIView *custContentView;

// Freestyles
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;

@end

@implementation RCSessionTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
//        // the space between the image and text
//        CGFloat spacing = 6.0;
//        
//        // lower the text and push it left so it appears centered
//        //  below the image
//        CGSize imageSize = self.likeButton.imageView.frame.size;
//        self.likeButton.titleEdgeInsets = UIEdgeInsetsMake(
//                                                  0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
//        
//        // raise the image and push it right so it appears centered
//        //  above the text
//        CGSize titleSize = self.likeButton.titleLabel.frame.size;
//        self.likeButton.imageEdgeInsets = UIEdgeInsetsMake(
//                                                  - (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
//        
//        imageSize = self.commentButton.imageView.frame.size;
//        self.commentButton.titleEdgeInsets = UIEdgeInsetsMake(
//                                                           0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
//        
//        // raise the image and push it right so it appears centered
//        //  above the text
//        titleSize = self.commentButton.titleLabel.frame.size;
//        self.commentButton.imageEdgeInsets = UIEdgeInsetsMake(
//                                                              - (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
//        [self.custContentView setFrame:CGRectMake(10, 0, 300, 250)];
        [self.custContentView setFrame:CGRectMake(10, 5, 300, 250)];
        UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.custContentView.bounds];
        self.custContentView.layer.masksToBounds = NO;
        self.custContentView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.custContentView.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
        self.custContentView.layer.shadowOpacity = 0.8f;
        self.custContentView.layer.shadowPath = shadowPath.CGPath;
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
//    self.freestyleDateLabel.text = [NSString stringWithFormat:@"%@ %@", [months objectAtIndex:[dateArray[0] intValue]], dateArray[1]];
}

- (void) setHeader
{
    [self.profilePictureImageView setImageWithURL:self.session.creator.profilePictureURL usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
}

- (void) setSessionWaveform:(RCSession *)session
{
    [self.thumbnailImageView setImageWithURL:session.waveformUrl usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.thumbnailImageView.bounds];
    self.thumbnailImageView.layer.masksToBounds = NO;
    self.thumbnailImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.thumbnailImageView.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    self.thumbnailImageView.layer.shadowOpacity = 0.5f;
    self.thumbnailImageView.layer.shadowPath = shadowPath.CGPath;
}


- (void)setCellSession:(RCSession *)session
{
    [self.custContentView setFrame:CGRectMake(10, 5, 300, 250)];
    self.session = session;
    self.likeButton.titleLabel.text = session.title;
    
    NSLog(@"Setting Cell Session that is battle: %@", session.isPrivate);
    [self setSessionWaveform:session];
    [self setHeader];
    
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
