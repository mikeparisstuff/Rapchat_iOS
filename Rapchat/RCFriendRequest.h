//
//  RCFriendRequest.h
//  Rapchat
//
//  Created by Michael Paris on 1/1/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCBaseModel.h"
#import "RCUser.h" 

@interface RCFriendRequest : RCBaseModel

@property (nonatomic, copy) NSNumber *friendRequestId;
@property (nonatomic, strong) RCUser *sender;
@property (nonatomic, strong) RCUser *requested;
@property (nonatomic, copy) NSDate *created;
@property (nonatomic, copy) NSDate *modified;

@end
