//
//  RCAppDelegate.m
//  Rapchat
//
//  Created by Michael Paris on 12/8/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import "RCAppDelegate.h"
#import <RestKit/RestKit.h>
#import "RCRestkitClient.h"
#import "RCFeedViewController.h"

@interface RCAppDelegate () <PKRevealing>

@property (nonatomic, strong, readwrite) PKRevealController *revealController;

@end


@implementation RCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:226.0/255.0 green:66.0/255.0 blue:51.0/255.0 alpha:1.0]];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithHue:0.0 saturation:0.06 brightness:0.14 alpha:1.0]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:24.0]}];
    //[UIColor colorWithHue:0.0 saturation:0.06 brightness:0.14 alpha:1.0] -- Dark
    //[UIColor colorWithRed:231.0/255.0 green:76.0/255.0 blue:60.0/255.0 alpha:1.0] -- Red
    //[UIColor colorWithRed:87.0/255.0 green:142.0/255.0 blue:160.0/255.0 alpha:1.9] - Teal
    //[UIColor colorWithRed:0.0/255.0 green:54.0/255.0 blue:71.0/255.0 alpha:1.9] - Dark Teal
    //[UIColor colorWithRed:206.0/255.0 green:90.0/255.0 blue:17.0/255.0 alpha:1.0] - orange
    //[UIColor colorWithRed:199.0/255.0 green:65.0/255.0 blue:0.0/255.0 alpha:1.0] - Dark orange

    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:255.0/255.0 green:84.0/255.0 blue:66.0/255.0 alpha:0.8];
    //[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:0.8]
    shadow.shadowOffset = CGSizeMake(0, 1);
    //[UIColor colorWithRed:231.0/255.0 green:76.0/255.0 blue:60.0/255.0 alpha:1.0]
                                                           
//                                                           NSShadowAttributeName: shadow}];
    
    [RCRestkitClient setupRestkit];
    
    // Checks to see if we have an accessToken and skips login page if we do
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:nil];
    
    NSString* controllerId;
    // If we already have a accessToken for you, then skip the login page
    if ([NSUserDefaults.standardUserDefaults objectForKey:@"accessToken"])
    {
        controllerId = @"MainStart";

    }
    else
    {
        controllerId = @"LoginStart";
    }
    self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:controllerId];
    
    [NSThread sleepForTimeInterval:1.0];
    [self.window makeKeyAndVisible];
    return YES;
    
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark PKRevealing

- (void)revealController:(PKRevealController *)revealController didChangeToState:(PKRevealControllerState)state
{
    NSLog(@"%@ (%d)", NSStringFromSelector(_cmd), (int)state);
}

- (void)revealController:(PKRevealController *)revealController willChangeToState:(PKRevealControllerState)next
{
    PKRevealControllerState current = revealController.state;
    NSLog(@"%@ (%d -> %d)", NSStringFromSelector(_cmd), (int)current, (int)next);
}

#pragma mark Helpers

- (UIViewController *)frontViewController
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:nil];
    UIViewController* controller = [storyboard instantiateViewControllerWithIdentifier:@"MainStart"];
    return controller;
}

- (UIViewController *)leftViewController
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:nil];
    UIViewController* controller = [storyboard instantiateViewControllerWithIdentifier:@"ProfileController"];
    return controller;
}

- (UIViewController *)rightViewController
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:nil];
    UIViewController* controller = [storyboard instantiateViewControllerWithIdentifier:@"FindFriendsController"];
    return controller;
}

@end
