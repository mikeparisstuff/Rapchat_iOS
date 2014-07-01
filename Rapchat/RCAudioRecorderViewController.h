//
//  RCAudioRecorderViewController.h
//  Rapchat
//
//  Created by Michael Paris on 6/18/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCViewController.h"
#import "RCAudioRecorderAndPlayer.h"
#import "RCChooseSongTableViewController.h"
#import "EZAudio.h"

@interface RCAudioRecorderViewController : RCViewController <RCAudioRecorderAndPlayerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, RCChooseSongTableViewControllerDelegate, EZAudioFileDelegate>

@end
