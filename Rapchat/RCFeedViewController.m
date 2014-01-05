//
//  RCFeedViewController.m
//  Rapchat
//
//  Created by Michael Paris on 12/12/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//
#import <SVProgressHUD.h>

#import "RCFeedViewController.h"
#import "RCSession.h"
#import "RCLike.h"
#import "RCSessionTableViewCell.h"
#import "RCCommentsViewController.h"
#import "RCPreviewFileViewController.h"
#import "RCPreviewVideoNoNavbarViewController.h"

#include "REMenu.h"

#import "RCUrlPaths.h"

@interface RCFeedViewController ()

@property (nonatomic, strong) NSArray *sessions;
@property (nonatomic, strong) RCSession *commentsSession;
@property (nonatomic, strong) NSURL *clipUrl;
@property (nonatomic, strong) NSNumber *selectedSessionId;
@property (nonatomic, strong) NSMutableSet *likesSet;

@property (nonatomic, strong) REMenu *menu;

@end

@implementation RCFeedViewController


// Control dragged from refreshController so that dragging down will
// refresh the page
- (IBAction)refresh:(id)sender {
    [self.refreshControl beginRefreshing];
    [self reloadData];
}

- (void)reloadData
{
    [self loadSessions];
    [self loadLikes];
}

- (void) updateUI {
    if(self.isViewLoaded) {
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
        if ([SVProgressHUD isVisible]) {
            [SVProgressHUD showSuccessWithStatus:@"Success"];
        }
    }
}

- (void)loadSessions
{
    // Load the object model via RestKit
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    [objectManager getObjectsAtPath:mySessionsEndpoint
                         parameters:nil
                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                NSArray *sessions = [mappingResult array];
                                NSLog(@"Loaded sessions: %@", sessions);
                                self.sessions = sessions;
                                [self updateUI];
                            }failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                [SVProgressHUD showErrorWithStatus:@"Network Error"];
                            }];
}

- (void)loadLikes
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    [objectManager getObjectsAtPath:myLikesEndpoint
                         parameters:nil
                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                NSMutableArray *likes = [[NSMutableArray alloc] init];
                                for (RCLike *like in [mappingResult array]) {
                                    [likes addObject:like.session.sessionId];
                                }
                                self.likesSet = [NSMutableSet setWithArray:likes];
                            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                [SVProgressHUD showErrorWithStatus:@"Network Error"];
                            }];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

//- (void)viewDidLayoutSubviews
//{
//    // Only works for iOS 7
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
//        CGRect viewBounds = self.view.bounds;
//        CGFloat topBarOffset = self.topLayoutGuide.length;
//        
//        // snaps the view under the status bar like iOS 6
//        viewBounds.origin.y = topBarOffset * -1;
//        
//        // shrink bounds to compensate for offset
//        self.view.bounds = viewBounds;
//    }
//}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Add profile and new session bar button items
    UIBarButtonItem *newSessionButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_microphone"] style:UIBarButtonItemStyleBordered target:self action:@selector(segueToNewSessionWorkflow)];
    self.navigationItem.rightBarButtonItem = newSessionButton;
    
    UIBarButtonItem *profileButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_man"] style:UIBarButtonItemStyleBordered target:self action:@selector(segueToProfileScreen)];
    self.navigationItem.leftBarButtonItem = profileButton;
    
    [self.refreshControl setBackgroundColor:[UIColor colorWithRed:82.0/255.0 green:187.0/255.0 blue:193.0/255.0 alpha:1.0]];
    [self.refreshControl setTintColor:[UIColor redColor]];
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleViewClicked)];
    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [titleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    NSAttributedString *titleString = [[NSAttributedString alloc] initWithString:@"Rapchat" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:24.0]}];
    [titleButton setAttributedTitle:titleString forState:UIControlStateNormal];
    [titleButton setImage:[UIImage imageNamed:@"ic_triangle"] forState:UIControlStateNormal];
    [titleButton setImageEdgeInsets:UIEdgeInsetsMake(20, 50, -11, 0)];
    [titleButton addTarget:self action:@selector(titleViewClicked) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = titleButton;
 
    [self setupREMenu];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
//    self.extendedLayoutIncludesOpaqueBars = YES;
//    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
//    self.edgesForExtendedLayout = UIRectEdgeNone;
    
}

- (void)viewWillAppear:(BOOL)animated
{
//    CGRect frame = self.view.frame;
//    frame.origin.y = 20;
//    if (self.view.frame.size.height == 1024 ||   self.view.frame.size.height == 768)
//    {
//        frame.size.height -= 20;
//    }
//    self.view.frame = frame;
//    UIView *statusBarBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
//    statusBarBackground.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:76.0/255.0 blue:60.0/255.0 alpha:1.0];
    [super viewWillAppear:animated];
    [SVProgressHUD showWithStatus:@"Loading Sessions" maskType:SVProgressHUDMaskTypeGradient];
    [self loadSessions];
    [self loadLikes];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark REMenu
- (void) setupREMenu
{
    REMenuItem *mySessionsItem = [[REMenuItem alloc] initWithTitle:@"Stage"
                                                       subtitle:nil//@"View my crowds competed sessions"
                                                          image:nil
                                               highlightedImage:nil
                                                         action:^(REMenuItem *item) {
                                                             NSLog(@"Item: %@", item);
                                                         }];
    
//    REMenuItem *myPendingSessionsItem = [[REMenuItem alloc] initWithTitle:@"My Pending Sessions"
//                                                          subtitle:nil//@"View my crowds incomplete sessions"
//                                                             image:nil
//                                                  highlightedImage:nil
//                                                            action:^(REMenuItem *item) {
//                                                                NSLog(@"Item: %@", item);
//                                                            }];
    
    REMenuItem *searchItem = [[REMenuItem alloc] initWithTitle:@"Search"
                                                      subtitle:nil
                                                         image:nil
                                              highlightedImage:nil
                                                        action:^(REMenuItem *item) {
                                                            NSLog(@"Item: %@", item);
                                                        }];
    
    REMenuItem *liveSessionsItem = [[REMenuItem alloc] initWithTitle:@"Live"
                                                       subtitle:nil//@"Explore your friends and followers"
                                                          image:nil
                                               highlightedImage:nil
                                                         action:^(REMenuItem *item) {
                                                             NSLog(@"Item: %@", item);
                                                         }];

    self.menu = [[REMenu alloc] initWithItems:@[searchItem, mySessionsItem, liveSessionsItem]];
}

#pragma mark Actions
- (void)titleViewClicked
{
    NSLog(@"Clicked Title");
    if ([self.menu isOpen]) {
        [self.menu close];
        [(UIButton *)self.navigationItem.titleView setImage:[UIImage imageNamed:@"ic_triangle"] forState:UIControlStateNormal];
    } else {
        [(UIButton *)self.navigationItem.titleView setImage:[UIImage imageNamed:@"ic_triangle_upright"] forState:UIControlStateNormal];
        [self.menu showFromNavigationController:self.navigationController];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    // Defaults to 1. Good
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of %luws (unsigned long)in the section.
    return [self.sessions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SessionCell";
    RCSessionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    RCSession *session = [self.sessions objectAtIndex:indexPath.row];
    [cell setCellSession:session];
    if ([self.likesSet containsObject:session.sessionId]) {
        [cell.likesButton setSelected:YES];
    } else {
        [cell.likesButton setSelected:NO];
    }
    cell.delegate = self;
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"GoToCommentsSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[RCCommentsViewController class]]) {
            RCCommentsViewController *RCtvc = segue.destinationViewController;
            RCtvc.comments = self.commentsSession.comments;
            RCtvc.sessionId = self.commentsSession.sessionId;
            NSLog(@"Prepared GoToCommentsSegue");
        }
    }
    if([segue.identifier isEqualToString:@"PlayVideoSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navController = segue.destinationViewController;
            if ([[navController topViewController] isKindOfClass:[RCPreviewVideoNoNavbarViewController class]]) {
                RCPreviewVideoNoNavbarViewController *RCpfvc = (RCPreviewVideoNoNavbarViewController *)[navController topViewController];
                RCpfvc.videoURL = self.clipUrl;
                RCpfvc.sessionId = self.selectedSessionId;
                NSLog(@"Prepared PlayVideoSegue");
            }
        }
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


# pragma mark Utility methods
- (NSIndexPath *)indexPathForCellHoldingButton:(UIButton *)button
{
    return [self.tableView indexPathForCell:(UITableViewCell *)button.superview];
}

#pragma mark Session cell Protocol

- (void)likeButtonPressedInCell:(RCSessionTableViewCell *)sender
{
//    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
//    NSLog(@"Clicked on like button in cell: %ld", (long)indexPath.row);
//    RCSession *session = [self.sessions objectAtIndex:indexPath.row];
    RCSession *session = [sender getCellSession];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager postObject:nil
                         path:myLikesEndpoint
                   parameters:@{@"session":session.sessionId}
                      success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                          NSLog(@"Toggling like for session: %@", session.sessionId);
                          // We can further optimize this so there is no delay when you are refreshing the tableview
                          [SVProgressHUD showWithStatus:@"Liking that shit" maskType:SVProgressHUDMaskTypeGradient];
                          [self reloadData];
                      }failure:^(RKObjectRequestOperation *operation, NSError *error) {
                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error"
                                                                          message:[error localizedDescription]
                                                                         delegate:nil
                                                                cancelButtonTitle:@"OK"
                                                                otherButtonTitles:nil, nil];
                          [alert show];
                          NSLog(@"Hit error: %@", error);
                      }];

}

- (void)commentButtonPressedInCell:(RCSessionTableViewCell *)sender
{
    self.commentsSession = [sender getCellSession];
    [self performSegueWithIdentifier:@"GoToCommentsSegue" sender:self];
}

- (void)playVideoInCell:(RCSessionTableViewCell *)sender
{
    RCSession *session = [sender getCellSession];
    self.clipUrl = session.mostRecentClipUrl;
    self.selectedSessionId = session.sessionId;
    NSLog(@"Clicking on video with url: %@", self.clipUrl);
    [self performSegueWithIdentifier:@"PlayVideoSegue" sender:self];
}

#pragma mark Segues
- (void)segueToNewSessionWorkflow
{
    [self performSegueWithIdentifier:@"segueToNewSessionWorkflow" sender:self];
}

- (void)segueToProfileScreen
{
    [self performSegueWithIdentifier:@"segueToProfileScreen" sender:self];
}


@end
