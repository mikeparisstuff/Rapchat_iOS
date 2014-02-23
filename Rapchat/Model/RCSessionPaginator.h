//
//  RCSessionPaginator.h
//  Rapchat
//
//  Created by Michael Paris on 1/3/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCPaginationItem.h"
#import "RCSession.h"

@interface RCSessionPaginator : RCPaginationItem

@property (nonatomic, strong) NSArray *currentPageSessions;

@end
