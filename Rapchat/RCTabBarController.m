//
//  RCTabBarController.m
//  Rapchat
//
//  Created by Michael Paris on 12/9/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import "RCTabBarController.h"
#define TABBAR_HEIGHT (49)

@interface RCTabBarController ()

@property (nonatomic, strong) UIButton *centerButton;
@property (nonatomic) BOOL isHidden;

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
    [[self.tabBar.items objectAtIndex:1] setEnabled:NO];
    [self setCreateNewButtonOnMiddleOfTabBar];
    
}

- (void)setCreateNewButtonOnMiddleOfTabBar
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
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
    self.centerButton = button;
    [self.view addSubview:button];
}

- (void)hideCenterButton
{
    [self.centerButton setHidden:YES];
    [self.centerButton setEnabled:NO];
}

- (void)showCenterButton
{
    [self.centerButton setHidden:NO];
    [self.centerButton setEnabled:YES];
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

- (BOOL)tabBarIsHidden
{
    return self.isHidden;
}

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    NSLog(@"setTabBarHidden:%d animated:%d", hidden, animated);
    
    if ( [self.view.subviews count] < 2 )
        return;
    
    UIView *contentView;
    
    if ( [[self.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]] )
        contentView = [self.view.subviews objectAtIndex:1];
    else
        contentView = [self.view.subviews objectAtIndex:0];
    
    
    if(hidden && !self.isHidden)
    {
        self.isHidden = YES;
        [self hideCenterButton];
        if(animated)
        {
            NSLog(@"HIDDEN - ANIMATED");
            
            [UIView animateWithDuration:0.2
                             animations:^{
                                 contentView.frame = self.view.bounds;
                                 
                                 self.tabBar.frame = CGRectMake(self.view.bounds.origin.x,
                                                                self.view.bounds.size.height,
                                                                self.view.bounds.size.width,
                                                                TABBAR_HEIGHT);
                             }
                             completion:^(BOOL finished) {
                                 self.tabBar.frame = CGRectMake(self.view.bounds.origin.x,
                                                                self.view.bounds.size.height,
                                                                self.view.bounds.size.width,
                                                                TABBAR_HEIGHT);
                             }];
        }
        else
        {
            NSLog(@"HIDDEN");
            
            contentView.frame = self.view.bounds;
            
            self.tabBar.frame = CGRectMake(self.view.bounds.origin.x,
                                           self.view.bounds.size.height,
                                           self.view.bounds.size.width,
                                           TABBAR_HEIGHT);
        }
    }
    else
    {
        if (self.isHidden) {
            
            self.tabBar.frame = CGRectMake(self.view.bounds.origin.x,
                                           self.view.bounds.size.height,
                                           self.view.bounds.size.width,
                                           0);
            self.isHidden = NO;
            [self showCenterButton];
            if(animated)
            {
                NSLog(@"NOT HIDDEN - ANIMATED");
                
                [UIView animateWithDuration:0.2
                                 animations:^{
                                     self.tabBar.frame = CGRectMake(self.view.bounds.origin.x,
                                                                    self.view.bounds.size.height - TABBAR_HEIGHT,
                                                                    self.view.bounds.size.width,
                                                                    TABBAR_HEIGHT);
                                 }   completion:^(BOOL finished) {
                                     contentView.frame = CGRectMake(self.view.bounds.origin.x,
                                                                    self.view.bounds.origin.y,
                                                                    self.view.bounds.size.width,
                                                                    self.view.bounds.size.height - TABBAR_HEIGHT);
                                 }];
            }
            else
            {
                NSLog(@"NOT HIDDEN");
                
                contentView.frame = CGRectMake(self.view.bounds.origin.x,
                                               self.view.bounds.origin.y,
                                               self.view.bounds.size.width,
                                               self.view.bounds.size.height - TABBAR_HEIGHT);
                
                self.tabBar.frame = CGRectMake(self.view.bounds.origin.x,
                                               self.view.bounds.size.height - TABBAR_HEIGHT,
                                               self.view.bounds.size.width,
                                               TABBAR_HEIGHT);
            }
        }
    }
}

@end
