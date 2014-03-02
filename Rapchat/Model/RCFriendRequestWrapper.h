//
//  RCFriendRequestWrapper.h
//  Rapchat
//
//  Created by Michael Paris on 2/26/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCFriendRequestWrapper : NSObject

@property (nonatomic, strong) NSArray *pendingMe;
@property (nonatomic, strong) NSArray *pendingThem;

@end
