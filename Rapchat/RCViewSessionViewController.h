//
//  RCViewSessionViewController.h
//  Rapchat
//
//  Created by Michael Paris on 1/14/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCViewController.h"
#import "RCSession.h"

@interface RCViewSessionViewController : RCViewController

@property (nonatomic, strong) RCSession *session;
@property (nonatomic) BOOL sessionIsLiked;

@end
