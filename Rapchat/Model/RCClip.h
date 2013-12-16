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

@interface RCClip : NSObject

@property (nonatomic, copy) NSNumber *clipNumber;
@property (nonatomic, strong) RCProfile *creator;
@property (nonatomic, strong) RCSession *session;
@property (nonatomic, copy) NSDate *created;
@property (nonatomic, copy) NSDate *modified;

@end
