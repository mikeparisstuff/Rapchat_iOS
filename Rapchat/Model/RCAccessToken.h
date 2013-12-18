//
//  RCAccessToken.h
//  Rapchat
//
//  Created by Michael Paris on 12/13/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCBaseModel.h"

@interface RCAccessToken : RCBaseModel

@property (nonatomic, copy) NSString* accessToken;

@end
