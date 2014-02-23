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
#import <SVProgressHUD.h>
#import <AVFoundation/AVFoundation.h>

static const NSString *ItemStatusContext;
static const NSString *ItemPlaybackLikelyToKeepUpContext;

@interface RCViewSessionViewController ()

// RCFilePlayer properties
@property (nonatomic) AVPlayer *player;
@property (nonatomic) AVPlayerItem *playerItem;
@property (weak, nonatomic) IBOutlet RCFilePlayerView *playerView;

@property (nonatomic) NSArray *videoClips;
@property (nonatomic) NSMutableArray *videoAssets;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;

@end

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
    
    
    currentVideoIndex = 0;
    [self setTitle:self.session.title];
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
    [self playNextClip];
//    [self loadClips];
//    [self loadAssetFromFile];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //    [[NSFileManager defaultManager] removeItemAtPath:[self.thumbnailImageUrl absoluteString] error:nil];
    [self.player pause];
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
    if (currentVideoIndex < [self.videoAssets count]) {
        NSLog(@"Using existing asset");
        self.playerItem = [AVPlayerItem playerItemWithAsset:self.videoAssets[currentVideoIndex]];;
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
        NSLog(@"Loading new asset from url");
        NSURL *fileUrl = url;
        videoAsset = [AVURLAsset URLAssetWithURL:fileUrl options:nil];
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
                                                             self.playerItem = [AVPlayerItem playerItemWithAsset:videoAsset];
                                                             [self.videoAssets addObject:videoAsset];
                                                             [self.playerItem addObserver:self
                                                                               forKeyPath:@"status"
                                                                                  options:0
                                                                                  context:&ItemStatusContext];
                                                             [self.playerItem addObserver:self
                                                                               forKeyPath:@"playbackLikelyToKeepUp"
                                                                                  options:0
                                                                                  context:&ItemPlaybackLikelyToKeepUpContext];
                                                             self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
                                                             self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
                                                             [[NSNotificationCenter defaultCenter] addObserver:self
                                                                                                      selector:@selector(playerItemDidReachEnd:)
                                                                                                          name:AVPlayerItemDidPlayToEndTimeNotification
                                                                                                        object:[self.player currentItem]];
                                                             [self.playerView setPlayer:self.player];
                                                             NSLog(@"Would Be Playing");
                                                             //                                                         [self.player play];
                                                         } else {
                                                             // Deal with the error
                                                             NSLog(@"The asset's tracks were not loaded: \n%@", [error localizedDescription]);
                                                         }
                                                         
                                                     });
                                  }];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"status"]) {
        if (self.player.status == AVPlayerStatusReadyToPlay) {
            //            playButton.enabled = YES;
            
            //            while (CMTimeGetSeconds([[self.playerItem.loadedTimeRanges objectAtIndex:0] CMTimeRangeValue].duration) < 3) {
            //                NSLog(@"Loaded time ranges: %f", CMTimeGetSeconds([[self.playerItem.loadedTimeRanges objectAtIndex:0] CMTimeRangeValue].duration));
            //            }
            //            [self.player play];
            NSLog(@"Player ready to play");
        } else if (self.player.status == AVPlayerStatusFailed) {
            // something went wrong. player.error should contain some information
            NSLog(@"Player Failed");
        }
    }
    if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        //        NSLog(@"Playback likely to keep up");
        if (self.playerItem.playbackLikelyToKeepUp == YES) {
            [self.player play];
        } else {
            [self.player pause];
        }
    }
    
    if (context == &ItemStatusContext) {
        NSLog(@"Item Status Context Change");
        //        dispatch_async(dispatch_get_main_queue(),
        //                       ^{
        //                           NSLog(@"Status changed.");
        ////                           [self syncUI];
        //                       });
        return;
    }
    if (context == &ItemPlaybackLikelyToKeepUpContext) {
        NSLog(@"Item Playback likely to keep up context change");
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object
                           change:change context:context];
    return;
}


- (void)playerItemDidReachEnd:(NSNotification *)notification {
//    [self.player seekToTime:kCMTimeZero];
    // Remove the observer on the current item because we reallocate them when we start playing them
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:[self.player currentItem]];
    
    [self playNextClip];
    NSLog(@"Rewound to time 0. Restarting Clip");
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
- (NSMutableArray *)videoAssets
{
    if (!_videoAssets) {
        _videoAssets = [[NSMutableArray alloc] init];
    }
    return _videoAssets;
}

@end
