//
//  RCTabBarController.m
//  Rapchat
//
//  Created by Michael Paris on 12/9/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import "RCTabBarController.h"

@interface RCTabBarController ()

@end

@implementation RCTabBarController

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
    
    // Set the button on the middle of the tabbar
    [self setCreateNewButtonOnMiddleOfTabBar];
}

- (void)setCreateNewButtonOnMiddleOfTabBar
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *buttonImage = [UIImage imageNamed:@"ic_create_new"];
    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    CGFloat heightDifference = buttonImage.size.height - self.tabBar.frame.size.height;
    if (heightDifference < 0)
        button.center = self.tabBar.center;
    else
    {
        CGPoint center = self.tabBar.center;
        center.y = center.y - heightDifference/2.0;
        button.center = center;
    }
    [button addTarget:self action:@selector(createNewButtonClicked:) forControlEvents:UIControlEventAllEvents];
    
    [self.view addSubview:button];
}

- (void)createNewButtonClicked:(id)sender
{
    [self performSegueWithIdentifier:@"CreateSegue" sender:sender];
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

@end
