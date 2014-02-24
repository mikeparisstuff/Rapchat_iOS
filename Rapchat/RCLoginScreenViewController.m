//
//  RCLoginScreenViewController.m
//  Rapchat
//
//  Created by Michael Paris on 12/13/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import "RCLoginScreenViewController.h"
#import "RCAccessToken.h"

#import "RCUrlPaths.h"

@interface RCLoginScreenViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) RCAccessToken *token;

@end

@implementation RCLoginScreenViewController

- (void) logInWithUsername:(NSString *)username password:(NSString *)password
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [objectManager.HTTPClient setDefaultHeader:@"Authorization" value:nil];
    
    [objectManager postObject:nil
                         path:obtainTokenEndpoint
                   parameters:@{@"username": username, @"password": password}
                      success: ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                          NSLog(@"Logging in user with username: %@", username);
                          self.token = [mappingResult firstObject];
                          if( self.token ) {
                              NSLog(@"Logged in with token: %@", self.token.accessToken);
                              [userDefaults setObject:self.token.accessToken forKey:@"accessToken"];
                              [userDefaults synchronize];
//                              RKObjectManager *objectManager = [RKObjectManager sharedManager];
                              [objectManager.HTTPClient setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Token %@", self.token.accessToken]];
                              // May not be the best way to get rid of the nav bar
                              [self performSegueWithIdentifier:@"SegueToHomeFromLoginScreen" sender:self];
                          } else {
                              NSLog(@"Access Token was nil");
                          }
                      }failure:^(RKObjectRequestOperation *operation, NSError *error) {
                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not find you"
                                                                          message:@"Sorry, we were unable to log you in with those credentials."
                                                                         delegate:nil
                                                                cancelButtonTitle:@"Close"
                                                                otherButtonTitles:nil, nil];
                          [alert show];
                          NSLog(@"Hit error: %@", error);
                      }];
}

- (IBAction)loginButtonClicked {
    [self logInWithUsername:self.usernameTextfield.text password:self.passwordTextfield.text];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Push To Home From Login Segue"]) {
        NSLog(@"Preparing for segue");
        self.navigationController.navigationBarHidden = YES;
//        if ([segue.destinationViewController isKindOfClass:[RCViewController class]]) {
//            TextStatsViewController *tsvc = (TextStatsViewController *)segue.destinationViewController;
//            tsvc.textToAnalyze = self.body.textStorage;
//        }
    }
}

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
//    [self.passwordTextfield setDelegate:self];
    [self.passwordTextfield setReturnKeyType:UIReturnKeyDone];
    [self.passwordTextfield addTarget:self
                       action:@selector(loginButtonClicked)
             forControlEvents:UIControlEventEditingDidEndOnExit];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Actions
- (IBAction)textFieldShouldReturn:(UITextField *)sender {
    [self.view endEditing:YES];
}

@end
