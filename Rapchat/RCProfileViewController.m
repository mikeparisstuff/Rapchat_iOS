//
//  RCProfileViewController.m
//  Rapchat
//
//  Created by Michael Paris on 12/8/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import "RCProfileViewController.h"
#import "RCProfile.h"
#import "RCCrowd.h"
#import "RClike.h"
#import "RCFriendRequest.h"
#import "RCFriendRequestTableViewCell.h"
#import "RCCrowdTableViewCell.h"
#import "RCSessionTableViewCell.h"
#import "RCFriendTableViewCell.h"
#import "RCClipTableviewCell.h"
#import "RCEditProfileViewController.h"
#import "RCCommentsViewController.h"
#import "RCPreviewVideoNoNavbarViewController.h"
#import "RCPublicProfileViewController.h"
#import "RCCrowdMembersTableViewController.h"

#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import <SVProgressHUD.h>

#import "RCUrlPaths.h"

@interface RCProfileViewController ()

@property (nonatomic, strong) RCSession *commentsSession;
@property (nonatomic, strong) NSURL *clipUrl;
@property (nonatomic, strong) NSNumber *selectedSessionId;

@property (nonatomic, strong) RCProfile *myProfile;
@property (nonatomic, strong) NSArray *myLikes;
@property (nonatomic, strong) NSArray *myCrowds;
@property (nonatomic, strong) NSArray *myRaps;
@property (nonatomic, strong) NSArray *myFriends;
@property (nonatomic, strong) NSSet *friendIdSet;

@property (nonatomic, strong) NSArray *myFriendRequests;
@property (nonatomic, strong) NSString *currentSection;
@property (nonatomic) NSInteger currentSectionIndex;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *tabs;
@property (nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (weak, nonatomic) IBOutlet UIButton *numberOfRapsButton;
@property (weak, nonatomic) IBOutlet UIButton *numberOfLikesButton;
@property (weak, nonatomic) IBOutlet UIButton *numberOfFriendsButton;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;

@property (nonatomic, strong) NSString *discoverUsername;
@property (nonatomic, strong) NSIndexPath *selectedIndex;

@end

@implementation RCProfileViewController


- (IBAction)segmentItemChanged:(UISegmentedControl *)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    self.currentSection = [segmentedControl titleForSegmentAtIndex: [segmentedControl selectedSegmentIndex]];
    self.currentSectionIndex = [self.tabs indexOfObject:self.currentSection];
    // Call a different method here depending on the tab currently selected
    NSLog(@"Calling %@", self.currentSection);
    [self performSelector:NSSelectorFromString([self validSelectorsForSegmentedControl][self.currentSection]) withObject:[NSNumber numberWithBool:NO]];
}

- (NSDictionary *)validSelectorsForSegmentedControl
{
    return @{@"Friends": NSStringFromSelector(@selector(loadFriends:)),
             @"Crowds": NSStringFromSelector(@selector(loadCrowds:)),
             @"Likes": NSStringFromSelector(@selector(loadLikes:)),
             @"Requests": NSStringFromSelector(@selector(loadFriendRequests:))
             };
}

- (NSDictionary *)validDataSourceForSection:(NSString *)section
{
    NSDictionary *dataSources = @{@"Friends": self.myFriends,
                                 @"Crowds": self.myCrowds,
                                 @"Likes": self.myLikes,
                                 @"Requests": self.myFriendRequests
                                 };
    return dataSources[section];
}

- (void)setProfileHeaderInfo
{
    [self.numberOfFriendsButton setTitle:[NSString stringWithFormat:@"%@", self.myProfile.numberOfFriends] forState:UIControlStateNormal];
    [self.numberOfLikesButton setTitle:[NSString stringWithFormat:@"%@", self.myProfile.numberOfLikes] forState:UIControlStateNormal];
    [self.numberOfRapsButton setTitle:[NSString stringWithFormat:@"%@", self.myProfile.numberOfRaps] forState:UIControlStateNormal];
    if (self.myProfile.profilePictureURL) {
        [self.profilePictureImageView setImageWithURL:self.myProfile.profilePictureURL
                          usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
}


- (void)refresh:(id)sender
{
    [self performSelector:NSSelectorFromString([self validSelectorsForSegmentedControl][self.currentSection]) withObject:[NSNumber numberWithBool:YES]];
}

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
    self.tabs = @[@"Friends", @"Crowds", @"Likes", @"Requests"];
    

    // Because refreshControl is made to be used with UItvc we need to create on and
    // embed our tableview within it to get the refresh to work. This is magic so just leave it
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.tableView;

    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor grayColor];
//    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControl;
    
    // Bar button items
//    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_house"] style:UIBarButtonItemStyleBordered target:self action:@selector(closeProfileScreen)];
//    self.navigationItem.leftBarButtonItem = closeButton;
    [self.navigationItem.leftBarButtonItem setImage:[UIImage imageNamed:@"ic_profile_nav"]];
    [self.navigationItem.leftBarButtonItem setImageInsets:UIEdgeInsetsZero];
    
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add_friend_icon"] style:UIBarButtonItemStyleBordered target:self action:@selector(findFriends)];
    self.navigationItem.rightBarButtonItem = logoutButton;
 
    
    
//    self.refreshControl = [[UIRefreshControl alloc] init];
//    self.refreshControl.tag = 99;
//    [self.tableView addSubview:self.refreshControl];
//    self.tableView.alwaysBounceVertical = YES;
//    self.edgesForExtendedLayout = UIRectEdgeNone;

//    [self.tableView registerClass: [RCCrowdTableViewCell class] forCellReuseIdentifier:@"Crowd Cell"];
//    [self.tableView registerClass: [RCFriendTableViewCell class] forCellReuseIdentifier:@"Friend Cell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.currentSection = [self.segmentedControl titleForSegmentAtIndex: [self.segmentedControl selectedSegmentIndex]];
    [self loadProfile];
    [self refresh:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark Tableview Utility Methods

- (void)updateGui
{
    [self.tableView reloadData];
    if (self.refreshControl.isRefreshing) {
        [self.refreshControl endRefreshing];
    }
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD showSuccessWithStatus:@"Success"];
    }
    self.navigationItem.title = self.myProfile.user.username;
}

#pragma mark TBV Cell Factory
- (RCFriendRequestTableViewCell *)createFriendRequestCellForTable:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = @"FriendRequestCell";
    RCFriendRequestTableViewCell *cell = (RCFriendRequestTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[RCFriendRequestTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    // Configure the cell...
    RCFriendRequest *friendRequest = [self.myFriendRequests objectAtIndex:indexPath.row];
    NSLog(@"Inserting Cell with Profile: %@", cell);
    [cell setFriendRequest:friendRequest];
    return cell;
}

- (RCCrowdTableViewCell *)createCrowdCellForTable:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = @"CrowdCell";
    RCCrowdTableViewCell *cell = (RCCrowdTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[RCCrowdTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    //Configure the cell
    RCCrowd *crowd = [self.myCrowds objectAtIndex:indexPath.row];
    [cell setCrowd: crowd];
    cell.delegate = self;
    return cell;
}

- (RCSessionTableViewCell *)createSessionCellForTable:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = @"SessionCell";
    RCSessionTableViewCell *cell = (RCSessionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    RCSession *session = [(RCLike *)[self.myLikes objectAtIndex:indexPath.row] session];
    [cell setCellSession:session];
    [cell.likeButton setSelected:YES];
    cell.delegate = self;
    return cell;
}

- (RCFriendTableViewCell *)createFriendCellForTable:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = @"FriendCell";
    RCFriendTableViewCell *cell = (RCFriendTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    RCProfile *friend = [self.myFriends objectAtIndex:indexPath.row];
    [cell setFriend:friend];
    cell.delegate = self;
    return cell;
}



/*
 *  Listview Delegate and Protocol Methods
 */
#pragma mark Tableview Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    // Defaults to 1. Good
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
//    NSLog(@"Number of rows: %d", [[self validDataSourceForSection:self.currentSection] count]);
//    return [[self validDataSourceForSection:self.currentSection] count];
    unsigned long numElements = 0;
    switch (self.currentSectionIndex) {
        case 0:
            numElements = [self.myFriends count];
            break;
        case 1:
            numElements = [self.myCrowds count];
            break;
        case 2:
            numElements = [self.myLikes count];
            NSLog(@"loading %lu likes", numElements);
            break;
        case 3:
            numElements = [self.myFriendRequests count];
            break;
    }
    return numElements;
}

// For some reason the height that is specified in the story board
// is not carried through to these calls and thus we need to specify the
// heights explicitly so that the rows do not overlap.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 50;
    switch (self.currentSectionIndex) {
        case 0:
            height = 75;
            break;
        case 1:
            height = 100;
            break;
        case 2:
            height = 428;
            break;
        case 3:
            height = 75;
            break;
    }
    return height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    switch (self.currentSectionIndex) {
        case 0:
            cell = [self createFriendCellForTable:tableView forIndexPath:indexPath];
            break;
        case 1:
            cell = [self createCrowdCellForTable:tableView forIndexPath:indexPath];
            break;
        case 2:
            cell = [self createSessionCellForTable:tableView forIndexPath:indexPath];
            break;
        case 3:
            cell = [self createFriendRequestCellForTable:tableView atIndexPath:indexPath];
            break;
    }
    
    return cell;
}

#pragma mark Segues

- (void) closeProfileScreen
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)findFriends
{
    [self performSegueWithIdentifier:@"segueToFindFriends" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToEditProfile"]) {
        if ([segue.destinationViewController isKindOfClass:[RCEditProfileViewController class]]) {
            RCEditProfileViewController *controller = segue.destinationViewController;
            controller.profile = self.myProfile;
        }
    }
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
    if ([segue.identifier isEqualToString:@"GotoProfileSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[RCPublicProfileViewController class]]) {
            RCPublicProfileViewController *controller = (RCPublicProfileViewController *)segue.destinationViewController;
            NSMutableArray *idArray = [[NSMutableArray alloc] init];
            for (RCProfile *friend in self.myFriends) {
                [idArray addObject:friend.profileId];
            }
            self.friendIdSet = [NSSet setWithArray:idArray];
            controller.discoverUsername = self.discoverUsername;
            controller.friendIdSet = self.friendIdSet;
            NSLog(@"Prepared GotoProfileSegue");
        }
    }
    if ([segue.identifier isEqualToString:@"GoToCrowdMembersSegue"]) {
        if([segue.destinationViewController isKindOfClass:[RCCrowdMembersTableViewController class]]) {
            NSLog(@"Segueing to crowd members table view");
            RCCrowdMembersTableViewController *controller = (RCCrowdMembersTableViewController *)segue.destinationViewController;
            RCCrowd *crowd = (RCCrowd *)[self.myCrowds objectAtIndex:self.selectedIndex.row];
            controller.crowd = crowd;
        }
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
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
                          [self.tableView reloadData];
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

- (void)playVideoInCell:(id)sender
{
    if ([sender isKindOfClass:[RCSessionTableViewCell class]]) {
        RCSession *session = [sender getCellSession];
        self.clipUrl = session.mostRecentClipUrl;
        self.selectedSessionId = session.sessionId;
        NSLog(@"Clicking on video with url: %@", self.clipUrl);
        [self performSegueWithIdentifier:@"PlayVideoSegue" sender:self];
    } else if ([sender isKindOfClass:[RCClipTableviewCell class]]) {
        RCClip *clip = [sender getCellClip];
        self.clipUrl = clip.url;
        self.selectedSessionId = clip.clipId;
        [self performSegueWithIdentifier:@"PlayVideoSegue" sender:self];
    }
}

#pragma mark Crowd Cell Protocol
- (void)viewCrowdMembers:(id)sender {
    self.selectedIndex = [self.tableView indexPathForCell:sender];
    [self performSegueWithIdentifier:@"GoToCrowdMembersSegue" sender:self];
}

#pragma mark Friend Cell Protocol
- (void)gotoProfile:(NSString *)username
{
    self.discoverUsername = username;
    [self performSegueWithIdentifier:@"GotoProfileSegue" sender:self];
}

#pragma mark API Calls

- (void)loadCrowds:(NSNumber *)forceRefresh
{
    NSLog(@"Load Crowds Clicked");
    if ((!self.myCrowds) || forceRefresh) {
        RKObjectManager *objectManager = [RKObjectManager sharedManager];
        [SVProgressHUD showWithStatus:@"Loading Crowds" maskType:SVProgressHUDMaskTypeGradient];
        [objectManager getObjectsAtPath:myCrowdsEndpoint
                             parameters:nil
                                success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                    self.myCrowds = [mappingResult array];
                                    NSLog(@"Got Crowds: %@", self.myCrowds);
                                    [self updateGui];
                                }failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                    [SVProgressHUD showErrorWithStatus:@"Network Error"];
                                }];
    } else {
        [self updateGui];
    }
}

- (void)loadLikes:(NSNumber *)forceRefresh
{
    NSLog(@"Loading Likes");
    if ((!self.myLikes) || forceRefresh) {
        RKObjectManager *objectManager = [RKObjectManager sharedManager];
        [SVProgressHUD showWithStatus:@"Loading Likes" maskType:SVProgressHUDMaskTypeGradient];
        [objectManager getObjectsAtPath:myLikesEndpoint
                             parameters:nil
                                success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                    self.myLikes = [mappingResult array];
                                    NSLog(@"Got Likes: %@", self.myLikes);
                                    [self updateGui];
                                }failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                    [SVProgressHUD showErrorWithStatus:@"Network Error"];
                                }];
    } else {
        [self updateGui];
    }
    NSLog(@"Load Likes Clicked");
}

- (void)loadProfile
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [SVProgressHUD showWithStatus:@"Loading Profile" maskType:SVProgressHUDMaskTypeGradient];
    [objectManager getObjectsAtPath:myProfileEndpoint
                         parameters:nil
                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                self.myProfile = [mappingResult firstObject];
                                NSLog(@"Got Profile: %@", self.myProfile.user.username);
                                self.myFriends = self.myProfile.friends;
                                [self setProfileHeaderInfo];
                                [self updateGui];
                            }failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                [SVProgressHUD showErrorWithStatus:@"Network Error"];
                            }];
}

- (void) loadFriendRequests:(NSNumber *)forceRefresh
{
    NSLog(@"Load Friend Requests");
    if ((!self.myFriendRequests) || forceRefresh) {
        [SVProgressHUD showWithStatus:@"Loading Friend Requests" maskType:SVProgressHUDMaskTypeGradient];
        RKObjectManager *objectManager = [RKObjectManager sharedManager];
        
        [objectManager getObjectsAtPath:myFriendRequestsEndpoint
                             parameters:nil
                                success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                    self.myFriendRequests = [mappingResult array];
                                    NSLog(@"Loading Requests: %@", self.myFriendRequests);
                                    [self updateGui];
                                }failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                    [SVProgressHUD showErrorWithStatus:@"Network Error"];
                                }];
    } else {
        [self updateGui];
    }
    
}

- (void)loadFriends:(NSNumber *)forceRefresh
{
    NSLog(@"Load Friends");
    if ((!self.myFriends) || forceRefresh) {
        [SVProgressHUD showWithStatus:@"Loading Friends" maskType:SVProgressHUDMaskTypeGradient];
        RKObjectManager *objectManager = [RKObjectManager sharedManager];
        
        [objectManager getObjectsAtPath:myFriendsEndpoint
                             parameters:nil
                                success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                    self.myFriends = [mappingResult array];
                                    [self updateGui];
                                }failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                    [SVProgressHUD showErrorWithStatus:@"Network Error"];
                                }];
    } else {
        [self updateGui];
    }
}

@end
