//
//  RCReplyToSessionCameraViewController.m
//  Rapchat
//
//  Created by Michael Paris on 12/18/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import "RCReplyToSessionCameraViewController.h"
#import "RCPreviewFileViewController.h"

@interface RCReplyToSessionCameraViewController ()

@end

@implementation RCReplyToSessionCameraViewController

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
	// Do any additional setup after loading the view.
    
    UIBarButtonItem *rotateButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_spin"] style:UIBarButtonItemStylePlain target:self action:@selector(changeCamera:)];
    self.navigationItem.rightBarButtonItem = rotateButton;
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
    self.navigationController.navigationBarHidden = NO;
    [self makeNavBarInvisible];
}

- (void)makeNavBarInvisible
{
    // Make the Navbar invisible
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBar.translucent = NO;
    [super viewWillDisappear:animated];
}

#pragma mark Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"PreviewVideoSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[RCPreviewFileViewController class]]) {
            RCPreviewFileViewController *controller = segue.destinationViewController;
            controller.sessionId = self.sessionId;
            controller.videoURL = [self getVideoUrl];
            controller.thumbnailImageUrl = self.thumbnailImageUrl;
            NSLog(@"Prepared PreviewVideoSegue");
        }
    }
}
@end
