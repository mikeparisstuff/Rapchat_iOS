//
//  RCTabBarController.h
//  Rapchat
//
//  Created by Michael Paris on 12/9/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCTabBarController : UITabBarController

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated;
- (BOOL)tabBarIsHidden;

@end
