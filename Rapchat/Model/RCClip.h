//
//  RCClip.h
//  Rapchat
//
//  Created by Michael Paris on 12/12/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCProfile.h"
#import "RCSession.h"
#import "RCBaseModel.h"

@interface RCClip : RCBaseModel

@property (nonatomic, copy) NSNumber *clipId;
@property (nonatomic, copy) NSString *relativePath;
@property (nonatomic, copy) NSNumber *clipNumber;
@property (nonatomic, copy) NSURL *url;
@property (nonatomic, copy) NSNumber *creator;
@property (nonatomic, copy) NSNumber *session;
@property (nonatomic, copy) NSURL *thumbnailUrl;
@property (nonatomic, copy) NSDate *created;
@property (nonatomic, copy) NSDate *modified;

@end
