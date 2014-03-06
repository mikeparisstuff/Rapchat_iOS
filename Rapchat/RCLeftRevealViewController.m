//
//  RCLeftRevealViewController.m
//  Rapchat
//
//  Created by Michael Paris on 3/2/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCLeftRevealViewController.h"
#import "RCUrlPaths.h"
#import <SVProgressHUD.h>
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "RCProfile.h"
#import "RCEditProfileViewController.h"

@interface RCLeftRevealViewController ()

@property (nonatomic) RCProfile *myProfile;
@property (weak, nonatomic) IBOutlet UIButton *numberOfRapsButton;
@property (weak, nonatomic) IBOutlet UIButton *numberOfLikesButton;
@property (weak, nonatomic) IBOutlet UIButton *numberOfFriendsButton;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@end

@implementation RCLeftRevealViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self loadProfile];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Update UI
- (void)setProfileHeaderInfo
{
    self.profilePictureImageView.layer.cornerRadius  = 5.0;
    self.profilePictureImageView.layer.masksToBounds = YES;
    [self.numberOfFriendsButton setTitle:[NSString stringWithFormat:@"%@", self.myProfile.numberOfFriends] forState:UIControlStateNormal];
    [self.numberOfLikesButton setTitle:[NSString stringWithFormat:@"%@", self.myProfile.numberOfLikes] forState:UIControlStateNormal];
    [self.numberOfRapsButton setTitle:[NSString stringWithFormat:@"%@", self.myProfile.numberOfRaps] forState:UIControlStateNormal];
    [self.usernameLabel setText:self.myProfile.user.username];
    if (self.myProfile.profilePictureURL) {
        [self.profilePictureImageView setImageWithURL:self.myProfile.profilePictureURL
                          usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
}

#pragma mark Actions
- (IBAction)gotoLive:(id)sender {
    if ([self.delegate respondsToSelector:@selector(gotoLive)]) {
        [self.delegate gotoLive];
    }
}
- (IBAction)gotoStage:(id)sender {
    if ([self.delegate respondsToSelector:@selector(gotoStage)]) {
        [self.delegate gotoStage];
    }
}
- (IBAction)gotoProfile:(id)sender {
    if ([self.delegate respondsToSelector:@selector(gotoProfile)]) {
        [self.delegate gotoProfile];
    }
}
- (IBAction)gotoFeedback:(id)sender {
    if ([self.delegate respondsToSelector:@selector(gotoFeedback)]) {
        [self.delegate gotoFeedback];
    }
}


#pragma mark API
- (void)loadProfile
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
//    [SVProgressHUD showWithStatus:@"" maskType:SVProgressHUDMaskTypeGradient];
    [objectManager getObjectsAtPath:myProfileEndpoint
                         parameters:nil
                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                self.myProfile = [mappingResult firstObject];
                                NSLog(@"Got Profile: %@", self.myProfile.user.username);
                                [self setProfileHeaderInfo];
                            }failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                [SVProgressHUD showErrorWithStatus:@"Network Error"];
                            }];
}

#pragma mark Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToEditProfile"]) {
        if ([segue.destinationViewController isKindOfClass:[RCEditProfileViewController class]]) {
            RCEditProfileViewController *controller = segue.destinationViewController;
            controller.profile = self.myProfile;
        }
    }
}

@end
