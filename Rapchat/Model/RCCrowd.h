//
//  RCCrowd.h
//  Rapchat
//
//  Created by Michael Paris on 12/12/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCBaseModel.h"

@interface RCCrowd : RCBaseModel

@property (nonatomic, copy) NSNumber *crowdId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSDate *created;
@property (nonatomic, copy) NSDate *modified;
@property (nonatomic, strong) NSArray *members;

@end
