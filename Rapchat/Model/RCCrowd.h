//
//  RCCrowd.h
//  Rapchat
//
//  Created by Michael Paris on 12/12/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCCrowd : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSDate *created;
@property (nonatomic, copy) NSDate *modified;
@property (nonatomic, strong) NSArray *members;

@end
