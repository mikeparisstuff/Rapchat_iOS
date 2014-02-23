//
//  RCProfileViewController.h
//  Rapchat
//
//  Created by Michael Paris on 12/8/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import "RCViewController.h"
#import "RCSessionTableViewCell.h"
#import "RCFriendTableViewCell.h"
#import "RCCrowdTableViewCell.h"

@interface RCProfileViewController : RCViewController <UITableViewDelegate, UITableViewDataSource, RCSessionCellProtocol, RCFriendCellProtocol, RCCrowdTableViewCellProtocol>

@end
