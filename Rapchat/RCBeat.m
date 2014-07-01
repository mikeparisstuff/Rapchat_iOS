//
//  RCBeat.m
//  Rapchat
//
//  Created by Michael Paris on 6/22/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCBeat.h"

@interface RCBeat ()


@end

@implementation RCBeat

- (id) initWithResourceName:(NSString *)name AndTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *filePath = [mainBundle pathForResource:name ofType:@"mp3"];
        NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
        self.url = fileUrl;
        self.asset = [AVURLAsset assetWithURL:fileUrl];
        self.title = title;
    }
    return self;
}

- (id) initWithUrl:(NSURL *)url AndTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        self.url = url;
        self.asset = [AVURLAsset assetWithURL:url];
        self.title = title;
    }
    return self;
}

- (AVURLAsset *)asset
{
    if (!self.asset) {
        self.asset = [AVURLAsset assetWithURL:self.url];
    }
    return self.asset;
}

@end
