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
#import "RCBaseModel.h"

@interface RCComment : RCBaseModel

@property (nonatomic, copy) NSNumber *commentId;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSDate *created;
@property (nonatomic, copy) NSDate *modified;
@property (nonatomic, strong) NSString *commenter;
//@property (nonatomic, strong) RCSession *session;


@end
