//
//  RCPublicProfile.h
//  Rapchat
//
//  Created by Michael Paris on 1/12/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCProfile.h"

@interface RCPublicProfile : NSObject

@property (nonatomic, strong) NSArray *likes;
@property (nonatomic, strong) RCProfile *profile;

@end
