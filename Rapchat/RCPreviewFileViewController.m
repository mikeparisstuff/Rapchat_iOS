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

#import <AVFoundation/AVFoundation.h>

static const NSString *ItemStatusContext;

@interface RCPreviewFileViewController ()

// RCFilePlayer properties
@property (nonatomic) AVPlayer *player;
@property (nonatomic) AVPlayerItem *playerItem;
@property (weak, nonatomic) IBOutlet RCFilePlayerView *playerView;


@end

@implementation RCPreviewFileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    self.showTabBar = NO;
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

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"RCPreviewFileViewController will appear to show file at url: %@", self.videoURL);
    [super viewWillAppear:animated];
    [self loadAssetFromFile];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.player pause];
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
                                                         self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
                                                         self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
                                                         [self.playerView setPlayer:self.player];
                                                         [[NSNotificationCenter defaultCenter] addObserver:self
                                                                                                  selector:@selector(playerItemDidReachEnd:)
                                                                                                      name:AVPlayerItemDidPlayToEndTimeNotification
                                                                                                    object:[self.player currentItem]];
                                                         [self.player play];
                                                     } else {
                                                         // Deal with the error
                                                         NSLog(@"The asset's tracks were not loaded: \n%@", [error localizedDescription]);
                                                     }
                                                     
                                                 });
                              }];
}

- (void)dealloc
{
    NSLog(@"Deleting file: %@", self.videoURL);
//    [[NSFileManager defaultManager] removeItemAtURL:self.videoURL error:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:[self.player currentItem]];
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [[NSFileManager defaultManager] removeItemAtPath:[self.thumbnailImageUrl absoluteString] error:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    
    if (context == &ItemStatusContext) {
        NSLog(@"Item Status Context Change");
//        dispatch_async(dispatch_get_main_queue(),
//                       ^{
//                           NSLog(@"Status changed.");
////                           [self syncUI];
//                       });
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object
                           change:change context:context];
    return;
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
