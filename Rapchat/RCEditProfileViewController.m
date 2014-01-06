//
//  RCEditProfileViewController.m
//  Rapchat
//
//  Created by Michael Paris on 1/4/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCEditProfileViewController.h"
#import "RCUrlPaths.h"
#import <SVProgressHUD.h>

@interface RCEditProfileViewController ()
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (nonatomic) NSUInteger previousPhoneNumberLength;

@end

@implementation RCEditProfileViewController

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
    
    [self.phoneTextField addTarget:self action:@selector(phoneNumberChanged) forControlEvents:UIControlEventEditingChanged];
    self.title = @"Edit Profile";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshUI];
    self.previousPhoneNumberLength = [self.phoneTextField.text length];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshUI
{
    [self.firstNameTextField setText:self.profile.user.firstName];
    [self.lastNameTextField setText:self.profile.user.lastName];
    [self.emailTextField setText:self.profile.user.email];
    [self.phoneTextField setText:self.profile.phoneNumber];
}

#pragma mark Actions

- (IBAction)updateProfile:(UIButton *)sender {
    [self.view endEditing:YES];
    if ([self validateInfo]) {
        RKObjectManager *objectManager = [RKObjectManager sharedManager];
        [SVProgressHUD showWithStatus:@"Updating" maskType:SVProgressHUDMaskTypeGradient];
        [objectManager putObject:nil
                            path:myProfileEndpoint
                      parameters:@{@"first_name": self.firstNameTextField.text,
                                   @"last_name": self.lastNameTextField.text,
                                   @"email": self.emailTextField.text,
                                   @"phone_number": self.phoneTextField.text}
                         success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                             self.profile = [mappingResult firstObject];
                             [SVProgressHUD showSuccessWithStatus:@"Success"];
                             [self.navigationController popViewControllerAnimated:YES];
                         } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                             [self refreshUI];
                             [SVProgressHUD showErrorWithStatus:@"Failed"];
                         }];
    }
}

# pragma mark validation
- (void)phoneNumberChanged
{
    NSLog(@"Phone Number Changed");
    // Append a - to the number when it is 3 or 7 characters long
    if ( ([self.phoneTextField.text length] == 3 || [self.phoneTextField.text length] == 7) &&  [self.phoneTextField.text length] > self.previousPhoneNumberLength) {
        [self.phoneTextField setText:[self.phoneTextField.text stringByAppendingString:@"-"]];
    }
    self.previousPhoneNumberLength = [self.phoneTextField.text length];
}

- (BOOL)validateInfo
{
    if ([self.phoneTextField.text length]) {
        NSError *error = NULL;
        NSRegularExpression *phoneRegEx = [[NSRegularExpression alloc] initWithPattern:@"^\\d{3}-\\d{3}-\\d{4}$"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        NSString *string = self.phoneTextField.text;
        if (![phoneRegEx numberOfMatchesInString:string options:0 range:NSMakeRange(0, [string length])] == 1) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Phone Number"
                                                            message:@"Should be of form xxx-xxx-xxxx"
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
            [alert show];
            return NO;
        }
    }
    return YES;
}

@end
