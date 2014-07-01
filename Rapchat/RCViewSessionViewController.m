//
//  RCViewSessionViewController.m
//  Rapchat
//
//  Created by Michael Paris on 1/14/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCViewSessionViewController.h"
#import "RCCommentsViewController.h"
#import "RCFilePlayerView.h"
#import "RCClip.h"
#import "RCUrlPaths.h"
#import "RCUtility.h"
#import <SVProgressHUD.h>
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import <AVFoundation/AVFoundation.h>
#import "RCVoteCount.h"


static const NSString *ItemStatusContext;
static const NSString *ItemPlaybackLikelyToKeepUpContext;

@interface RCViewSessionViewController ()

// RCFilePlayer properties
@property (nonatomic) AVPlayer *player;
@property (nonatomic) AVPlayerItem *playerItem;
@property (weak, nonatomic) IBOutlet RCFilePlayerView *playerView;

@property (nonatomic) NSArray *videoClips;
@property (nonatomic) NSMutableDictionary *videoAssets;
//@property (nonatomic) NSMutableArray *videoAssets;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;

// Battles
@property (nonatomic) UILabel *roundTitleView;
@property (nonatomic) UILabel *creatorUsernameLabel;
@property (nonatomic) UIImageView *creatorImageView;
@property (nonatomic) UILabel *receiverUsernameLabel;
@property (nonatomic) UIImageView *receiverImageView;
@property (nonatomic) BOOL isCreatorsTurn;

// Battle Voting
@property (nonatomic) UIImageView *voteForCreatorIV;
@property (nonatomic) UIImageView *voteForReceiverIV;
@property (nonatomic) UIView *dragHereToVoteView;
@property (nonatomic) UILabel *votingTitleLabel;
@property (nonatomic) UILabel *creatorVoteCountLabel;
@property (nonatomic) UILabel *receiverVoteCountLabel;
@property (nonatomic) BOOL votingViewsPresent;

@end

typedef enum : NSUInteger
{
    VoteForStateCreator         = 1,
    VoteForStateReceiver        = 2
} VoteForState;

@implementation RCViewSessionViewController
{
    int currentVideoIndex;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.navigationController.navigationBar setTranslucent:YES];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSLog(@"Has Voted on this session: %d", self.has_been_voted_on);
    
    currentVideoIndex = 1;
    self.isCreatorsTurn = YES;
    [self setupBattleViews];
    [self setTitle:self.session.title];
    
    // Setup button sizes
    if ([RCUtility hasIphone5Screen]) {
        [self.likeButton setFrame:CGRectMake(self.likeButton.frame.origin.x, self.likeButton.frame.origin.y, self.likeButton.frame.size.width, 96)];
        [self.commentButton setFrame:CGRectMake(self.commentButton.frame.origin.x, self.commentButton.frame.origin.y, self.commentButton.frame.size.width, 96)];
    } else {
        [self.likeButton setFrame:CGRectMake(self.likeButton.frame.origin.x, self.likeButton.frame.origin.y, self.likeButton.frame.size.width, 48)];
        [self.commentButton setFrame:CGRectMake(self.commentButton.frame.origin.x, self.commentButton.frame.origin.y, self.commentButton.frame.size.width, 48)];
    }
    
    if (self.has_been_voted_on) {
        [self showVoteCount:self.voteCount];
    }
    self.votingViewsPresent = NO;
    
    //    // Create the AVPlayer
    //    AVPlayer *player = [[AVPlayer alloc] init];
    //    [self setPlayer:player];
    //
    //    // Setup the previewView to play the file
    //    [[self playerView] setPlayer:player];
    //    dispatch_queue_t playerQueue = dispatch_queue_create("player queue", DISPATCH_QUEUE_SERIAL);
    //    [self setPlayerQueue:playerQueue];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"RCViewSessionViewController will appear");
    [super viewWillAppear:animated];
    self.videoClips = self.session.clips;
    if (self.sessionIsLiked) {
        [self.likeButton setSelected:YES];
    } else {
        [self.likeButton setSelected:NO];
    }
    [self loadVideoAssetsAsynchronously];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(disableFrontPanning)];
//    [self playNextClip];
    
//    [self playNextClip];
    
//    [self loadClips];
//    [self loadAssetFromFile];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //    [[NSFileManager defaultManager] removeItemAtPath:[self.thumbnailImageUrl absoluteString] error:nil];
    [self.player pause];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(enableFrontPanning)];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:[self.player currentItem]];
    @try{
        [self.playerItem removeObserver:self forKeyPath:@"status"];
    }@catch(id anException){
        //do nothing, obviously it wasn't attached because an exception was thrown
    }
    @try{
        [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    }@catch(id anException){
        //do nothing, obviously it wasn't attached because an exception was thrown
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark Battle Work
- (void)setupBattleViews
{
    if ([self.session.isPrivate boolValue]) {
        [self.roundTitleView setTextColor:[UIColor whiteColor]];
        [self.roundTitleView setTextAlignment:NSTextAlignmentCenter];
        [self.roundTitleView setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:22.0f]];
        [self.creatorUsernameLabel setTextColor:[UIColor whiteColor]];
        [self.creatorUsernameLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:17.0f]];
        [self.receiverUsernameLabel setTextColor:[UIColor whiteColor]];
        [self.receiverUsernameLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:17.0f]];
        [self.playerView addSubview:self.roundTitleView];
        [self.playerView addSubview:self.creatorImageView];
        [self.playerView addSubview:self.receiverImageView];
        [self.playerView addSubview:self.creatorUsernameLabel];
        [self.playerView addSubview:self.receiverUsernameLabel];
        [self updateBattleInfo];
    }
}
- (void)updateBattleInfo
{
    if ([self.session.isPrivate boolValue]) {
        [self setCurrentRoundTitle];
    }
}

- (void) setCurrentRoundTitle
{
    int roundNum = ((currentVideoIndex-1) / 2) + 1;
    NSLog(@"Setting to round %d", roundNum);
    [self.roundTitleView setText:[NSString stringWithFormat:@"ROUND %d", roundNum]];
}

- (void)toggleCreatorReceiverImageViews
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    if (self.isCreatorsTurn) {
        NSLog(@"Showing Receiver");
        
        // Animate ImageViews
        CGRect creatorIVFrame = CGRectMake(self.creatorImageView.frame.origin.x-(self.creatorImageView.frame.size.width + 10), self.creatorImageView.frame.origin.y, self.creatorImageView.frame.size.width, self.creatorImageView.frame.size.height);
        [self.creatorImageView setFrame:creatorIVFrame];
        [self.creatorImageView setAlpha:0.0f];
        CGRect receiverIVFrame = CGRectMake(self.receiverImageView.frame.origin.x-(self.receiverImageView.frame.size.width + 10), self.receiverImageView.frame.origin.y, self.receiverImageView.frame.size.width, self.receiverImageView.frame.size.height);
        [self.receiverImageView setFrame:receiverIVFrame];
        [self.receiverImageView setAlpha:1.0f];
        
        // Animate Username Labels
        CGRect creatorUNameFrame = CGRectMake(self.creatorUsernameLabel.frame.origin.x-(self.creatorImageView.frame.size.width+10), self.creatorUsernameLabel.frame.origin.y, self.creatorUsernameLabel.frame.size.width, self.creatorUsernameLabel.frame.size.height);
        [self.creatorUsernameLabel setFrame:creatorUNameFrame];
        [self.creatorUsernameLabel setAlpha:0.0f];
        CGRect receiverUNameFrame = CGRectMake(self.receiverUsernameLabel.frame.origin.x-(self.receiverImageView.frame.size.width+10), self.receiverUsernameLabel.frame.origin.y, self.receiverUsernameLabel.frame.size.width, self.receiverUsernameLabel.frame.size.height);
        [self.receiverUsernameLabel setFrame:receiverUNameFrame];
        [self.receiverUsernameLabel setAlpha:1.0f];
        
        self.isCreatorsTurn = NO;
    } else {
        NSLog(@"Showing Creator");
        
        // Animate ImageViews
        CGRect creatorIVFrame = CGRectMake(self.creatorImageView.frame.origin.x+(self.creatorImageView.frame.size.width+10), self.creatorImageView.frame.origin.y, self.creatorImageView.frame.size.width, self.creatorImageView.frame.size.height);
        [self.creatorImageView setFrame:creatorIVFrame];
        [self.creatorImageView setAlpha:1.0f];
        CGRect receiverIVFrame = CGRectMake(self.receiverImageView.frame.origin.x+(self.receiverImageView.frame.size.width+10), self.receiverImageView.frame.origin.y, self.receiverImageView.frame.size.width, self.receiverImageView.frame.size.height);
        [self.receiverImageView setFrame:receiverIVFrame];
        [self.receiverImageView setAlpha:0.0f];
        
        // Animate Username Labels
        CGRect creatorUNameFrame = CGRectMake(self.creatorUsernameLabel.frame.origin.x+(self.creatorImageView.frame.size.width+10), self.creatorUsernameLabel.frame.origin.y, self.creatorUsernameLabel.frame.size.width, self.creatorUsernameLabel.frame.size.height);
        [self.creatorUsernameLabel setFrame:creatorUNameFrame];
        [self.creatorUsernameLabel setAlpha:1.0f];
        CGRect receiverUNameFrame = CGRectMake(self.receiverUsernameLabel.frame.origin.x+(self.receiverImageView.frame.size.width+10), self.receiverUsernameLabel.frame.origin.y, self.receiverUsernameLabel.frame.size.width, self.receiverUsernameLabel.frame.size.height);
        [self.receiverUsernameLabel setFrame:receiverUNameFrame];
        [self.receiverUsernameLabel setAlpha:0.0f];
        
        self.isCreatorsTurn = YES;
    }
    [UIView commitAnimations];
    
}

#pragma mark - Voting Helpers

- (void)setupVotingViews
{
//    CGRect cbFrame = CGRectMake(0, self.view.frame.size.height-96, self.view.frame.size.width/2, self.view.frame.size.height/6 );
//    UIButton *voteForCreatorButton = [[UIButton alloc] initWithFrame:cbFrame];
//    [self.view addSubview:self.dragHereToVoteView];
    [self.view addSubview:self.voteForCreatorIV];
    [self.view addSubview:self.voteForReceiverIV];
    [self.view addSubview:self.votingTitleLabel];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.voteForCreatorIV.center = CGPointMake(40, self.view.frame.size.height-50);
        self.voteForReceiverIV.center = CGPointMake(self.view.frame.size.width-40, self.view.frame.size.height-50);
//        self.dragHereToVoteView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height-50);
        self.votingTitleLabel.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height-50);
    }];
    
    self.votingViewsPresent = YES;
    
//    [voteForCreatorButton setTitle:@"Vote for Creator" forState:UIControlStateNormal];
//    [voteForCreatorButton setImage:[self.creatorImageView image] forState:UIControlStateNormal];
//    CGRect rbFrame = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height-96, self.view.frame.size.width/2, self.view.frame.size.height/6);
//    UIButton *voteForReceiverButton = [[UIButton alloc] initWithFrame:rbFrame];
//    [voteForReceiverButton setTitle:@"Vote for Receiver" forState:UIControlStateNormal];
//    [voteForReceiverButton setImage:[self.receiverImageView image] forState:UIControlStateNormal];
//    
//    [self.view addSubview:voteForCreatorButton];
//    [self.view addSubview:voteForReceiverButton];
}

- (void)voteCreatorTapDetected
{
    NSLog(@"Voting for creator");
    [self castVoteFor:VoteForStateCreator];
}

- (void)voteReceiverTapDetected
{
    NSLog(@"Voting for receiver");
    [self castVoteFor:VoteForStateReceiver];
}

- (void)castVoteFor:(VoteForState)state
{
    NSString *username = nil;
    if (state == VoteForStateCreator) {
        username = self.session.creator.user.username;
    } else if (state == VoteForStateReceiver) {
        username = self.session.receiver.user.username;
    }
    
    // Make the api request
    if (username != nil) {
        RKObjectManager *objectManager = [RKObjectManager sharedManager];
        [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"Shouting out to %@", username] maskType:SVProgressHUDMaskTypeGradient];
        [objectManager postObject:nil
                             path:[NSString stringWithFormat:@"sessions/%@/votes/", self.session.sessionId]
                       parameters:@{@"voted_for": username}
                          success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                              NSLog(@"Successfully voted for %@", username);
                              RCVoteCount *voteCount = [mappingResult firstObject];
                              NSLog(@"Count: %@", voteCount);
                              [SVProgressHUD showSuccessWithStatus:@"Success"];
                              [self showVoteCount:voteCount];
                          } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                              NSLog(@"Failed to vote for %@", username);
                              [SVProgressHUD showErrorWithStatus:@"Unable to cast vote"];
                          }];
    }
    
}

- (void)showVoteCount:(RCVoteCount *)voteCount
{
    CGRect frame = CGRectMake(0, 0, 50, 50);
    self.creatorVoteCountLabel = [[UILabel alloc] initWithFrame:frame];
    self.creatorVoteCountLabel.center = CGPointMake(50, self.view.frame.size.height-50);
    [self.creatorVoteCountLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:30.0]];
    [self.creatorVoteCountLabel setTextAlignment:NSTextAlignmentCenter];
    self.receiverVoteCountLabel = [[UILabel alloc] initWithFrame:frame];
    self.receiverVoteCountLabel.center = CGPointMake(self.view.frame.size.width-50, self.view.frame.size.height-50);
    [self.receiverVoteCountLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:30.0]];
    [self.receiverVoteCountLabel setTextAlignment:NSTextAlignmentCenter];
    if (voteCount.votesForCreator > voteCount.votesForReceiver) {
        [self.creatorVoteCountLabel setTextColor:[UIColor greenColor]];
        [self.receiverVoteCountLabel setTextColor:[UIColor redColor]];
    } else if (voteCount.votesForReceiver > voteCount.votesForCreator) {
        [self.creatorVoteCountLabel setTextColor:[UIColor redColor]];
        [self.receiverVoteCountLabel setTextColor:[UIColor greenColor]];
    } else {
        [self.creatorVoteCountLabel setTextColor:[UIColor whiteColor]];
        [self.receiverVoteCountLabel setTextColor:[UIColor whiteColor]];
    }
    NSLog(@"Vote Count: %@, %@", voteCount.votesForCreator, voteCount.votesForReceiver);
    [self.creatorVoteCountLabel setText:[NSString stringWithFormat:@"%@", voteCount.votesForCreator]];
    [self.receiverVoteCountLabel setText:[NSString stringWithFormat:@"%@", voteCount.votesForReceiver]];
    [self.voteForCreatorIV setAlpha:0.0];
    [self.voteForReceiverIV setAlpha:0.0];
    self.votingTitleLabel.hidden = NO;
    self.votingTitleLabel.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height-50);
    [self.votingTitleLabel setText:@"-  SCORE  -"];
    [self.view addSubview:self.votingTitleLabel];
    [self.view addSubview:self.creatorVoteCountLabel];
    [self.view addSubview:self.receiverVoteCountLabel];
}

- (void)handleCreatorPan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self.view];
    
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        // Check here for the position of the view when the user stops touching the screen
        
        // Set "CGFloat finalX" and "CGFloat finalY", depending on the last position of the touch
        
        // Use this to animate the position of your view to where you want
        CGPoint velocity = [recognizer velocityInView:self.view];
        CGFloat magnitude = sqrtf((velocity.x * velocity.x) + (velocity.y * velocity.y));
        CGFloat slideMult = magnitude / 200;
        
        float slideFactor = 0.1 * slideMult; // Increase for more slide
        [UIView animateWithDuration: 1.0
                              delay: 0
                            options: UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             CGPoint finalPoint = CGPointMake(40, self.view.frame.size.height-40);
                             recognizer.view.center = finalPoint; }
                         completion:nil];
    }
    
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
}

- (void)handleReceiverPan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self.view];
    
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        // Check here for the position of the view when the user stops touching the screen
        
        // Set "CGFloat finalX" and "CGFloat finalY", depending on the last position of the touch
        
        // Use this to animate the position of your view to where you want
        CGPoint velocity = [recognizer velocityInView:self.view];
        CGFloat magnitude = sqrtf((velocity.x * velocity.x) + (velocity.y * velocity.y));
        CGFloat slideMult = magnitude / 200;
        
        float slideFactor = 0.1 * slideMult; // Increase for more slide
        [UIView animateWithDuration: 1.0
                              delay: 0
                            options: UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             CGPoint finalPoint = CGPointMake(self.view.frame.size.width-40, self.view.frame.size.height-40);
                             recognizer.view.center = finalPoint; }
                         completion:nil];
    }
    
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
}

#pragma mark API Calls
- (void)loadClips
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager getObjectsAtPath:[NSString stringWithFormat:@"/sessions/%@/clips/", self.session.sessionId]
                         parameters:nil
                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                NSLog(@"Got Clips");
                                self.videoClips = [mappingResult array];
                                [self playNextClip];
                            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                NSLog(@"Error loading clips: %@", error);
                            }];
}

#pragma mark File Player

//- (void)syncUI
//{
//    if ((self.player.currentItem != nil) && ([self.player.currentItem status] == AVPlayerItemStatusReadyToPlay)) {
//        self.nextButton.enabled = YES;
//    } else {
//        self.nextButton.enabled = NO;
//    }
//}

- (void)prepareToPlayNextAsset
{
    NSLog(@"Playing clip number: %d", currentVideoIndex);
    AVAsset *asset = [self.videoAssets objectForKey:[NSNumber numberWithInt:currentVideoIndex]];
    // Update battle info.. Only occurs if the session is a battle
    [self updateBattleInfo];
    if (!asset.playable) {
        return;
    }
    if (self.playerItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.playerItem];
        @try{
            [self.playerItem removeObserver:self forKeyPath:@"status"];
        }@catch(id anException){
            //do nothing, obviously it wasn't attached because an exception was thrown
        }
        @try{
            [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        }@catch(id anException){
            //do nothing, obviously it wasn't attached because an exception was thrown
        }
        
//        [self.playerItem removeObserver:self forKeyPath:@"status"];
//        [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                        name:AVPlayerItemDidPlayToEndTimeNotification
//                                                      object:self.playerItem];
    }
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    [self.playerItem addObserver:self forKeyPath:@"status"
                         options:NSKeyValueObservingOptionInitial |
     NSKeyValueObservingOptionNew
                         context:nil];
    [self.playerItem addObserver:self
                      forKeyPath:@"playbackLikelyToKeepUp"
                         options:0
                         context:&ItemPlaybackLikelyToKeepUpContext];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.player currentItem]];
    if (![self player]) {
        // Set the asset to the waveform generator
        
        [self setPlayer:[AVPlayer playerWithPlayerItem:self.playerItem]];
        [self.player addObserver:self forKeyPath:@"currentItem"
                         options:NSKeyValueObservingOptionInitial |
         NSKeyValueObservingOptionNew
                         context:nil];
    }
    if (self.player.currentItem != self.playerItem) {
        [[self player] replaceCurrentItemWithPlayerItem:self.playerItem];
    }
}

- (void)loadVideoAssetsAsynchronously
{
    NSLog(@"Video Clips: %@", self.videoClips);
    for (RCClip *clip in self.videoClips) {
        NSLog(@"Loading new asset from url: %@", clip.url);
        NSURL *fileUrl = clip.url;
        AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:fileUrl options:nil];
        NSString *tracksKey = @"tracks";
        [videoAsset loadValuesAsynchronouslyForKeys:@[tracksKey]
                                  completionHandler:^{
                                      // Completion block
                                      dispatch_async(dispatch_get_main_queue(),
                                                     ^{
                                                         NSLog(@"Loading Video on Async Thread");
                                                         NSError *error;
                                                         AVKeyValueStatus status = [videoAsset statusOfValueForKey:tracksKey
                                                                                                             error:&error];
                                                         if (status == AVKeyValueStatusLoaded) {
                                                             
                                                             NSLog(@"Status is of type ABKeyValueStatusLoaded");
                                                             NSLog(@"Loaded Video with count: %@", clip.clipNumber);
//                                                            [self.videoAssets addObject:videoAsset];
                                                             [self.videoAssets setObject:videoAsset forKey:clip.clipNumber];
                                                             [self prepareToPlayNextAsset];
                                                             
//                                                             self.playerItem = [AVPlayerItem playerItemWithAsset:videoAsset];
//                                                             [self.playerItem addObserver:self
//                                                                               forKeyPath:@"status"
//                                                                                  options:0
//                                                                                  context:&ItemStatusContext];
//                                                             [self.playerItem addObserver:self
//                                                                               forKeyPath:@"playbackLikelyToKeepUp"
//                                                                                  options:0
//                                                                                  context:&ItemPlaybackLikelyToKeepUpContext];
//                                                             self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
//                                                             self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
//                                                             [[NSNotificationCenter defaultCenter] addObserver:self
//                                                                                                      selector:@selector(playerItemDidReachEnd:)
//                                                                                                          name:AVPlayerItemDidPlayToEndTimeNotification
//                                                                                                        object:[self.player currentItem]];
//                                                             [self.playerView setPlayer:self.player];
//                                                             NSLog(@"Would Be Playing");
                                                             
                                                             //                                                         [self.player play];
                                                         } else {
                                                             // Deal with the error
                                                             NSLog(@"The asset's tracks were not loaded: \n%@", [error localizedDescription]);
                                                         }
                                                         
                                                     });
                                  }];
    }
}


#pragma mark - Video Actions

- (void)playNextClip
{
    RCClip *clip = (RCClip *)[self.videoClips objectAtIndex:currentVideoIndex];
    [self loadAssetFromFileWithUrl:clip.url];
    currentVideoIndex = (currentVideoIndex+1)%[self.videoClips count];
}

- (void)loadAssetFromFileWithUrl:(NSURL *)url
{
    NSLog(@"loadAssetFromFile called");
    AVURLAsset *videoAsset = nil;
    NSLog(@"CurrentVideoIndex: %d, PlayerItems Count: %lu",currentVideoIndex, (unsigned long)[self.videoAssets count]);
//    if (currentVideoIndex < [self.videoAssets count]) {
    
    if ( [[self.videoAssets allKeys] containsObject:[NSNumber numberWithInt:currentVideoIndex] ] ) {
    
        NSLog(@"Video Assets contains asset for key %@", [NSNumber numberWithInt:currentVideoIndex]);
        videoAsset = [self.videoAssets objectForKey:[NSNumber numberWithInt:currentVideoIndex]];
//        self.playerItem = [AVPlayerItem playerItemWithAsset:self.videoAssets[currentVideoIndex]];
        self.playerItem = [AVPlayerItem playerItemWithAsset:videoAsset];
        
        [self.playerItem addObserver:self
                          forKeyPath:@"status"
                             options:0
                             context:&ItemStatusContext];
        [self.playerItem addObserver:self
                          forKeyPath:@"playbackLikelyToKeepUp"
                             options:0
                             context:&ItemPlaybackLikelyToKeepUpContext];
        [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
        self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        
        [self.playerView setPlayer:self.player];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[self.player currentItem]];
    
    } else {
        NSLog(@"Video Asset did not yet contain value for key: %@", [NSNumber numberWithInt:currentVideoIndex]);
    }

//    else {
//        NSLog(@"Loading new asset from url");
//        NSURL *fileUrl = url;
//        videoAsset = [AVURLAsset URLAssetWithURL:fileUrl options:nil];
//        NSString *tracksKey = @"tracks";
//        [videoAsset loadValuesAsynchronouslyForKeys:@[tracksKey]
//                                  completionHandler:^{
//                                      // Completion block
//                                      dispatch_async(dispatch_get_main_queue(),
//                                                     ^{
//                                                         NSLog(@"Loading Video on Async Thread");
//                                                         NSError *error;
//                                                         AVKeyValueStatus status = [videoAsset statusOfValueForKey:tracksKey
//                                                                                                             error:&error];
//                                                         if (status == AVKeyValueStatusLoaded) {
//                                                             
//                                                             NSLog(@"Status is of type ABKeyValueStatusLoaded");
//                                                             self.playerItem = [AVPlayerItem playerItemWithAsset:videoAsset];
//                                                             [self.videoAssets addObject:videoAsset];
//                                                             [self.playerItem addObserver:self
//                                                                               forKeyPath:@"status"
//                                                                                  options:0
//                                                                                  context:&ItemStatusContext];
//                                                             [self.playerItem addObserver:self
//                                                                               forKeyPath:@"playbackLikelyToKeepUp"
//                                                                                  options:0
//                                                                                  context:&ItemPlaybackLikelyToKeepUpContext];
//                                                             self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
//                                                             self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
//                                                             [[NSNotificationCenter defaultCenter] addObserver:self
//                                                                                                      selector:@selector(playerItemDidReachEnd:)
//                                                                                                          name:AVPlayerItemDidPlayToEndTimeNotification
//                                                                                                        object:[self.player currentItem]];
//                                                             [self.playerView setPlayer:self.player];
//                                                             NSLog(@"Would Be Playing");
//                                                             //                                                         [self.player play];
//                                                         } else {
//                                                             // Deal with the error
//                                                             NSLog(@"The asset's tracks were not loaded: \n%@", [error localizedDescription]);
//                                                         }
//                                                         
//                                                     });
//                                  }];
//    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:
                                  NSKeyValueChangeNewKey] integerValue];
        if (status == AVPlayerStatusReadyToPlay) {
            [self.player play];
        }
        return;
	}
    if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        //        NSLog(@"Playback likely to keep up");
        if (self.playerItem.playbackLikelyToKeepUp == YES) {
            [self.player play];
        } else {
            [self.player pause];
        }
        return;
    }
    if ([keyPath isEqualToString:@"currentItem"]) {
        AVPlayerItem *newPlayerItem = [change objectForKey:
                                       NSKeyValueChangeNewKey];
        
        if (newPlayerItem) {
            [self.playerView setPlayer:self.player];
        }
        return;
	}
    [super observeValueForKeyPath:keyPath ofObject: object
                               change:change context:context];
    return;
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
//                        change:(NSDictionary *)change context:(void *)context {
//    if ([keyPath isEqualToString:@"status"]) {
//        if (self.player.status == AVPlayerStatusReadyToPlay) {
//            //            playButton.enabled = YES;
//            
//            //            while (CMTimeGetSeconds([[self.playerItem.loadedTimeRanges objectAtIndex:0] CMTimeRangeValue].duration) < 3) {
//            //                NSLog(@"Loaded time ranges: %f", CMTimeGetSeconds([[self.playerItem.loadedTimeRanges objectAtIndex:0] CMTimeRangeValue].duration));
//            //            }
//            //            [self.player play];
//            NSLog(@"Player ready to play");
//        } else if (self.player.status == AVPlayerStatusFailed) {
//            // something went wrong. player.error should contain some information
//            NSLog(@"Player Failed");
//        }
//    }
//    if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
//        //        NSLog(@"Playback likely to keep up");
//        if (self.playerItem.playbackLikelyToKeepUp == YES) {
//            [self.player play];
//        } else {
//            [self.player pause];
//        }
//    }
//
//    if (context == &ItemStatusContext) {
//        NSLog(@"Item Status Context Change");
//        //        dispatch_async(dispatch_get_main_queue(),
//        //                       ^{
//        //                           NSLog(@"Status changed.");
//        ////                           [self syncUI];
//        //                       });
//        return;
//    }
//    if (context == &ItemPlaybackLikelyToKeepUpContext) {
//        NSLog(@"Item Playback likely to keep up context change");
//        return;
//    }
//    [super observeValueForKeyPath:keyPath ofObject:object
//                           change:change context:context];
//    return;
//}


- (void)playerItemDidReachEnd:(NSNotification *)notification {
//    [self.player seekToTime:kCMTimeZero];
    // Remove the observer on the current item because we reallocate them when we start playing them
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:[self.player currentItem]];
    currentVideoIndex = (currentVideoIndex+1)%([self.videoClips count]+1);
    if (currentVideoIndex == 0 && [self.session.isPrivate boolValue]) {
        if (!self.votingViewsPresent && !self.has_been_voted_on) {
            [self setupVotingViews];
        }
        currentVideoIndex = 1;
    }
    NSLog(@"Current Video: %d", currentVideoIndex);
    [self toggleCreatorReceiverImageViews];
    [self prepareToPlayNextAsset];
//    [self playNextClip];
    //    [self.player play];
}

#pragma mark Actions
- (IBAction)likeButtonPressed:(UIButton *)sender {
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [SVProgressHUD showWithStatus:@"HOLD UP!" maskType:SVProgressHUDMaskTypeClear];
    [objectManager postObject:nil
                         path:myLikesEndpoint
                   parameters:@{@"session":self.session.sessionId}
                   success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                       [SVProgressHUD showSuccessWithStatus:@"Success"];
                       if (operation.HTTPRequestOperation.response.statusCode == 201) {
                           [self.likeButton setSelected:YES];
                       } else {
                           [self.likeButton setSelected:NO];
                       }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Error"];
        NSLog(@"Failed to toggle like");
    }];

}


#pragma mark Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"GoToCommentsSegue"]) {
        RCCommentsViewController *RCtvc = segue.destinationViewController;
        RCtvc.comments = self.session.comments;
        RCtvc.sessionId = self.session.sessionId;
        NSLog(@"Prepared GoToCommentsSegue");
    }
}


#pragma mark Getters
//- (NSMutableArray *)videoAssets
//{
//    if (!_videoAssets) {
//        _videoAssets = [[NSMutableArray alloc] init];
//    }
//    return _videoAssets;
//}

- (NSMutableDictionary *)videoAssets {
    if (!_videoAssets) {
        _videoAssets = [[NSMutableDictionary alloc] init];
    }
    return _videoAssets;
}

- (UILabel *)roundTitleView
{
    if (!_roundTitleView) {
        CGRect  frame = CGRectMake(self.playerView.frame.size.width/2-75, 25, 150, 45);
        _roundTitleView = [[UILabel alloc] initWithFrame:frame];
    }
    return _roundTitleView;
}

- (UIImageView *)creatorImageView
{
    if (!_creatorImageView) {
        CGRect frame = CGRectMake(10, 25, 60, 60);
        _creatorImageView = [[UIImageView alloc] initWithFrame:frame];
        [_creatorImageView setImageWithURL:self.session.creator.profilePictureURL placeholderImage:[UIImage imageNamed:@"ic_profile"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _creatorImageView.layer.cornerRadius  = 5.0;
        _creatorImageView.layer.masksToBounds = YES;
    }
    return _creatorImageView;
}

- (UIImageView *)receiverImageView
{
    if (!_receiverImageView) {
        CGRect frame = CGRectMake(self.view.frame.size.width, 25, 60, 60);
        _receiverImageView = [[UIImageView alloc] initWithFrame:frame];
        [_receiverImageView setImageWithURL:self.session.receiver.profilePictureURL placeholderImage:[UIImage imageNamed:@"ic_profile"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _receiverImageView.layer.cornerRadius  = 5.0;
        _receiverImageView.layer.masksToBounds = YES;
    }
    return _receiverImageView;
}

- (UILabel *)creatorUsernameLabel
{
    if (!_creatorUsernameLabel) {
        CGRect frame = CGRectMake(self.creatorImageView.frame.origin.x, self.creatorImageView.frame.origin.y+60, 100, 32);
        _creatorUsernameLabel = [[UILabel alloc] initWithFrame:frame];
        [_creatorUsernameLabel setText:[NSString stringWithFormat:@"%@", self.session.creator.user.username]];
    }
    return _creatorUsernameLabel;
}

- (UILabel *)receiverUsernameLabel
{
    if (!_receiverUsernameLabel) {
        CGRect frame = CGRectMake(self.receiverImageView.frame.origin.x-40, self.receiverImageView.frame.origin.y+60, 100, 32);
        _receiverUsernameLabel = [[UILabel alloc] initWithFrame:frame];
        [_receiverUsernameLabel setTextAlignment:NSTextAlignmentRight];
        [_receiverUsernameLabel setAlpha:0.0f];
        [_receiverUsernameLabel setText:[NSString stringWithFormat:@"%@", self.session.receiver.user.username]];
    }
    return _receiverUsernameLabel;
}

- (UIImageView *)voteForCreatorIV
{
    if (!_voteForCreatorIV) {
        CGRect frame = CGRectMake(10, self.view.frame.size.height, 60, 60);
        _voteForCreatorIV = [[UIImageView alloc] initWithFrame:frame];
        _voteForCreatorIV.center = CGPointMake(40, self.view.frame.size.height);
        [_voteForCreatorIV setImageWithURL:self.session.creator.profilePictureURL placeholderImage:[UIImage imageNamed:@"ic_profile"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _voteForCreatorIV.layer.cornerRadius = 5.0;
        _voteForCreatorIV.layer.masksToBounds = YES;
        _voteForCreatorIV.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(voteCreatorTapDetected)];
        singleTap.numberOfTapsRequired = 1;
        [_voteForCreatorIV addGestureRecognizer:singleTap];
        
//        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handleCreatorPan:)];
//        [_voteForCreatorIV addGestureRecognizer:panRecognizer];
    }
    return _voteForCreatorIV;
}

- (UIImageView *)voteForReceiverIV
{
    if (!_voteForReceiverIV) {
        CGRect frame = CGRectMake(self.view.frame.size.width-70, self.view.frame.size.height, 60, 60);
        _voteForReceiverIV= [[UIImageView alloc] initWithFrame:frame];
        _voteForReceiverIV.center = CGPointMake(self.view.frame.size.width-40, self.view.frame.size.height);
        [_voteForReceiverIV setImageWithURL:self.session.receiver.profilePictureURL placeholderImage:[UIImage imageNamed:@"ic_profile"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _voteForReceiverIV.layer.cornerRadius = 5.0;
        _voteForReceiverIV.layer.masksToBounds = YES;
        _voteForReceiverIV.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(voteReceiverTapDetected)];
        singleTap.numberOfTapsRequired = 1;
        [_voteForReceiverIV addGestureRecognizer:singleTap];
    
//        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handleReceiverPan:)];
//        [_voteForReceiverIV addGestureRecognizer:panRecognizer];
    }
    return _voteForReceiverIV;
}

- (UIView *)dragHereToVoteView
{
    if (!_dragHereToVoteView) {
        CGRect frame = CGRectMake(self.view.frame.size.width-70, self.view.frame.size.height, 74, 74);
        _dragHereToVoteView = [[UIImageView alloc] initWithFrame:frame];
        _dragHereToVoteView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height);
        [_dragHereToVoteView setBackgroundColor:[UIColor lightGrayColor]];
        _dragHereToVoteView.layer.cornerRadius = 5.0;
        _dragHereToVoteView.layer.masksToBounds = YES;
    }
    return _dragHereToVoteView;
}

- (UILabel *)votingTitleLabel
{
    if (!_votingTitleLabel) {
        _votingTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
        _votingTitleLabel.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height);
        [_votingTitleLabel setText:@"WHO WON?"];
        [_votingTitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:22.0]];
        [_votingTitleLabel setTextColor:[UIColor whiteColor]];
        [_votingTitleLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return _votingTitleLabel;
}

@end
