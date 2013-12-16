//
//  RCComment.h
//  Rapchat
//
//  Created by Michael Paris on 12/12/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCProfile.h"
#import "RCSession.h"

@interface RCComment : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSDate *created;
@property (nonatomic, copy) NSDate *modified;
@property (nonatomic, strong) RCProfile *creator;
@property (nonatomic, strong) RCSession *session;


@end
