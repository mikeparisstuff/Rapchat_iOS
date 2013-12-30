//
//  RCRegisterScreenViewController.m
//  Rapchat
//
//  Created by Michael Paris on 12/13/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import "RCRegisterScreenViewController.h"
#import "RCProfile.h"

#import "RCUrlPaths.h"

@interface RCRegisterScreenViewController ()
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield2;

@end

@implementation RCRegisterScreenViewController

- (void)registerUserWithParameters:(NSDictionary *)profileParams
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager.HTTPClient setDefaultHeader:@"Authorization" value:nil];
    [objectManager postObject:nil
                         path:usersEndpoint
                   parameters:profileParams
                      success:^(RKObjectRequestOperation *operation, RKMappingResult* mappingResult) {
                          NSLog(@"Registering user: %@", profileParams);
                          RCProfile *registerProfile = [mappingResult firstObject];
                          if(registerProfile.accessToken) {
                              [[NSUserDefaults standardUserDefaults] setObject:registerProfile.accessToken forKey:@"accessToken"];
                              [objectManager.HTTPClient setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Token %@", registerProfile.accessToken]];
                              [[NSUserDefaults standardUserDefaults] synchronize];
                              [self performSegueWithIdentifier:@"Push To Home From Register Segue" sender:self];
                          }else {
                              NSLog(@"Error Registering Profile");
                          }
                      }failure:^(RKObjectRequestOperation *operation, NSError *error) {
                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error"
                                                                          message:[error localizedDescription]
                                                                         delegate:nil
                                                                cancelButtonTitle:@"OK"
                                                                otherButtonTitles:nil, nil];
                          [alert show];
                          NSLog(@"Hit error: %@", error);
                      }];
    
    
}

- (IBAction)registerButtonClicked {
    if ([self.passwordTextfield.text isEqualToString:self.passwordTextfield2.text]) {
        NSDictionary *profileParams = @{@"username":self.usernameTextfield.text,
                                        @"password":self.passwordTextfield.text,
                                        @"first_name":self.firstNameTextField.text,
                                        @"last_name":self.lastNameTextField.text,
                                        @"email":self.emailTextfield.text
                                        };
        [self registerUserWithParameters:profileParams];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password Error"
                                                        message:@"The passwords you entered do not match."
                                                       delegate:nil
                                              cancelButtonTitle:@"Try Again"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SegueToHomeFromRegisterScreen"]) {
        NSLog(@"Preparing for segue");
        self.navigationController.navigationBarHidden = YES;
        
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
    
    // Make Done button appear when on password2 box
    [self.passwordTextfield2 setReturnKeyType:UIReturnKeyDone];
    [self.passwordTextfield2 addTarget:self
                               action:@selector(registerButtonClicked)
                     forControlEvents:UIControlEventEditingDidEndOnExit];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
