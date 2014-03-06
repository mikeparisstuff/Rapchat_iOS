//
//  RCAppDelegate.h
//  Rapchat
//
//  Created by Michael Paris on 12/8/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKRevealController.h"
#import "RCLeftRevealViewController.h"
#import "RCRightRevealViewController.h"
#import "RCNavigationController.h"

@interface RCAppDelegate : UIResponder <UIApplicationDelegate, RCLeftRevealVCProtocol, RCNavigationControllerProtocol, RCRightRevealVCProtocol >

@property (strong, nonatomic) UIWindow *window;

@end
