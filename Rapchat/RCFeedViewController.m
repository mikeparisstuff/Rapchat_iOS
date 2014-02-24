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
#import "RCSessionPaginator.h"


#include "REMenu.h"

#import "RCUrlPaths.h"
#import "RCConstants.h"

#define RELOAD_OFFSET 5

@interface RCFeedViewController ()

@property (nonatomic, strong) NSArray *sessions;
@property (nonatomic, strong) RCSession *commentsSession;
@property (nonatomic, strong) NSURL *clipUrl;
@property (nonatomic, strong) NSNumber *selectedSessionId;
@property (nonatomic, strong) NSMutableSet *likesSet;
@property (nonatomic, strong) NSMutableArray *allSessions;
@property (nonatomic, strong) RCSessionPaginator *sessionsPaginator;
@property (nonatomic) BOOL stillLoadingLikes;
@property (nonatomic) BOOL stillLoadingSessions;

@end

@implementation RCFeedViewController
{
    BOOL scrolledToBottom;
    BOOL alreadyLoading;
}


// Control dragged from refreshController so that dragging down will
// refresh the page
- (IBAction)refresh:(id)sender {
    [self.refreshControl beginRefreshing];
    [self reloadData];
}

- (void)reloadData
{
    [self loadLikes];
    [self loadSessions];
}

- (void) updateUI {
    if(self.isViewLoaded) {
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
        scrolledToBottom = NO;
        alreadyLoading = NO;
        if ([SVProgressHUD isVisible]) {
            [SVProgressHUD showSuccessWithStatus:@"Success"];
        }
    }
}

- (void)updateUIAtIndexPaths:(NSArray *)indexPaths
{
    if(self.isViewLoaded) {
        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
        [self.refreshControl endRefreshing];
        scrolledToBottom = NO;
        alreadyLoading = NO;
        if ([SVProgressHUD isVisible]) {
            [SVProgressHUD showSuccessWithStatus:@"Success"];
        }
    }
}

- (void)loadSessions
{
    NSLog(@"Loading Sessions");
    // Load the object model via RestKit
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    alreadyLoading = YES;
    self.stillLoadingSessions = YES;
    [objectManager getObjectsAtPath:mySessionsEndpoint
                         parameters:nil
                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
//                                NSArray *sessions = [mappingResult array];
                                self.sessionsPaginator = [mappingResult firstObject];
//                                self.sessions = sessions;
                                self.allSessions = [self.sessionsPaginator.currentPageSessions mutableCopy];
                                if (!self.stillLoadingLikes) {
                                    [self updateUI];
                                }
                                self.stillLoadingSessions = NO;
                            }failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                [SVProgressHUD showErrorWithStatus:@"Network Error"];
                            }];
}

- (void)loadNextSessions
{
    NSLog(@"Load next sessions");
    if (self.sessionsPaginator.nextUrl) {
        alreadyLoading = YES;
        RKObjectManager *objectManager = [RKObjectManager sharedManager];
        [objectManager getObjectsAtPath:self.sessionsPaginator.nextUrl
                             parameters:nil
                                success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                    //                                NSArray *sessions = [mappingResult array];
                                    self.sessionsPaginator = [mappingResult firstObject];
                                    //                                self.sessions = sessions;
                                    int firstIndex = (int)[self.allSessions count];
                                    [self.allSessions addObjectsFromArray:self.sessionsPaginator.currentPageSessions];
                                    int lastIndex = (int)[self.allSessions count];
                                    NSMutableArray *indexes = [[NSMutableArray alloc] init];
                                    for (int i = firstIndex; i < lastIndex; i++) {
                                        NSLog(@"Inserting row with index %d", i);
                                        [indexes addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                                    }
                                    [self.tableView insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationLeft];
                                    [self updateUI];
                                }failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                    [SVProgressHUD showErrorWithStatus:@"Network Error"];
                                }];

    }
}

- (void)loadLikes
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    alreadyLoading = YES;
    self.stillLoadingLikes = YES;
    [objectManager getObjectsAtPath:myLikesEndpoint
                         parameters:nil
                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                NSMutableArray *likes = [[NSMutableArray alloc] init];
                                for (RCLike *like in [mappingResult array]) {
                                    [likes addObject:like.session.sessionId];
                                }
                                self.likesSet = [NSMutableSet setWithArray:likes];
                                if (!self.stillLoadingSessions) {
                                    [self updateUI];
                                }
                                self.stillLoadingLikes = NO;
                            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                [SVProgressHUD showErrorWithStatus:@"Network Error"];
                            }];
}

- (void)loadLikesAndReloadAtIndexPaths:(NSArray *)indexPaths
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    alreadyLoading = YES;
    [objectManager getObjectsAtPath:myLikesEndpoint
                         parameters:nil
                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                NSMutableArray *likes = [[NSMutableArray alloc] init];
                                for (RCLike *like in [mappingResult array]) {
                                    [likes addObject:like.session.sessionId];
                                }
                                self.likesSet = [NSMutableSet setWithArray:likes];
                                [self updateUIAtIndexPaths:indexPaths];
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
    NSLog(@"Creating Live Feed");
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Add profile and new session bar button items
    UIBarButtonItem *newSessionButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_microphone"] style:UIBarButtonItemStyleBordered target:self action:@selector(segueToNewSessionWorkflow)];
    self.navigationItem.rightBarButtonItem = newSessionButton;
    
    [self.navigationItem.leftBarButtonItem setImage:[UIImage imageNamed:@"ic_heart_rate_nav"]];
    [self.navigationItem.leftBarButtonItem setImageInsets:UIEdgeInsetsZero];
    
    [self setTitle:@"Live Feed"];
    
    [self.refreshControl setBackgroundColor:[UIColor colorWithRed:189.0/255.0 green:195.0/255.0 blue:199.0/255.0 alpha:1.0]];
    [self.refreshControl setTintColor:[UIColor redColor]];
    
}

- (void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];
//    [SVProgressHUD showWithStatus:@"Loading Sessions" maskType:SVProgressHUDMaskTypeGradient];
    [self.refreshControl beginRefreshing];
    [self reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return [self.allSessions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SessionCell";
    RCSessionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    RCSession *session = [self.allSessions objectAtIndex:indexPath.row];
    [cell setCellSession:session];
    if ([self.likesSet containsObject:session.sessionId]) {
        [cell.likeButton setSelected:YES];
    } else {
        [cell.likeButton setSelected:NO];
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

#pragma mark ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // UITableView only moves in one direction, y axis
//    NSInteger currentOffset = scrollView.contentOffset.y;
//    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    NSArray *visibleIndexes = [self.tableView indexPathsForVisibleRows];
    if ([visibleIndexes count]) {
        NSIndexPath *topItem = (NSIndexPath *)visibleIndexes[0];
        // load more data when we have scrolled to within 4 sessions of the end
        if (!alreadyLoading && topItem.row > [self.allSessions count] - RELOAD_OFFSET) {
            NSLog(@"Reloading data");
            [self loadNextSessions];
        }
    }
    
//    if (maximumOffset - currentOffset <= 10.0 && !scrolledToBottom) {
//        scrolledToBottom = YES;
//        NSLog(@"Scrolled to bottom");
//        [self loadNextSessions];
//    }
}


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
                          [SVProgressHUD showWithStatus:@"Liking That" maskType:SVProgressHUDMaskTypeGradient];
                          NSIndexPath *selectedPath = [NSIndexPath indexPathForRow:[self.tableView indexPathForCell:sender].row inSection:0];
                          [self loadLikesAndReloadAtIndexPaths:@[selectedPath]];
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

#pragma mark Lazy Loading
-(RCSessionPaginator *)sessionsPaginator
{
    if (!_sessionsPaginator) {
        _sessionsPaginator = [[RCSessionPaginator alloc] init];
    }
    return _sessionsPaginator;
}

-(NSMutableArray *)allSessions
{
    if (!_allSessions) {
        _allSessions = [[NSMutableArray alloc] init];
    }
    return _allSessions;
}

@end
