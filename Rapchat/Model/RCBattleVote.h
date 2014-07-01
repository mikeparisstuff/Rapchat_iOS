//
//  RCBattleVote.h
//  Rapchat
//
//  Created by Michael Paris on 3/14/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCProfile.h"
#import "RCSession.h"

@interface RCBattleVote : NSObject

@property (nonatomic, copy) NSNumber *voteId;
@property (nonatomic, copy) NSDate *created;
@property (nonatomic, copy) NSDate *modified;
@property (nonatomic) RCProfile *voter;
@property (nonatomic) RCProfile *votedFor;
@property (nonatomic) RCSession *battle;
@property (nonatomic, copy) NSNumber *isForCreator;

@end
