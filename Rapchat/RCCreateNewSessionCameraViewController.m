//
//  RCCreateNewSessionCameraViewController.m
//  Rapchat
//
//  Created by Michael Paris on 12/18/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import "RCCreateNewSessionCameraViewController.h"
#import "RCPreviewVideoForCreationViewController.h"

@interface RCCreateNewSessionCameraViewController ()
@end

@implementation RCCreateNewSessionCameraViewController

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
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"PreviewVideoSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[RCPreviewVideoForCreationViewController class]]) {
            RCPreviewVideoForCreationViewController *controller = segue.destinationViewController;
            controller.videoURL = [self getVideoUrl];
            controller.thumbnailImageUrl = self.thumbnailImageUrl;
            controller.progressValue = self.timerProgress;
            controller.isBattle = self.isBattle;
            controller.battleUsername = self.battleUsername;
            NSLog(@"Prepared PreviewVideoSegue");
        }
    }
}

#pragma mark Actions
- (IBAction)changeBeatsButtonClicked {
    [self changeSong];
}

@end
