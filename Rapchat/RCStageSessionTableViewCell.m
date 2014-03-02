//
//  RCStageSessionTableViewCell.m
//  Rapchat
//
//  Created by Michael Paris on 1/18/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCStageSessionTableViewCell.h"
#import "RCClip.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

@interface RCStageSessionTableViewCell ()

@property (nonatomic) RCSession *session;
@property (weak, nonatomic) IBOutlet UIImageView *topLeftThumbnailView;
@property (weak, nonatomic) IBOutlet UIImageView *topRightThumbnailView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomLeftThumbnailView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomRightThumbnailView;

@end

@implementation RCStageSessionTableViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

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
    NSArray *clips = session.clips;
    for (int i = 0; i < 4; i++) {
        RCClip *clip = clips[i];
        switch (i) {
            case 0:
                [self.topLeftThumbnailView setImageWithURL:clip.thumbnailUrl usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                break;
            case 1:
                [self.topRightThumbnailView setImageWithURL:clip.thumbnailUrl usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                break;
            case 2:
                [self.bottomLeftThumbnailView setImageWithURL:clip.thumbnailUrl usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                break;
            case 3:
                [self.bottomRightThumbnailView setImageWithURL:clip.thumbnailUrl usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                break;
            default:
                break;
        }
    }
    
    self.titleLabel.text = [session.title uppercaseString];
    self.dateLabel.text = [NSString stringWithFormat:@"%@ %@", [months objectAtIndex:[dateArray[0] intValue]], dateArray[1]];
//    self.numberOfMembersLabel.text = [NSString stringWithFormat:@"%d members", (int)[session.crowd.members count]];
//    self.crowdTitleLabel.text = [NSString stringWithFormat:@"Crowd: %@", session.crowd.title];
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

@end
