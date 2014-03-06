//
//  RCLeftRevealViewController.h
//  Rapchat
//
//  Created by Michael Paris on 3/2/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCViewController.h"

@protocol RCLeftRevealVCProtocol <NSObject>

- (void)gotoLive;
- (void)gotoStage;
- (void)gotoProfile;
- (void)gotoFeedback;

@end

@interface RCLeftRevealViewController : RCViewController

@property (nonatomic, strong) id delegate;

@end
