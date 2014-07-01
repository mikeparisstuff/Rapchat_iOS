//
//  RCBeat.h
//  Rapchat
//
//  Created by Michael Paris on 6/22/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface RCBeat : NSObject

- (id) initWithUrl:(NSURL *)url AndTitle:(NSString *)title;
- (id) initWithResourceName:(NSString *)name AndTitle:(NSString *)title;

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) AVURLAsset *asset;

@end
