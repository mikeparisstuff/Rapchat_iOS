//
//  RCCameraView.h
//  Rapchat
//
//  Created by Michael Paris on 12/16/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVCaptureSession;

@interface RCCameraView : UIView

@property (nonatomic) AVCaptureSession *session;

@end
