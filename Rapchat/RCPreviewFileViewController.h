//
//  RCPreviewFileViewController.h
//  Rapchat
//
//  Created by Michael Paris on 12/16/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCViewController.h"

@interface RCPreviewFileViewController : RCViewController

@property (nonatomic) NSURL *videoURL;
@property (nonatomic) NSURL *thumbnailImageUrl;
@property (nonatomic, strong)NSNumber *sessionId;
@property (nonatomic) float progressValue;

@end
