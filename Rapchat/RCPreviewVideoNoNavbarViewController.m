//
//  RCPreviewVideoNoNavbarViewController.m
//  Rapchat
//
//  Created by Michael Paris on 12/18/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import "RCPreviewVideoNoNavbarViewController.h"

@interface RCPreviewVideoNoNavbarViewController ()

@end

@implementation RCPreviewVideoNoNavbarViewController

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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Hide the navigation bar
    self.navigationController.navigationBarHidden = YES;
}


#pragma mark Actions
- (IBAction)dismissModalVideoPreview:(UIButton *)sender {
    [self dismissViewControllerAnimated:self completion:nil];
}

-(IBAction)replyToVideo:(UIButton *)sender {
    [self performSegueWithIdentifier:@"ReplyToVideoSegue" sender:self];
}

@end