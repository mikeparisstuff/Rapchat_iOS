//
//  RCChooseSongTableViewCell.m
//  Rapchat
//
//  Created by Michael Paris on 6/22/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCChooseSongTableViewCell.h"

@interface RCChooseSongTableViewCell ()

@property (nonatomic) BOOL isPlaying;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;

@end

@implementation RCChooseSongTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [self setup];
}

- (void) setup
{
    self.isPlaying = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)playPauseButton:(id)sender
{
    self.isPlaying = !self.isPlaying;
    if (self.isPlaying) {
        [self.playPauseButton setImage:[UIImage imageNamed:@"ic_play_circ"] forState:UIControlStateNormal];
        [self.delegate pauseButtonTapped];
    } else {
        [self.playPauseButton setImage:[UIImage imageNamed:@"ic_pause_circ"] forState:UIControlStateNormal];
        [self.delegate playButtonTapped];
    }
}

- (void) hideAccessoryButton
{
    [self.playPauseButton setHidden:YES];
}

- (void) showAccessoryButton
{
    [self.playPauseButton setHidden:NO];
}

@end
