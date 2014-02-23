//
//  RCSession.h
//  Rapchat
//
//  Created by Michael Paris on 12/12/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCCrowd.h"
#import "RCClip.h"
#import "RCBaseModel.h"

@interface RCSession : RCBaseModel

@property (nonatomic, copy) NSNumber *sessionId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSNumber *isComplete;
@property (nonatomic, copy) NSDate *created;
@property (nonatomic, copy) NSDate *modified;
@property (nonatomic, strong) RCCrowd *crowd;
@property (nonatomic, copy) NSNumber *numberOfLikes;
@property (nonatomic, copy) NSArray *comments;
@property (nonatomic, copy) NSURL *mostRecentClipUrl;
@property (nonatomic, copy) NSURL *thumbnailUrl;
@property (nonatomic, strong) NSArray *clips;

// Probably need likes here as well


@end
