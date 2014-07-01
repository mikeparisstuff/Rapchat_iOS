//
//  RCVoteCount.h
//  Rapchat
//
//  Created by Michael Paris on 3/14/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCVoteCount : NSObject

@property (nonatomic, copy) NSNumber *votesForCreator;
@property (nonatomic, copy) NSNumber *votesForReceiver;

@end
