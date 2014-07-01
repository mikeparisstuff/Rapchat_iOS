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
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStyleBordered target:self.navigationController action:@selector(toggleRevealLeft)];
    }
//    [self.navigationItem.leftBarButtonItem setImage:[UIImage imageNamed:@"ic_menu"]];
//    [self.navigationItem.leftBarButtonItem setImageInsets:UIEdgeInsetsZero];
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

#pragma mark - Awesome Menu
- (AwesomeMenu *)createAwesomeMenu
{
    UIImage *storyMenuItemImage = [UIImage imageNamed:@"bg-new-battle.png"];
    UIImage *storyMenuItemImagePressed = [UIImage imageNamed:@"bg-new-battle.png"];
    UIImage *starImage = [UIImage imageNamed:@"ic_versus.png"];
    UIImage *freestyleImage = [UIImage imageNamed:@"ic_stack-music"];
    AwesomeMenuItem *starMenuItem1 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                                           highlightedImage:storyMenuItemImagePressed
                                                               ContentImage:starImage
                                                    highlightedContentImage:nil];
    
    AwesomeMenuItem *starMenuItem2 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                                           highlightedImage:storyMenuItemImagePressed
                                                               ContentImage:freestyleImage
                                                    highlightedContentImage:nil];
    // the start item, similar to "add" button of Path
    AwesomeMenuItem *startItem = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg-awesome_menu.png"]
                                                       highlightedImage:[UIImage imageNamed:@"bg-awesome_menu.png"]
                                                           ContentImage:[UIImage imageNamed:@"ic_microphone_red.png"]
                                                highlightedContentImage:[UIImage imageNamed:@"ic_microphone_red.png"]];
    AwesomeMenu *menu = [[AwesomeMenu alloc] initWithFrame:self.view.frame startItem:startItem optionMenus:@[starMenuItem1, starMenuItem2]];
    menu.delegate = self;
    menu.startPoint = CGPointMake(self.view.frame.size.width - 40, self.view.frame.size.height - 40);
    menu.menuWholeAngle = M_PI_2;
    menu.rotateAngle = -M_PI_2;
    menu.farRadius = 90.0;
    menu.nearRadius = 60.0;
    menu.endRadius = 75.0;
    return menu;
}


@end
