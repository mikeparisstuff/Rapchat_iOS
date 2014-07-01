//
//  RCChooseSongTableViewCell.h
//  Rapchat
//
//  Created by Michael Paris on 6/22/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RCChooseSongTableViewCellDelegate <NSObject>

- (void) playButtonTapped;
- (void) pauseButtonTapped;

@end

@interface RCChooseSongTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *songTitleLabel;
@property (strong, nonatomic) id<RCChooseSongTableViewCellDelegate> delegate;

- (void) hideAccessoryButton;
- (void) showAccessoryButton;


@end
