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
#import "RCSettingsPageViewController.h"
#import "Flurry.h"

@interface RCAppDelegate () <PKRevealing>

@property (nonatomic, strong, readwrite) PKRevealController *revealController;

@end


@implementation RCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Setup Flurry
    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:@"9FVNYJQ8Y5SN575KWTVN"];
    
    
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
    
    // If we already have a accessToken for you, then skip the login page
    if ([NSUserDefaults.standardUserDefaults objectForKey:@"accessToken"])
    {
        [self initializeMainScreen];
    }
    else
    {
        [self initializeLoginScreen];
    }
    
    [self disableFrontPanning];
    
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

#pragma mark RCNavBarDelegate

- (void) toggleRevealControllerLeft
{
    [self.revealController showViewController:self.revealController.leftViewController];
}

- (void) toggleRevealControllerRight
{
    [self.revealController showViewController:self.revealController.rightViewController];
}

#pragma mark RCRightRevealVCProtocol

- (void) pushToPresentationMode
{
    [self.revealController enterPresentationModeAnimated:YES
                                              completion:^(BOOL finished) {
                                                  NSLog(@"In Presentation Mode");
                                              }];
}

- (void) pushBackFromPresentationMode
{
    if ([self.revealController isPresentationModeActive]) {
        [self.revealController resignPresentationModeEntirely:NO
                                                     animated:YES
                                                   completion:^(BOOL finished) {
                                                       NSLog(@"Resigned Presentation mode");
                                                   }];
    }
    
}

#pragma mark RCLeftRevealVCProtocol
- (void)gotoSettings
{
    NSLog(@"Settings");
    UIStoryboard *storybard = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:nil];
    RCSettingsPageViewController *controller = (RCSettingsPageViewController *)[storybard instantiateViewControllerWithIdentifier:@"SettingsPage"];
    [self presentViewController:controller];
}

- (void)gotoLive
{
    NSLog(@"Live");
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:nil];
    RCFeedViewController* controller = (RCFeedViewController *)[storyboard instantiateViewControllerWithIdentifier:@"LiveFeedController"];
    [self presentViewController:controller];
}

- (void)gotoStage
{
    NSLog(@"Stage");
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:nil];
    RCFeedViewController* controller = (RCFeedViewController *)[storyboard instantiateViewControllerWithIdentifier:@"CompletedFeedController"];
    [self presentViewController:controller];
}

- (void)gotoProfile
{
    NSLog(@"Profile");
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:nil];
    UIViewController* controller = [storyboard instantiateViewControllerWithIdentifier:@"ProfileController"];
    [self presentViewController:controller];
}

- (void)gotoFeedback
{
    NSLog(@"Feedback");
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:nil];
    UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"FeedbackController"];
    [self presentViewController:controller];
}

- (void) presentViewController:(UIViewController *)vc
{
    [self.revealController enterPresentationModeAnimated:YES completion:^(BOOL finished) {
        RCNavigationController *mainController = (RCNavigationController *)self.revealController.frontViewController;
        [mainController setViewController:vc];
        [NSThread sleepForTimeInterval:.3];
        [self.revealController resignPresentationModeEntirely:YES animated:YES completion:^(BOOL finished) {
            NSLog(@"Should be focused on center");
        }];
    }];
}

#pragma mark - Handle Login Logic
- (void)gotoLogin
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:nil];
    UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"LoginStart"];
    [self.revealController enterPresentationModeAnimated:YES completion:^(BOOL finished) {
        [self.revealController setFrontViewController:controller];
        self.revealController.frontViewController.revealController.recognizesPanningOnFrontView = NO;
        [NSThread sleepForTimeInterval:.3];
        [self.revealController resignPresentationModeEntirely:YES animated:YES completion:^(BOOL finished) {
            NSLog(@"Should be focused on center");
        }];
    }];
}

- (void)gotoMainScreenFromLogin
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:nil];
    UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"LoginStart"];
    [self.revealController setFrontViewController:[self frontViewController]];
    [self.revealController setRightViewController:[self rightViewController]];
    [self.revealController setLeftViewController:[self leftViewController]];
    self.revealController.frontViewController.revealController.recognizesPanningOnFrontView = YES;
    
//    [self.revealController enterPresentationModeAnimated:YES completion:^(BOOL finished) {
//        [self.revealController setFrontViewController:[self frontViewController]];
//        [self.revealController setRightViewController:[self rightViewController]];
//        self.revealController.frontViewController.revealController.recognizesPanningOnFrontView = YES;
//        [NSThread sleepForTimeInterval:.3];
//        [self.revealController resignPresentationModeEntirely:YES animated:YES completion:^(BOOL finished) {
//            NSLog(@"Should be focused on center");
//            [self.revealController setLeftViewController:[self leftViewController]];
//            
//        }];
//    }];
}

- (void)initializeMainScreen
{
    //controllerId = @"MainStart";
    // Reveal controller
    UIViewController *frontViewController = [self frontViewController];
    
    //        UINavigationController *frontNavigationController = [[UINavigationController alloc] initWithRootViewController:frontViewController];
    
    //        UIViewController *rightViewController = [[UIViewController alloc] init];
    //        rightViewController.view.backgroundColor = [UIColor redColor];
    
    // Step 2: Instantiate.
    self.revealController = [PKRevealController revealControllerWithFrontViewController:frontViewController
                                                                     leftViewController:[self leftViewController]
                                                                    rightViewController:[self rightViewController]];
    // Step 3: Configure.
    self.revealController.delegate = self;
    self.revealController.animationDuration = 0.25;
    [self.revealController setMinimumWidth:85.0 maximumWidth:85.0 forViewController:self.revealController.leftViewController];
    [self.revealController setMinimumWidth:300.0 maximumWidth:320.0 forViewController:self.revealController.rightViewController];
    
    // Step 4: Apply.
    self.window.rootViewController = self.revealController;
}

- (void)initializeLoginScreen
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:nil];
    self.revealController = [PKRevealController revealControllerWithFrontViewController:[storyboard instantiateViewControllerWithIdentifier:@"LoginStart"] leftViewController:[[UIViewController alloc] init]];

    // Step 3: Configure.
    self.revealController.delegate = self;
    self.revealController.animationDuration = 0.25;
    [self.revealController setMinimumWidth:300.0 maximumWidth:320.0 forViewController:self.revealController.leftViewController];
    [self.revealController setMinimumWidth:300.0 maximumWidth:320.0 forViewController:self.revealController.rightViewController];
    self.revealController.frontViewController.revealController.recognizesPanningOnFrontView = NO;
    self.window.rootViewController = self.revealController;
}

#pragma mark Helpers

- (UIViewController *)frontViewController
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:nil];
    RCNavigationController* controller = [storyboard instantiateViewControllerWithIdentifier:@"MainStart"];
    controller.revealDelegate = self;
    return controller;
}

- (UIViewController *)leftViewController
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:nil];
    RCLeftRevealViewController* controller = [storyboard instantiateViewControllerWithIdentifier:@"LeftRevealVC"];
    controller.delegate = self;
    return controller;
}

- (UIViewController *)rightViewController
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:nil];
    RCNavigationController* controller = [storyboard instantiateViewControllerWithIdentifier:@"RightRevealVC"];
    RCRightRevealViewController *rightView = (RCRightRevealViewController *)controller.viewControllers[0];
    rightView.delegate = self;
    return controller;
}

- (void)disableFrontPanning
{
    self.revealController.frontViewController.revealController.recognizesPanningOnFrontView = NO;
}

- (void)enableFrontPanning
{
    self.revealController.frontViewController.revealController.recognizesPanningOnFrontView = YES;
}

@end
