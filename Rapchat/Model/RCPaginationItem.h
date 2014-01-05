//
//  RCPaginationItem.h
//  Rapchat
//
//  Created by Michael Paris on 1/3/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCPaginationItem : NSObject

@property (nonatomic, copy) NSString *nextUrl;
@property (nonatomic, copy) NSString *previousUrl;
@property (nonatomic, copy) NSNumber *itemCount;

@end
