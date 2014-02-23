//
//  RCEditProfileViewController.h
//  Rapchat
//
//  Created by Michael Paris on 1/4/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCViewController.h"
#import "RCProfile.h"

@interface RCEditProfileViewController : RCViewController <UIImagePickerControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) RCProfile *profile;

@end
