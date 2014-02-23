//
//  RCCameraViewController.h
//  Rapchat
//
//  Created by Michael Paris on 12/16/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCViewController.h"

@interface RCCameraViewController : RCViewController

- (NSURL *)getVideoUrl;

// Thumbnail
@property (nonatomic, strong) NSURL *thumbnailImageUrl;
@property (nonatomic, strong) NSString *currentBeat;
@property (nonatomic) NSUInteger beatNumber;
@property (nonatomic, strong)NSArray *beats;

@property (nonatomic) float timerProgress;

- (void)changeCamera:(id)sender;
- (void)reloadAudio;
- (void)changeSong;

@end
