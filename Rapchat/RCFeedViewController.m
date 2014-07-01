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
#import "RCPreviewVideoForRapbackViewController.h"
#import "RCSessionPaginator.h"
#import "RCCreateNewSessionCameraViewController.h"


#include "REMenu.h"

#import "RCUrlPaths.h"
#import "RCConstants.h"
#import "RCNavigationController.h"

#define RELOAD_OFFSET 5

@interface RCFeedViewController ()

@property (nonatomic, strong) NSArray *sessions;
@property (nonatomic, strong) RCSession *commentsSession;
@property (nonatomic, strong) NSURL *clipUrl;
@property (nonatomic, strong) RCSession *selectedSession;
@property (nonatomic, strong) NSMutableSet *likesSet;
@property (nonatomic, strong) NSMutableArray *allSessions;
@property (nonatomic, strong) RCSessionPaginator *sessionsPaginator;
@property (nonatomic) BOOL stillLoadingLikes;
@property (nonatomic) BOOL stillLoadingSessions;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) UIRefreshControl *refreshControl;


@property (nonatomic) BOOL shouldBattle;
@end

@implementation RCFeedViewController
{
    BOOL scrolledToBottom;
    BOOL alreadyLoading;
}


// Control dragged from refreshController so that dragging down will
// refresh the page
//- (IBAction)refresh:(id)sender {
//    [self.refreshControl beginRefreshing];
//    [self reloadData];
//}

- (void)refresh
{
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

//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Creating Live Feed");

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Add profile and new session bar button items
//    UIBarButtonItem *newSessionButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_microphone"] style:UIBarButtonItemStyleBordered target:self action:@selector(segueToNewSessionWorkflow)];
    UIBarButtonItem *friendsBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_users"] style:UIBarButtonItemStyleBordered target:self action:@selector(revealRightVC)];
    self.navigationItem.rightBarButtonItem = friendsBarItem;
//    [self.navigationItem setRightBarButtonItems:@[friendsBarItem, newSessionButton]];
    
    [self.navigationItem.leftBarButtonItem setImage:[UIImage imageNamed:@"ic_heart_rate_nav"]];
    [self.navigationItem.leftBarButtonItem setImageInsets:UIEdgeInsetsZero];
    
    [self setTitle:@"Live Feed"];
    
    // Setup tableview
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
//    [self.refreshControl setBackgroundColor:[UIColor colorWithRed:189.0/255.0 green:195.0/255.0 blue:199.0/255.0 alpha:1.0]];
    [self.refreshControl setBackgroundColor:[UIColor clearColor]];
    [self.refreshControl setTintColor:[UIColor redColor]];
    [self.tableView addSubview:self.refreshControl];
    
//    [self.view addSubview:[self createAwesomeMenu]];
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [backgroundView setImage:[UIImage imageNamed:@"freedom_tower"]];
    [self.tableView setBackgroundView:backgroundView];
    
//    [self.tableView setBackgroundColor:[UIColor colorWithRed:34.0/255.0 green:36.0/255.0 blue:42.0/255.0 alpha:1.0]];
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
}

- (void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];
//    [SVProgressHUD showWithStatus:@"Loading Sessions" maskType:SVProgressHUDMaskTypeGradient];
//    [self.refreshControl beginRefreshing];
    [self reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) revealRightVC
{
    RCNavigationController *navCont = (RCNavigationController *)self.navigationController;
    if ([navCont respondsToSelector:@selector(toggleRevealRight)]) {
        [navCont toggleRevealRight];
    }
}

#pragma mark - Awesome Menu

- (void)awesomeMenu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx
{
    NSLog(@"Selected index: %ld", (long)idx);
    self.shouldBattle = (idx == 0) ? YES : NO;
    if (self.shouldBattle) {
        RCNavigationController *navController = (RCNavigationController *)self.navigationController;
        [navController toggleRevealRight];
    } else {
        [self performSegueWithIdentifier:@"segueToNewSessionWorkflow" sender:self];
    }
}

- (IBAction)createNewRapButtonTapped:(id)sender
{
    [self performSegueWithIdentifier:@"segueToNewSessionWorkflow" sender:self];
}


#pragma mark - API

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
    static NSString *CellIdentifier = @"RapCell";
//    RCRapTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    RCRapTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RCRapTableViewCell" owner:self options:nil];
        cell = (RCRapTableViewCell *)[nib objectAtIndex:0];
    }
    
    if ([self.allSessions count] > 0) {
        [cell setCellSession:[self.allSessions objectAtIndex:indexPath.row]];
        cell.delegate = self;
    }
    
    // Configure the cell...
//    RCSession *session = [self.allSessions objectAtIndex:indexPath.section];
//    [cell setCellSession:session];
//    if ([self.likesSet containsObject:session.sessionId]) {
//        [cell.likeButton setSelected:YES];
//    } else {
//        [cell.likeButton setSelected:NO];
//    }
//    cell.delegate = self;
//    [cell setNeedsDisplay];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 240;
}

//- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    return [[UIView alloc] initWithFrame:CGRectMake(0,0, tableView.bounds.size.width, 5)];
//}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectMake(0, tableView.bounds.size.height-44, tableView.bounds.size.width, 44)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 44;
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

#pragma mark - ScrollViewDelegate
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


#pragma mark - Segues

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
            if ([[navController topViewController] isKindOfClass:[RCPreviewVideoForRapbackViewController class]]) {
                RCPreviewVideoForRapbackViewController *RCpfvc = (RCPreviewVideoForRapbackViewController *)[navController topViewController];
                RCpfvc.videoURL = self.clipUrl;
                RCpfvc.sessionId = self.selectedSession.sessionId;
//                RCpfvc.isBattle = self.selectedSession.isBattle;
                NSLog(@"Prepared PlayVideoSegue");
            }
        }
    }
    if ([segue.identifier isEqualToString:@"segueToNewSessionWorkflow"]) {
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navController = segue.destinationViewController;
            if ([[navController topViewController] isKindOfClass:[RCCreateNewSessionCameraViewController class]]) {
                RCCreateNewSessionCameraViewController *RCnsc = (RCCreateNewSessionCameraViewController *)[navController topViewController];
                
                // Depending on which button was clicked set isBattle Yes or No
                RCnsc.isBattle = self.shouldBattle;
                NSLog(@"Prepared CreateNewSessionSegue");
            }
        }
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


# pragma mark - Utility methods
- (NSIndexPath *)indexPathForCellHoldingButton:(UIButton *)button
{
    return [self.tableView indexPathForCell:(UITableViewCell *)button.superview];
}

#pragma mark - Session cell Protocol

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
    self.selectedSession = session;
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
