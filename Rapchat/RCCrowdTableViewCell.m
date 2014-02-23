//
//  RCCrowdTableViewCell.m
//  Rapchat
//
//  Created by Michael Paris on 12/14/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import "RCCrowdTableViewCell.h"
#import "RCProfile.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

@interface RCCrowdTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iv1;
@property (weak, nonatomic) IBOutlet UIImageView *iv2;
@property (weak, nonatomic) IBOutlet UIImageView *iv3;
@property (weak, nonatomic) IBOutlet UIImageView *iv4;
@property (weak, nonatomic) IBOutlet UIImageView *iv5;
@property (weak, nonatomic) IBOutlet UIImageView *iv6;
@property (weak, nonatomic) IBOutlet UIImageView *iv7;


@end

@implementation RCCrowdTableViewCell

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
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Call delegate method to go to profile
    if ([self.delegate respondsToSelector:@selector(viewCrowdMembers:)] && selected) {
        [self.delegate viewCrowdMembers:self];
    }
}

- (void)setCrowd:(RCCrowd *)crowd {
    NSArray *imageViews = @[self.iv1, self.iv2, self.iv3, self.iv4, self.iv4, self.iv6, self.iv7];
    self.titleLabel.text = crowd.title;
    self.numberOfMembersLabel.text = [NSString stringWithFormat:@"%lu members", (unsigned long)[crowd.members count]];
    int top = ([crowd.members count] < 7) ? (int)[crowd.members count] : 7;
    for (int i =0; i < top; i++) {
        [(UIImageView *)[imageViews objectAtIndex:i] setImageWithURL:[[crowd.members objectAtIndex:i] profilePictureURL] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    for (int i = top; i < 7; i++) {
        [(UIImageView *)[imageViews objectAtIndex:i] setImage:nil];
    }
    
}

@end
