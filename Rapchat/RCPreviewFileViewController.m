//
//  RCPreviewFileViewController.m
//  Rapchat
//
//  Created by Michael Paris on 12/16/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import "RCPreviewFileViewController.h"
#import "RCFilePlayerView.h"
#import "RCTabBarController.h"
#import "RCProgressView.h"

#import <AVFoundation/AVFoundation.h>

static const NSString *ItemStatusContext;
static const NSString *ItemPlaybackLikelyToKeepUpContext;

@interface RCPreviewFileViewController ()

// RCFilePlayer properties
@property (nonatomic) AVPlayer *player;
@property (nonatomic) AVPlayerItem *playerItem;
@property (weak, nonatomic) IBOutlet RCFilePlayerView *playerView;
@property (nonatomic) RCProgressView *progressView;

@property (nonatomic) NSTimer *myTimer;



@end

@implementation RCPreviewFileViewController

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
    
//    // Create the AVPlayer
//    AVPlayer *player = [[AVPlayer alloc] init];
//    [self setPlayer:player];
//    
//    // Setup the previewView to play the file
//    [[self playerView] setPlayer:player];
//    dispatch_queue_t playerQueue = dispatch_queue_create("player queue", DISPATCH_QUEUE_SERIAL);
//    [self setPlayerQueue:playerQueue];

}

- (void) setupProgressView {
    // Create the progress view
    // On the custome view you need to set the frame twice because it overwrites the frame in init
    [self.navigationController.navigationBar setTranslucent:YES];
    self.progressView=[[RCProgressView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-96, 325, 96)];
    self.progressView.frame = CGRectMake(0, self.view.frame.size.height-96, 325, 96);
    [self.view addSubview:self.progressView];
    //    [self.view sendSubviewToBack:self.previewView];
    [self.view sendSubviewToBack:self.progressView];
    [self.progressView setProgress:self.progressValue animated:YES];
//    [self startTimer];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"RCPreviewFileViewController will appear to show file at url: %@", self.videoURL);
    [super viewWillAppear:animated];
    [self loadAssetFromFile];
    [self setupProgressView];
}

- (void)viewWillDisappear:(BOOL)animated
{
//    [[NSFileManager defaultManager] removeItemAtPath:[self.thumbnailImageUrl absoluteString] error:nil];
    [self.player pause];
    NSLog(@"Preview Disappearing. Pausing Playback");
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
    [super viewWillDisappear:animated];
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

#pragma mark File Player

//- (void)syncUI
//{
//    if ((self.player.currentItem != nil) && ([self.player.currentItem status] == AVPlayerItemStatusReadyToPlay)) {
//        self.nextButton.enabled = YES;
//    } else {
//        self.nextButton.enabled = NO;
//    }
//}

- (void)loadAssetFromFile
{
    NSLog(@"loadAssetFromFile called");
    NSURL *fileUrl = self.videoURL;
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
                                                         self.playerItem = [AVPlayerItem playerItemWithAsset:videoAsset];
                                                         [self.playerItem addObserver:self
                                                                           forKeyPath:@"status"
                                                                              options:0
                                                                              context:&ItemStatusContext];
                                                         [self.playerItem addObserver:self
                                                                           forKeyPath:@"playbackLikelyToKeepUp"
                                                                              options:0
                                                                              context:&ItemPlaybackLikelyToKeepUpContext];
                                                         [self.playerItem addObserver:self forKeyPath:@"currentTime.value" options:0 context:nil];
                                                         self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
                                                         self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
                                                         
                                                         [self.playerView setPlayer:self.player];
                                                         [[NSNotificationCenter defaultCenter] addObserver:self
                                                                                                  selector:@selector(playerItemDidReachEnd:)
                                                                                                      name:AVPlayerItemDidPlayToEndTimeNotification
                                                                                                    object:[self.player currentItem]];
                                                         NSLog(@"Would Be Playing");
//                                                         [self.player play];
                                                     } else {
                                                         // Deal with the error
                                                         NSLog(@"The asset's tracks were not loaded: \n%@", [error localizedDescription]);
                                                     }
                                                     
                                                 });
                              }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {

    NSLog(@"Keypath: %@", keyPath);
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
    if ([keyPath isEqualToString:@"currentTime.value"]) {
        NSLog(@"Detecting change of value: %@", change);
        [self.progressView setProgress:10.0];
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object
                           change:change context:context];
    return;
}

- (void)startTimer
{
    NSLog(@"Starting Timer");
    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateProgressView) userInfo:nil repeats:YES];
}

- (void)updateProgressView {
    double progress = self.playerItem.currentTime.value ;
    [self.progressView setProgress:progress];
}


- (void)playerItemDidReachEnd:(NSNotification *)notification {
    [self.player seekToTime:kCMTimeZero];
    NSLog(@"Rewound to time 0. Restarting Clip");
//    [self.player play];
}

#pragma mark Actions

- (IBAction)retryVideoCapture:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)submitVideoForUpload:(UIButton *)sender {
    NSLog(@"Submit video and go to select crowd");
}
@end
