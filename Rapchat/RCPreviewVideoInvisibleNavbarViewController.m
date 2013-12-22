//
//  RCPreviewVideoInvisibileNavbarViewController.m
//  Rapchat
//
//  Created by Michael Paris on 12/18/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import "RCPreviewVideoInvisibleNavbarViewController.h"

@interface RCPreviewVideoInvisibleNavbarViewController ()

@property (nonatomic, strong) UIColor *startingBackgroundColor;
@property (nonatomic, strong) UIImage *startingShadowImage;
@property (nonatomic, strong) UIImage *startingBackgroundImage;

@end

@implementation RCPreviewVideoInvisibleNavbarViewController

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
    
    // Add right navigation button to submit the video
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(submitClip)];
    self.navigationItem.rightBarButtonItem = submitButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Hide the navigation bar
    NSLog(@"Previewing video with URL: %@", self.videoURL);
    self.navigationController.navigationBarHidden = NO;
    [self makeNavBarInvisible];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self undoNavBarChanges];
    [super viewWillDisappear:animated];
}

- (void)undoNavBarChanges
{
    [self.navigationController.navigationBar setBackgroundImage:self.startingBackgroundImage forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = self.startingShadowImage;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.view.backgroundColor = self.startingBackgroundColor;
}

- (void)makeNavBarInvisible
{
    // Make the Navbar invisible
    self.navigationController.navigationBarHidden = NO;
    self.startingBackgroundImage = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.startingShadowImage = self.navigationController.navigationBar.shadowImage;
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.startingBackgroundColor = self.navigationController.view.backgroundColor;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark Actions
- (void)submitClip
{
    NSLog(@"Submitting Clip");
    RKObjectManager *objectManager = [RKObjectManager sharedManager];

    if ([[NSFileManager defaultManager] fileExistsAtPath:[self.thumbnailImageUrl absoluteString]]) {
//        [[NSFileManager defaultManager] removeItemAtPath:[self.thumbnailImageUrl absoluteString] error:nil];
        NSLog(@"File exists at path: %@", self.thumbnailImageUrl);
    }
    NSMutableURLRequest *request = [objectManager multipartFormRequestWithObject:nil
                                                                          method:RKRequestMethodPOST
                                                                            path:[NSString stringWithFormat:@"/sessions/%@/clips/", self.sessionId]
                                                                      parameters:nil
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
    NSLog(@"URLRequest: %@", request);
    
    RKObjectRequestOperation *operation = [objectManager objectRequestOperationWithRequest:request
                                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                 NSLog(@"Successfully uploaded video to server");
//                                                 [self.navigationController popToRootViewControllerAnimated:NO];
                                                 [self dismissViewControllerAnimated:YES completion:nil];
//                                                 [self performSegueWithIdentifier:@"BackToFeedSegue" sender:self];
//                                                 [self.navigationController popViewControllerAnimated:NO];
                                             } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                 NSLog(@"Error sending clip");
                                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error"
                                                                                                 message:[error localizedDescription]
                                                                                                delegate:nil
                                                                                       cancelButtonTitle:@"OK"
                                                                                       otherButtonTitles:nil, nil];
                                                 [alert show];
                                                 NSLog(@"Hit error: %@", error);
                                             }];
    [operation start];
}

@end
