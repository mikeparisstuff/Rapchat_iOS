//
//  RCChooseSongTableViewController.h
//  Rapchat
//
//  Created by Michael Paris on 6/22/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCTableViewController.h"
#import "RCChooseSongTableViewCell.h"
#import "RCBeat.h"

@protocol RCChooseSongTableViewControllerDelegate <NSObject>

- (void)selectionDidFinishWithSong:(RCBeat *)beat;

@end

@interface RCChooseSongTableViewController : RCTableViewController <RCChooseSongTableViewCellDelegate>

@property(nonatomic, strong) id<RCChooseSongTableViewControllerDelegate> delegate;

@end
