//
//  RCAudioRecorderAndPlayer.m
//  Rapchat
//
//  Created by Michael Paris on 6/19/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCAudioRecorderAndPlayer.h"

@interface RCAudioRecorderAndPlayer ()

@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) AVPlayer *urlPlayer;

@end

@implementation RCAudioRecorderAndPlayer

- (id) initWithOutputUrl:(NSURL *)url
{
    self = [super init];
    if (self){
        // initialize self
        if (url != nil) {
            [self setupRecorderToOutputTo:url];
        }
    }
    return self;
}

- (void) setupRecorderToOutputTo:(NSURL *)url
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    
    // Initiate and prepare the recorder
    self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:NULL];
    self.recorder.delegate = self;
//    self.recorder.meteringEnabled = YES;
    self.recorder.delegate = self;
    [self.recorder prepareToRecord];
}

#pragma mark - Control Player Playback
- (void) setPlayerWithContentsOfUrl:(NSURL *)url
{
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.player.delegate = self;
    [self.player setDelegate:self];
    [self.player prepareToPlay];
}

- (void) setPlayerWithData:(NSData *)data
{
    self.player = [[AVAudioPlayer alloc] initWithData:data error:nil];
    self.player.delegate = self;
    [self.player setDelegate:self];
    [self.player prepareToPlay];
}

- (void) startPlayerWithUrl:(NSURL *)url
{
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.player.delegate = self;
    [self.player setDelegate:self];
    [self.player prepareToPlay];
    [self.player play];
}

- (void) startPlayerWithData:(NSData *)data
{
    NSError *error = nil;
    
    self.player = [[AVAudioPlayer alloc] initWithData:data error:&error];
    self.player.delegate = self;
    [self.player setDelegate:self];
    [self.player prepareToPlay];
    [self.player play];
}

- (void) startPlayer
{
    [self.player play];
}

- (void) startPlayerAtTime:(NSTimeInterval)interval
{
    [self.player playAtTime:interval];
}

- (void) pausePlayer
{
    [self.player pause];
}

- (void) stopPlayer
{
    if (self.player.isPlaying) {
        [self.player stop];
    }
}

- (NSURL *) playerUrl
{
    return self.player.url;
}

- (void) setVolume:(float)volume
{
    self.player.volume = volume;
}

- (BOOL) isPlaying
{
    return self.player.isPlaying;
}



#pragma mark - Recorder Controls

- (void)startRecorder
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    
    // Start recording
    [self.recorder record];
}

- (void)pauseRecorder
{
    [self.recorder pause];
}

- (void)stopRecorder
{
    [self.recorder stop];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}

- (void) recordForDuration:(NSTimeInterval)duration
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    
    // Start recording
    [self.recorder recordForDuration:duration];
}

- (BOOL) deleteRecording
{
    return [self.recorder deleteRecording];
}

#pragma mark - Recorder Status
- (BOOL) isRecorderRecording
{
    return self.recorder.recording;
}

- (NSURL *) recorderOutputURL
{
    return self.recorder.url;
}

- (NSTimeInterval) recorderCurrentTime
{
    return self.recorder.currentTime;
}

- (NSDictionary *) recorderSettings
{
    return self.recorder.settings;
}

#pragma mark - Player and Recorder Delegates
#pragma mark - AVAudioRecorderDelegate
- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag
{
    [self.delegate recorderDidFinishRecording:avrecorder successfully:flag];
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self.delegate playerDidFinishPlaying:player successfully:flag];
}

#pragma mark - Audio Manipulation
- (void) superImposeAudioTracks
{
    AVURLAsset *songAsset = [[AVURLAsset alloc] initWithURL:self.player.url options:nil];
    AVURLAsset *rapAsset = [[AVURLAsset alloc] initWithURL:self.recorder.url options:nil];
    NSLog(@"Song Asset URL: %@", self.player.url);
    NSLog(@"Rap Asset URL: %@", self.recorder.url);
    if (songAsset != nil && rapAsset != nil) {
        AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
        AVMutableCompositionTrack *songCompositionTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        AVMutableCompositionTrack *rapCompositionTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        NSError *error;
        [rapCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, rapAsset.duration) ofTrack:[[rapAsset tracksWithMediaType:AVMediaTypeAudio] lastObject] atTime:kCMTimeZero error:&error];
        if (error) {
            NSLog(@"Error adding rap track to composition: %@", error.description);
            error = nil;
        }
        [songCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, songAsset.duration) ofTrack:[[songAsset tracksWithMediaType:AVMediaTypeAudio] lastObject] atTime:kCMTimeZero error:&error];
        if (error) {
            NSLog(@"Error adding song track to composition");
        }
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,    NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *combinedSongUrl = [documentsDirectory stringByAppendingPathComponent:@"export.m4a"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:combinedSongUrl]) {
            NSError *error;
            [[NSFileManager defaultManager] removeItemAtPath:combinedSongUrl error:&error];
            if (error) {
                NSLog(@"Error removing file: ERROR: %@", error);
            }
        }
        NSURL *url = [NSURL fileURLWithPath:combinedSongUrl];
        
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetAppleM4A];
        exporter.outputURL = url;
        exporter.outputFileType = AVFileTypeAppleM4A;
        exporter.shouldOptimizeForNetworkUse = YES;
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            switch (exporter.status) {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export failed -> Reason: %@, User Info: %@",
                          exporter.error.localizedDescription,
                          exporter.error.userInfo.description);
                    break;
                    
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export cancelled");
                    break;
                    
                case AVAssetExportSessionStatusCompleted:
                    NSLog(@"Export finished");
                    [self.delegate audioFilesWereSuccessfullyMixedAtURL:exporter.outputURL];
                    break;
                    
                default:
                    break;
            }
        }];
    }
}

@end
