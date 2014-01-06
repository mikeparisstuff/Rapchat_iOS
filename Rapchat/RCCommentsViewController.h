//
//  RCCommentsViewController.h
//  Rapchat
//
//  Created by Michael Paris on 12/17/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCViewController.h"

@interface RCCommentsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSNumber *sessionId;
@property (strong, nonatomic) NSArray *comments;

@end
