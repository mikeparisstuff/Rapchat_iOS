//
//  RCSessionPaginator.m
//  Rapchat
//
//  Created by Michael Paris on 1/3/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCSessionPaginator.h"
#import "RCUrlPaths.h"

@implementation RCSessionPaginator

- (void)getNextPage
{
    // Load the object model via RestKit
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    NSString *nextUrl = (self.nextUrl) ? self.nextUrl : mySessionsEndpoint;
    
    [objectManager getObjectsAtPath:mySessionsEndpoint
                         parameters:nil
                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                self.currentPageSessions = [mappingResult array];
                                [self.allSessions addObjectsFromArray:[mappingResult array]];
                            }failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error"
                                                                                message:[error localizedDescription]
                                                                               delegate:nil
                                                                      cancelButtonTitle:@"OK"
                                                                      otherButtonTitles:nil, nil];
                                [alert show];
                                NSLog(@"Hit error: %@", error);
                            }];
}

- (NSArray *)getCurrentPage
{
    return [self.currentPageSessions copy];
}

- (NSArray *)getAllSessions
{
    return [self.allSessions copy];
}




#pragma mark Lazy Getters
- (NSArray *)currentPageSessions
{
    if (!_currentPageSessions){
        _currentPageSessions = [[NSArray alloc] init];
    }
    return _currentPageSessions;
}

- (NSMutableArray *)allSessions
{
    if (!_allSessions){
        _allSessions = [[NSArray alloc] init];
    }
    return _allSessions;
}

@end
