//
//  RCViewController.h
//  Rapchat
//
//  Created by Michael Paris on 12/8/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AwesomeMenu.h"

@interface RCViewController : UIViewController <AwesomeMenuDelegate>

@property (nonatomic, strong) id revealDelegate;

- (void)makeNavbarInvisible;
- (AwesomeMenu *)createAwesomeMenu;

@end
