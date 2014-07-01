//
//  RCSettingsPageViewController.m
//  Rapchat
//
//  Created by Michael Paris on 6/14/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCSettingsPageViewController.h"
#import "RCProfile.h"
#import "RCConstants.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

@interface RCSettingsPageViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (weak, nonatomic) IBOutlet UITextField *fullnameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextfield;

@end

@implementation RCSettingsPageViewController

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
    [self setTitle:@"Settings"];
    [self.navigationItem.leftBarButtonItem setImage:[UIImage imageNamed:@"ic_settings"]];
    [self.navigationItem.leftBarButtonItem setImageInsets:UIEdgeInsetsZero];
    [self.navigationItem.leftBarButtonItem setTarget:self];
    [self.navigationItem.leftBarButtonItem setAction:@selector(revealLeftVC)];
    UIBarButtonItem *friendsBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_users"] style:UIBarButtonItemStyleBordered target:self action:@selector(revealRightVC)];
    self.navigationItem.rightBarButtonItem = friendsBarItem;
    UIImageView *iv = [[UIImageView alloc] initWithFrame:self.tableView.frame];
    [iv setImage:[UIImage imageNamed:@"freedom_tower"]];
    [self.tableView setBackgroundView:iv];
    [self setProfileInformation];
}

- (void)setProfileInformation
{
    NSLog(@"Setting Profile Information in Settings");
    NSUserDefaults *uds = [NSUserDefaults standardUserDefaults];
//    NSDictionary *myProfile = (NSDictionary *)[uds objectForKey:USER_DEFAULT_PROFILE_KEY];
    self.emailTextfield.text = [uds stringForKey:@"email"];
    self.fullnameTextfield.text = [NSString stringWithFormat:@"%@ %@",  [uds stringForKey:@"first_name"], [uds stringForKey:@"last_name"]];
    self.usernameTextfield.text = [uds stringForKey:@"username"];
    self.phoneTextfield.text = [uds stringForKey:@"phone"];
    [self.profilePictureImageView setImageWithURL:[NSURL URLWithString:[uds stringForKey:@"profile_picture_url"]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//- (void)setTextFieldDelegates
//{
//    self.usernameTextfield.delegate = self;
//    self.fullnameTextfield.delegate = self;
//    self.emailTextfield.delegate = self;
//    self.phoneTextfield.delegate = self;
//}

#pragma mark - Tableview Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"IndexPath Section %ld, Row %ld", (long)indexPath.section, (long)indexPath.row);
    switch (indexPath.section) {
        case 1:
            switch (indexPath.row) {
                case 0:
                    NSLog(@"Edit Username");
                    break;
                case 1:
                    NSLog(@"Edit Name");
                    break;
                case 2:
                    NSLog(@"Edit Email");
                    break;
                case 3:
                    NSLog(@"Edit Phonenumber");
                    break;
                default:
                    break;
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 0:
                    NSLog(@"Support");
                    break;
                case 1:
                    NSLog(@"Privacy Policy");
                    break;
                case 2:
                    NSLog(@"Terms of Use");
                    break;
                default:
                    break;
            }
            break;
        case 3:
            switch (indexPath.row) {
                case 0:
                    // Log Out
                    NSLog(@"Logging Out");
                    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"Are you sure you would like to logout?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
                    av.delegate = self;
                    [av show];
                    break;
            }
            break;
        default:
            break;
    }
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"textFieldShouldReturn");
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            NSLog(@"Cancel Logout");
            break;
        case 1:
            NSLog(@"Logging Out");
            [self logout];
            break;
        default:
            break;
    }
}

#pragma mark - Logout
- (void)logout
{
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(gotoLogin)]) {
        
        // Remove Login Details From UserDefaults
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"accessToken"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // Remove this modal view
        [self dismissViewControllerAnimated:YES completion:nil];
        
        // Call method in AppDelegate to go to login screen
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(gotoLogin)];
    }
}


@end
