//
//  RCProfile.h
//  Rapchat
//
//  Created by Michael Paris on 12/11/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCUser.h"
#import "RCBaseModel.h"

@interface RCProfile : RCBaseModel

@property (nonatomic, copy) NSNumber *profileId;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, strong) RCUser *user;
@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, copy) NSURL *profilePictureURL;

@property (nonatomic, copy) NSNumber *numberOfFriends;
@property (nonatomic, copy) NSNumber *numberOfLikes;
@property (nonatomic, copy) NSNumber *numberOfRaps;

@property (nonatomic, copy) NSDate *created;
@property (nonatomic, copy) NSDate *modified;

- (NSString *)text;

@end
