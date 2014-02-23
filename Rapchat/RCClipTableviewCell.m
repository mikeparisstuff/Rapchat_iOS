//
//  RCClipTableviewCell.m
//  Rapchat
//
//  Created by Michael Paris on 1/12/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCClipTableviewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

@interface RCClipTableviewCell()

@property (nonatomic, strong) RCClip *clip;

@end

@implementation RCClipTableviewCell

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

#pragma mark Methods

- (RCClip *)getCellClip
{
    return self.clip;
}

- (void)setCellClip:(RCClip *)clip
{
    self.clip = clip;
    // Set Date
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    NSArray *months = @[@"", @"Jan", @"Feb", @"March", @"Apr", @"May", @"June", @"July", @"Aug", @"Sep",  @"Oct", @"Nov", @"Dec"];
    [dateFormatter setDateFormat:@"MM/dd"];
    NSArray *dateArray = [[dateFormatter stringFromDate:clip.created] componentsSeparatedByString:@"/"];
    self.dateLabel.text = [NSString stringWithFormat:@"%@ %@", [months objectAtIndex:[dateArray[0] intValue]], dateArray[1]];
    [self.thumbnailImageView setImageWithURL:clip.thumbnailUrl usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
}
- (IBAction)videoThumbnailButtonClicked:(UIButton *)sender {
    if([[self delegate] respondsToSelector:@selector(playVideoInCell:)]) {
        [[self delegate] playVideoInCell:self];
    }
}

@end
