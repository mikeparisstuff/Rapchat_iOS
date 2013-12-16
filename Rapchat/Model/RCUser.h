//
//  RCUser.h
//  Rapchat
//
//  Created by Michael Paris on 12/11/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCUser : NSObject

@property (nonatomic, copy) NSNumber *userId;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *email;
//@property (nonatomic, copy) NSDate *lastLogin;
@property (nonatomic, copy) NSDate *dateJoined;

@end
