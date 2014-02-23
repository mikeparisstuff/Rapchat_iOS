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
    
    // Set translucent no so that the statusbar color matches
    // THIS HAS CAUSED ISSUES SO WATCH IT
    [self.navigationController.navigationBar setTranslucent:YES];
    self.extendedLayoutIncludesOpaqueBars = NO;
    
	// Do any additional setup after loading the view, typically from a nib.
    
    if ([self.navigationController isKindOfClass:[RCNavigationController class]]) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStyleBordered target:self.navigationController action:@selector(toggleMenu)];
    }
    
    // Disable middle button with red button overlay
    
//    [self.tabBarController.tabBar setBackgroundColor:[UIColor colorWithHue:0.0 saturation:0.06 brightness:0.14 alpha:1.0]];
//    [self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithHue:0.0 saturation:0.06 brightness:0.14 alpha:1.0]];
}

- (void)searchButtonClicked:(id)sender
{
    NSLog(@"Search Clicked");
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"CreateSegue"]) {
//        if ([segue.destinationViewController isKindOfClass:[DoSoemthingVC class]]) {
//            DoSomethingVC *doVC = (DoSomethingVS *)segue.destinationViewController;
//            doVC.neededInfo = ....;
//        }
        NSLog(@"CreateSeque being prepared");
    }
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


@end
