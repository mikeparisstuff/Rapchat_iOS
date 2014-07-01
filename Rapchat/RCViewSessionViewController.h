//
//  RCViewSessionViewController.h
//  Rapchat
//
//  Created by Michael Paris on 1/14/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCViewController.h"
#import "RCSession.h"
#import "RCVoteCount.h"

@interface RCViewSessionViewController : RCViewController

@property (nonatomic, strong) RCSession *session;
@property (nonatomic) BOOL sessionIsLiked;
@property (nonatomic) BOOL has_been_voted_on;
@property (nonatomic) RCVoteCount *voteCount;

@end
