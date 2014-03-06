//
//  RCRightRevealViewController.h
//  Rapchat
//
//  Created by Michael Paris on 3/2/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCTableViewController.h"
#import "RCFriendTableViewCell.h"

@protocol RCRightRevealVCProtocol <NSObject>

- (void) pushToPresentationMode;
- (void) pushBackFromPresentationMode;

@end

@interface RCRightRevealViewController : RCTableViewController <RCFriendCellProtocol>

@property (nonatomic, strong) id delegate;

@end
