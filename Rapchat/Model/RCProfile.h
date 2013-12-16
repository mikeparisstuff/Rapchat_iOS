//
//  RCProfile.h
//  Rapchat
//
//  Created by Michael Paris on 12/11/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCUser.h"

@interface RCProfile : NSObject

@property (nonatomic, copy) NSNumber *profileId;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, strong) RCUser *user;
@property (nonatomic, strong) NSArray *friends;

- (NSString *)text;

@end
