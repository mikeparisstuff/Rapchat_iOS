//
//  RCRapTableViewCell.m
//  Rapchat
//
//  Created by Michael Paris on 6/29/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCRapTableViewCell.h"
#import "RCAudioRecorderAndPlayer.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "RCAudioRecorderAndPlayer.h"

@interface RCRapTableViewCell ()

@property (nonatomic, strong) RCSession *session;
@property (weak, nonatomic) IBOutlet UIImageView *waveformImageView;
@property (weak, nonatomic) IBOutlet UILabel *sessionTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIView *custContentView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerItem *playerItem;

@end

@implementation RCRapTableViewCell
{
    bool isPlaying;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setupViews
{
    // Add Gesture Recognizers to the waveformImageView
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragged:)];
    [self addGestureRecognizer:recognizer];
    
    [self.waveformImageView setImageWithURL:self.session.waveformUrl usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.sessionTitleLabel setText:self.session.title];
    [self.profilePictureImageView setImageWithURL:self.session.creator.profilePictureURL usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.usernameLabel setText:self.session.creator.user.username];
    
    [self.custContentView.layer setCornerRadius:5.0];
    
    UIBezierPath *waveShadowPath = [UIBezierPath bezierPathWithRect:self.waveformImageView.bounds];
    self.waveformImageView.layer.masksToBounds = NO;
    self.waveformImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.waveformImageView.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    self.waveformImageView.layer.shadowOpacity = 0.8f;
    self.waveformImageView.layer.shadowPath = waveShadowPath.CGPath;
    
    UIBezierPath *contentShadowPath = [UIBezierPath bezierPathWithRect:self.custContentView.bounds];
    self.custContentView.layer.masksToBounds = NO;
    self.custContentView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.custContentView.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    self.custContentView.layer.shadowOpacity = 0.8f;
    self.custContentView.layer.shadowPath = contentShadowPath.CGPath;
}

- (void) prepareToPlayAudio
{
    self.playerItem = [AVPlayerItem playerItemWithURL:self.session.mostRecentClipUrl];
    [self.playerItem addObserver:self forKeyPath:@"status" options:0 context:nil];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
}

- (void) setCellSession:(RCSession *)session
{
    self.session = session;
    isPlaying = NO;
    [self setupViews];
}

- (RCSession *) getCellSession
{
    return self.session;
}

#pragma mark - Listeners
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItem *pItem = (AVPlayerItem *)object;
        if (pItem.status == AVPlayerItemStatusReadyToPlay) {
            // Here you can access to the player item's asset
            // e.g.: self.asset = (AVURLAsset *)pItem.asset;
            NSLog(@"AVPlayerItem is ready to play");
            [self.player play];
        }
    }
}

#pragma mark - Button Actions

- (IBAction)playButtonTapped:(id)sender {
    if (isPlaying) {
        NSLog(@"Pausing Audio at URL: %@", self.session.mostRecentClipUrl);
        [self.player pause];
        [self.playButton setImage:[UIImage imageNamed:@"record_button_play"] forState:UIControlStateNormal];
        isPlaying = NO;
    }
    else {
        NSLog(@"Playing Audio at URL: %@", self.session.mostRecentClipUrl);
        isPlaying = YES;
        [self.playButton setImage:[UIImage imageNamed:@"record_button_pause"] forState:UIControlStateNormal];
        [self prepareToPlayAudio];
    }
}

- (IBAction)commentButtonPressed:(id)sender {
    [self.delegate commentButtonPressedInCell:self];
}

- (IBAction)likeButtonPressed:(id)sender {
    [self.delegate likeButtonPressedInCell:self];
}



@end
