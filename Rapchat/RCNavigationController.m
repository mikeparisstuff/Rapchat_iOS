//
//  RCNavigationController.m
//  Rapchat
//
//  Created by Michael Paris on 12/9/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import "RCNavigationController.h"

@interface RCNavigationController ()

@property (strong, readwrite, nonatomic) REMenu *menu;

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
    
    if (REUIKitIsFlatMode()) {
        [self.navigationBar performSelector:@selector(setBarTintColor:)
                                 withObject:[UIColor colorWithRed:226.0/255.0 green:66.0/255.0 blue:51.0/255.0 alpha:1.0]];
        self.navigationBar.tintColor = [UIColor colorWithHue:0.0 saturation:0.06 brightness:0.14 alpha:1.0];
    } else {
        self.navigationBar.tintColor = [UIColor colorWithHue:0.0 saturation:0.06 brightness:0.14 alpha:1.0];
    }
    
    __typeof (self) __weak weakSelf = self;
    REMenuItem *liveItem = [[REMenuItem alloc] initWithTitle:@"Live"
                                                    subtitle:nil
                                                       image:[UIImage imageNamed:@"ic_music_note"]
                                            highlightedImage:nil
                                                      action:^(REMenuItem *item) {
                                                          NSLog(@"Item: %@", item);
                                                          UIStoryboard* storyboard = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:nil];
                                                          UIViewController* controller = [storyboard instantiateViewControllerWithIdentifier:@"LiveFeedController"];
                                                          [weakSelf setViewControllers:@[controller] animated:NO];
                                                      }];
    
    REMenuItem *stageItem = [[REMenuItem alloc] initWithTitle:@"Stage"
                                                       subtitle:nil
                                                          image:[UIImage imageNamed:@"ic_home"]
                                               highlightedImage:nil
                                                         action:^(REMenuItem *item) {
                                                             NSLog(@"Item: %@", item);
                                                             UIStoryboard* storyboard = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:nil];
                                                             UIViewController* controller = [storyboard instantiateViewControllerWithIdentifier:@"LiveFeedController"];
                                                             [weakSelf setViewControllers:@[controller] animated:NO];
                                                         }];
    
    REMenuItem *profileItem = [[REMenuItem alloc] initWithTitle:@"Profile"
                                                          image:[UIImage imageNamed:@"ic_profile"]
                                               highlightedImage:nil
                                                         action:^(REMenuItem *item) {
                                                             NSLog(@"Item: %@", item);
                                                             UIStoryboard* storyboard = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:nil];
                                                             UIViewController* controller = [storyboard instantiateViewControllerWithIdentifier:@"ProfileController"];
                                                             [weakSelf setViewControllers:@[controller] animated:NO];
                                                         }];
    
    
    // You can also assign a custom view for any particular item
    // Uncomment the code below and add `customViewItem` to `initWithItems` array, for example:
    // self.menu = [[REMenu alloc] initWithItems:@[homeItem, exploreItem, activityItem, profileItem, customViewItem]]
    //
    /*
     UIView *customView = [[UIView alloc] init];
     customView.backgroundColor = [UIColor blueColor];
     customView.alpha = 0.4;
     REMenuItem *customViewItem = [[REMenuItem alloc] initWithCustomView:customView action:^(REMenuItem *item) {
     NSLog(@"Tap on customView");
     }];
     */
    
    liveItem.tag = 0;
    stageItem.tag = 1;
    profileItem.tag = 2;
    
    self.menu = [[REMenu alloc] initWithItems:@[liveItem, stageItem, profileItem]];
    
    // Background view
    //
    //self.menu.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    //self.menu.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //self.menu.backgroundView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.600];
    
    //self.menu.imageAlignment = REMenuImageAlignmentRight;
    //self.menu.closeOnSelection = NO;
    //self.menu.appearsBehindNavigationBar = NO; // Affects only iOS 7
    if (!REUIKitIsFlatMode()) {
        self.menu.cornerRadius = 4;
        self.menu.shadowRadius = 4;
        self.menu.shadowColor = [UIColor blackColor];
        self.menu.shadowOffset = CGSizeMake(0, 1);
        self.menu.shadowOpacity = 1;
    }
    
    // Blurred background in iOS 7
    //
    //self.menu.liveBlur = YES;
    //self.menu.liveBlurBackgroundStyle = REMenuLiveBackgroundStyleDark;
    //self.menu.liveBlurTintColor = [UIColor redColor];
    
    self.menu.imageOffset = CGSizeMake(5, -1);
    self.menu.waitUntilAnimationIsComplete = NO;
    self.menu.badgeLabelConfigurationBlock = ^(UILabel *badgeLabel, REMenuItem *item) {
        badgeLabel.backgroundColor = [UIColor colorWithRed:0 green:179/255.0 blue:134/255.0 alpha:1];
        badgeLabel.layer.borderColor = [UIColor colorWithRed:0.000 green:0.648 blue:0.507 alpha:1.000].CGColor;
    };
    
    
}

- (void)toggleMenu
{
    if (self.menu.isOpen) {
        return [self.menu close];
    }
    [self.menu showFromNavigationController:self];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    // Change the color of the status bar items
    return UIStatusBarStyleLightContent;
}


@end
