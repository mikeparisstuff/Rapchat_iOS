//
//  RCAudioRecorderAndPlayer.h
//  Rapchat
//
//  Created by Michael Paris on 6/19/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol RCAudioRecorderAndPlayerDelegate <NSObject>

- (void) audioFilesWereSuccessfullyMixedAtURL:(NSURL *)url;
- (void) recorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag;
- (void) playerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag;

@end

@interface RCAudioRecorderAndPlayer : NSObject <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

- (id) initWithOutputUrl:(NSURL *)url;

- (void) setPlayerWithContentsOfUrl:(NSURL *)url;
- (void) setPlayerWithData:(NSData *)data;
- (void) startPlayerWithUrl:(NSURL *)url;
- (void) startPlayerWithData:(NSData *)data;
- (void) startPlayer;
- (void) startPlayerAtTime:(NSTimeInterval)interval;
- (void) pausePlayer;
- (void) stopPlayer;
- (BOOL) isPlaying;
- (NSURL *)playerUrl;
- (void) setVolume:(float)volume;


@property(nonatomic, assign) id<RCAudioRecorderAndPlayerDelegate> delegate;
@property(nonatomic, assign) id<AVAudioPlayerDelegate> playerDelegate;
@property(nonatomic, assign) id<AVAudioRecorderDelegate> recorderDelegate;

- (void) startRecorder;
- (void) pauseRecorder;
- (void) stopRecorder;
- (void) recordForDuration:(NSTimeInterval)duration;
- (BOOL) deleteRecording;
- (BOOL) isRecorderRecording;
- (NSURL *)recorderOutputURL;
- (NSTimeInterval) recorderCurrentTime;
- (NSDictionary *) recorderSettings;

- (void) superImposeAudioTracks;


@end
