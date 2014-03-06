//
//  RCPreviewVideoForCreationViewController.m
//  Rapchat
//
//  Created by Michael Paris on 12/23/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import "RCPreviewVideoForCreationViewController.h"
#import "RCNewSessionInfoViewController.h"
#import "RCVideoReencoder.h"
#import "RCProgressView.h"
#import "RCUrlPaths.h"
#import "RCConstants.h"
#import <SVProgressHUD.h>

@interface RCPreviewVideoForCreationViewController ()

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (nonatomic) NSString *startingTitle;

// Video Reencoder
@property (nonatomic) RCVideoReencoder *videoReencoder;

@end

@implementation RCPreviewVideoForCreationViewController

static NSString *NEW_SESSION_INFO_SEGUE =  @"NewSessionInfoSegue";

- (BOOL)prefersStatusBarHidden
{
    return YES;
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
    self.navigationController.navigationBarHidden = NO;
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    
    self.videoReencoder = [[RCVideoReencoder alloc] init];
    [self.videoReencoder addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
    self.startingTitle = [self.titleTextField.text lowercaseString];
    
	// Do any additional setup after loading the view.
    
//    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(nextButtonClicked)];
//    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:NEW_SESSION_INFO_SEGUE]) {
        if ([segue.destinationViewController isKindOfClass:[RCNewSessionInfoViewController class]]) {
            RCNewSessionInfoViewController *controller = segue.destinationViewController;
            controller.videoURL = self.videoURL;
            controller.thumbnailImageURL = self.thumbnailImageUrl;
            NSLog(@"Prepared NewSessionInfo");
        }
    }
}

#pragma mark Text Field delegate
- (IBAction)titleViewEndFocus:(UITextField *)sender {
    [self.view endEditing:YES];
}

#pragma mark Actions
- (IBAction)nextButtonClicked:(UIButton *)sender {
    [self performSegueWithIdentifier:NEW_SESSION_INFO_SEGUE sender:self];
}

- (IBAction)submitButtonClicked:(UIButton *)sender {
    if ([self validateFields]) {
        [self.submitButton setEnabled:NO];
        [self.videoReencoder loadAssetToReencode:self.videoURL];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter a Title"
                                                        message:@"Please enter a title for the session"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (BOOL)validateFields
{
    if ([self.titleTextField.text length] > 0 && ![[self.titleTextField.text lowercaseString] isEqualToString:self.startingTitle]) {
        return YES;
    }
    return NO;
}

#pragma mark Listeners
#pragma mark Observers
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"] && [[change objectForKey:NSKeyValueChangeNewKey] isEqualToString:RCVideoReencoderDidFinishSuccessfully]) {
        //        NSLog(@"keypath: %@", keyPath);
        self.videoURL = [NSURL fileURLWithPath:self.videoReencoder.outputURL];
        if (self.isBattle && !self.battleUsername) {
            // PICK USER TO SEND BATTLE TO HERE
            NSLog(@"Need to pick battle username before submitting clip");
        }
        [self submitSession];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark API Calls
- (void)submitSession
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSError *error = [[NSError alloc] init];
    NSDictionary *params = (self.isBattle) ? @{@"title": self.titleTextField.text,@"is_battle": @YES, @"battle_receiver": self.battleUsername} : @{@"title": self.titleTextField.text,@"is_battle": @NO};
    [SVProgressHUD showWithStatus:@"Creating Session" maskType:SVProgressHUDMaskTypeGradient];
    NSMutableURLRequest *request = [objectManager multipartFormRequestWithObject:nil
                                                                          method:RKRequestMethodPOST
                                                                            path:mySessionsEndpoint
                                                                      parameters:params
                                                       constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                           [formData appendPartWithFileData:[NSData dataWithContentsOfURL:self.videoURL]
                                                                                       name:@"clip"
                                                                                   fileName:@"movie.mp4"
                                                                                   mimeType:@"video/mp4"];
                                                           //                                                           NSLog(@"Submitting thumbnail: %@", self.thumbnailImageUrl);
                                                           [formData appendPartWithFileData:[NSData dataWithContentsOfFile:[self.thumbnailImageUrl absoluteString]]
                                                                                       name:@"thumbnail"
                                                                                   fileName:@"thumbnail.jpg"
                                                                                   mimeType:@"image/jpg"];
                                                           //                                                            NSLog(@"Form Data: %@", formData);
                                                       }];
    RKObjectRequestOperation *operation = [objectManager objectRequestOperationWithRequest:request
                                                                                   success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                                                       [SVProgressHUD showSuccessWithStatus:@"Success"];
                                                                                        [self dismissViewControllerAnimated:YES completion:nil];
                                                                                   }
                                                                                   failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                                                       [SVProgressHUD showErrorWithStatus:@"Error"];
                                                                                       [self.submitButton setEnabled:YES];
                                                                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                                                       message:@"Sorry there was a problem uploading the clip. Please try again"
                                                                                                                                      delegate:nil
                                                                                                                             cancelButtonTitle:@"OK"
                                                                                                                             otherButtonTitles:nil, nil];
                                                                                       [alert show];
                                                                                   }];
    [operation start];
    
}


@end
