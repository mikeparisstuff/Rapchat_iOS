//
//  RCVideoReencoder.h
//  Rapchat
//
//  Created by Michael Paris on 1/13/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCVideoReencoder : NSObject

@property (nonatomic) NSString *outputURL;
@property (nonatomic) NSString *status;
- (void)loadAssetToReencode:(NSURL *)videoURL;

@end
