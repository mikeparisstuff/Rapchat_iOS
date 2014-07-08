//
//  RCDataManager.m
//  Rapchat
//
//  Created by Michael Paris on 7/1/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCDataManager.h"

@implementation RCDataManager

- (id) init
{
    self = [super init];
    if (self != nil) {
        self.myProfile = [[RCProfile alloc] init];
    }
    return self;
}

+ (RCDataManager*)sharedInstance
{
    // 1
    static RCDataManager *_sharedInstance = nil;
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[RCDataManager alloc] init];
    });
    return _sharedInstance;
}

@end
