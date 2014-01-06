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
    
    self.showTabBar = YES;
	// Do any additional setup after loading the view, typically from a nib.
    
    if ([self.navigationController isKindOfClass:[RCNavigationController class]]) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self.navigationController action:@selector(toggleMenu)];
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
    [self setTabBarVisible];
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)setTabBarVisible
{
    if (self.showTabBar) {
        RCTabBarController *tabBarController = (RCTabBarController *)self.tabBarController;
        [tabBarController setTabBarHidden:NO animated:YES];
    } else {
        RCTabBarController *tabBarController = (RCTabBarController *)self.tabBarController;
        [tabBarController setTabBarHidden:YES animated:YES];
    }
}

@end
