//
//  RCPreviewVideoForRapbackViewController.m
//  Rapchat
//
//  Created by Michael Paris on 12/18/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import "RCPreviewVideoForRapbackViewController.h"
#import "RCReplyToSessionCameraViewController.h"

@interface RCPreviewVideoForRapbackViewController ()

@end

@implementation RCPreviewVideoForRapbackViewController

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
    
    // Set close button
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_home"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissModalVideoPreview:)];
    self.navigationItem.leftBarButtonItem = closeButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self makeNavbarInvisible];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    // Hide the navigation bar
//    self.navigationController.navigationBarHidden = YES;
}

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ReplyToVideoSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[RCReplyToSessionCameraViewController class]]) {
            RCReplyToSessionCameraViewController *controller = segue.destinationViewController;
            controller.sessionId = self.sessionId;
            controller.isBattle = self.isBattle;
            NSLog(@"Prepared ReplyToVideoSegue");
        }
    }
}


#pragma mark Actions
- (IBAction)dismissModalVideoPreview:(UIButton *)sender {
    [self dismissViewControllerAnimated:self completion:nil];
}

-(IBAction)replyToVideo:(UIButton *)sender {
    [self performSegueWithIdentifier:@"ReplyToVideoSegue" sender:self];
}

@end
