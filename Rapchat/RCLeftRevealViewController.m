//
//  RCLeftRevealViewController.m
//  Rapchat
//
//  Created by Michael Paris on 3/2/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCLeftRevealViewController.h"
#import "RCUrlPaths.h"
#import "RCConstants.h"
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
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *feedButton;
@property (weak, nonatomic) IBOutlet UIButton *feedbackButton;
@property (weak, nonatomic) IBOutlet UIButton *stageButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
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
//    UIImage *patternImage = [UIImage imageNamed:@"grey_washed"];
//    self.view.backgroundColor = [UIColor colorWithPatternImage:patternImage];
    [self setHeaderStyle];
    [self setButtonStyles];
}

- (void)setHeaderStyle
{
    self.headerView.layer.cornerRadius = 10.0;
    self.headerView.layer.masksToBounds = YES;
    self.headerView.clipsToBounds = NO;
    self.headerView.layer.shadowColor = [[UIColor whiteColor] CGColor];
    self.headerView.layer.shadowOffset = CGSizeMake(0,3);
    self.headerView.layer.shadowOpacity = 0.5;
}

- (void)setButtonStyles
{
    self.stageButton.clipsToBounds = NO;
    self.stageButton.layer.masksToBounds = YES;
    self.stageButton.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.stageButton.layer.shadowOffset = CGSizeMake(0,3);
    self.stageButton.layer.shadowOpacity = 0.5;
    self.stageButton.layer.cornerRadius = self.stageButton.frame.size.width/2;
    
    self.feedbackButton.clipsToBounds = NO;
    self.feedbackButton.layer.masksToBounds = YES;
    self.feedbackButton.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.feedbackButton.layer.shadowOffset = CGSizeMake(0,3);
    self.feedbackButton.layer.shadowOpacity = 0.5;
    self.feedbackButton.layer.cornerRadius = self.stageButton.frame.size.width/2;
    
    self.settingsButton.clipsToBounds = NO;
    self.settingsButton.layer.masksToBounds = YES;
    self.settingsButton.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.settingsButton.layer.shadowOffset = CGSizeMake(0,3);
    self.settingsButton.layer.shadowOpacity = 0.5;
    self.settingsButton.layer.cornerRadius = self.stageButton.frame.size.width/2;
    
    self.feedButton.clipsToBounds = NO;
    self.feedButton.layer.masksToBounds = YES;
    self.feedButton.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.feedButton.layer.shadowOffset = CGSizeMake(0,3);
    self.feedButton.layer.shadowOpacity = 0.5;
    self.feedButton.layer.cornerRadius = self.stageButton.frame.size.width/2;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Update UI
- (void)setProfileHeaderInfo
{
//    self.profilePictureImageView.layer.cornerRadius  = 5.0;
//    self.profilePictureImageView.layer.masksToBounds = YES;
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

- (IBAction)gotoSettings:(id)sender {
    if ([self.delegate respondsToSelector:@selector(gotoSettings)]) {
        [self.delegate gotoSettings];
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
                                [self saveProfile];
                            }failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                [SVProgressHUD showErrorWithStatus:@"Network Error"];
                            }];
}

- (void)saveProfile
{
    [[NSUserDefaults standardUserDefaults] setValuesForKeysWithDictionary:@{@"username": self.myProfile.user.username, @"first_name": self.myProfile.user.firstName, @"last_name": self.myProfile.user.lastName, @"phone_number": self.myProfile.phoneNumber, @"email": self.myProfile.user.email, @"profile_picture_url": [self.myProfile.profilePictureURL absoluteString]}];
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
