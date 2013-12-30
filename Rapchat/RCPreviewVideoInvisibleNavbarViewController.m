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
//    [self makeNavBarInvisible];
}

- (void)viewWillDisappear:(BOOL)animated
{
//    [self undoNavBarChanges];
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



@end
