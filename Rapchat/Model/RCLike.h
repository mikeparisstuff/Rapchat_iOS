//
//  RCLike.h
//  Rapchat
//
//  Created by Michael Paris on 12/17/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCSession.h"
#import "RCBaseModel.h"

@interface RCLike : RCBaseModel

@property (nonatomic, copy) NSNumber *likeId;
@property (nonatomic, strong) RCSession *session;
@property (nonatomic, copy) NSDate *created;
@property (nonatomic, copy) NSDate *modified;

// May want to add user later

@end
