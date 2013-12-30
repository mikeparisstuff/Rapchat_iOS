//
//  RCCreateNewSessionViewController.h
//  Rapchat
//
//  Created by Michael Paris on 12/23/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import "RCViewController.h"

@interface RCNewSessionInfoViewController : RCViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) NSURL *thumbnailImageURL;

@end
