//
//  RCFeedViewController.h
//  Rapchat
//
//  Created by Michael Paris on 12/12/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCViewController.h"
#import "RCContractableTableViewController.h"
#import "RCSessionTableViewCell.h"
#import "RCRapTableViewCell.h"

@interface RCFeedViewController : RCViewController <RCSessionCellProtocol, RCRapTableViewCellDelegate, UITableViewDataSource, UITableViewDelegate>

@end

