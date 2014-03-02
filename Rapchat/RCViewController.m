//
//  RCViewController.m
//  Rapchat
//
//  Created by Michael Paris on 12/8/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import "RCViewController.h"
#import "RCTabBarController.h"
#import "RCNavigationController.h"

@interface RCViewController ()

@end

@implementation RCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.extendedLayoutIncludesOpaqueBars = NO;
    
	// Do any additional setup after loading the view, typically from a nib.
    
    if ([self.navigationController isKindOfClass:[RCNavigationController class]]) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStyleBordered target:self.navigationController action:@selector(toggleMenu)];
    }
}

- (void)searchButtonClicked:(id)sender
{
    NSLog(@"Search Clicked");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[self.navigationController viewControllers] count] > 1) {
        NSLog(@"Nav Controller is not nil");
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_back"] style:UIBarButtonItemStylePlain target:self action:@selector(backPressed)];
        self.navigationItem.leftBarButtonItem = backButton;
    }
}

- (void)backPressed
{
    if ([[self.navigationController viewControllers] count] > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)makeNavbarInvisible
{
    // Make the Navbar invisible
    if (self.navigationController) {
        self.navigationController.navigationBarHidden = NO;
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                      forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = [UIImage new];
        //    self.navigationController.navigationBar.translucent = YES;
        self.navigationController.view.backgroundColor = [UIColor clearColor];
    }
}


@end
