//
//  RCRapTableViewCell.h
//  Rapchat
//
//  Created by Michael Paris on 6/29/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCSession.h"

@protocol RCRapTableViewCellDelegate

- (void)likeButtonPressedInCell:(UITableViewCell *)sender;
- (void)commentButtonPressedInCell:(UITableViewCell *)sender;
- (void)playAudioWithUrl:(NSURL *)url;

@end

@interface RCRapTableViewCell : UITableViewCell

- (void) setCellSession:(RCSession *) session;
- (RCSession *) getCellSession;
@property (nonatomic, strong) id<RCRapTableViewCellDelegate> delegate;

@end
