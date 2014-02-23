//
//  RCCrowdTableViewCell.h
//  Rapchat
//
//  Created by Michael Paris on 12/14/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCCrowd.h"

@protocol RCCrowdTableViewCellProtocol <NSObject>

- (void)viewCrowdMembers:(UITableViewCell *)sender;

@end

@interface RCCrowdTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfMembersLabel;
@property (weak, nonatomic) id delegate;

- (void)setCrowd:(RCCrowd *)crowd;

@end
