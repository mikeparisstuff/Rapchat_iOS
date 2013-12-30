//
//  RCCameraViewController.h
//  Rapchat
//
//  Created by Michael Paris on 12/16/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCCameraViewController : UIViewController

- (NSURL *)getVideoUrl;

// Thumbnail
@property (nonatomic, strong) NSURL *thumbnailImageUrl;

- (void)changeCamera:(id)sender;

@end
