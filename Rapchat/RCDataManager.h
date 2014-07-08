//
//  RCDataManager.h
//  Rapchat
//
//  Created by Michael Paris on 7/1/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCProfile.h"
#import "RCLike.h"

@interface RCDataManager : NSObject

@property (nonatomic, strong) NSArray *sessions;
@property (nonatomic, strong) RCProfile *myProfile;
@property (nonatomic, strong) NSArray *myLikes;

+ (RCDataManager*)sharedInstance;
+ (void) refreshSessions;
+ (void) refreshProfile;
+ (void) refreshLikes;
+ (void) refreshAll;

@end
