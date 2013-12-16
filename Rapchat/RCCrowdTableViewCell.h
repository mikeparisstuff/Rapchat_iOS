//
//  RCCrowdTableViewCell.h
//  Rapchat
//
//  Created by Michael Paris on 12/14/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCCrowdTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfMembersLabel;

@end
