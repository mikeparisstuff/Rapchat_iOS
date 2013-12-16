//
//  RCNavigationController.m
//  Rapchat
//
//  Created by Michael Paris on 12/9/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import "RCNavigationController.h"

@interface RCNavigationController ()

@end

@implementation RCNavigationController

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

-(UIStatusBarStyle)preferredStatusBarStyle
{
    // Change the color of the status bar items
    return UIStatusBarStyleLightContent;
}


@end
