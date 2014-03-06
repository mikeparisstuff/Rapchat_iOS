//
//  RCNavigationController.h
//  Rapchat
//
//  Created by Michael Paris on 12/9/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REMenu.h"

@protocol RCNavigationControllerProtocol <NSObject>

- (void)toggleRevealControllerLeft;
- (void)toggleRevealControllerRight;

@end

@interface RCNavigationController : UINavigationController

@property (strong, readonly, nonatomic) REMenu *menu;
@property (strong) id revealDelegate;

- (void)toggleMenu;
- (void)toggleRevealLeft;
- (void)toggleRevealRight;
- (void)setViewController:(UIViewController *)vc;

@end
