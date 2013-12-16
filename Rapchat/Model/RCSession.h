//
//  RCSession.h
//  Rapchat
//
//  Created by Michael Paris on 12/12/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCCrowd.h"

@interface RCSession : NSObject

@property (nonatomic, copy) NSNumber *sessionId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSNumber *isComplete;
@property (nonatomic, copy) NSDate *created;
@property (nonatomic, copy) NSDate *modified;
@property (nonatomic, strong) RCCrowd *crowd;

// Probably need likes here as well


@end
