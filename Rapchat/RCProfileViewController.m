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
#import "RCEditProfileViewController.h"

#import <SVProgressHUD.h>

#import "RCUrlPaths.h"

@interface RCProfileViewController ()


@property (nonatomic, strong) RCProfile *myProfile;
@property (nonatomic, strong) NSArray *myLikes;
@property (nonatomic, strong) NSArray *myCrowds;
@property (nonatomic, strong) NSArray *myRaps;
@property (nonatomic, strong) NSArray *myFriends;
@property (nonatomic, strong) NSArray *myFriendRequests;
@property (nonatomic, strong) NSString *currentSection;
@property (nonatomic) NSInteger currentSectionIndex;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *tabs;
@property (nonatomic) UIRefreshControl *refreshControl;

@property (weak, nonatomic) IBOutlet UIButton *numberOfRapsButton;
@property (weak, nonatomic) IBOutlet UIButton *numberOfLikesButton;
@property (weak, nonatomic) IBOutlet UIButton *numberOfFriendsButton;

@end

@implementation RCProfileViewController


- (IBAction)segmentItemChanged:(UISegmentedControl *)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    self.currentSection = [segmentedControl titleForSegmentAtIndex: [segmentedControl selectedSegmentIndex]];
    self.currentSectionIndex = [self.tabs indexOfObject:self.currentSection];
    // Call a different method here depending on the tab currently selected
    [self performSelector:NSSelectorFromString([self validSelectorsForSegmentedControl][self.currentSection])];
}

- (NSDictionary *)validSelectorsForSegmentedControl
{
    return @{@"Raps": NSStringFromSelector(@selector(loadRaps)),
             @"Crowds": NSStringFromSelector(@selector(loadCrowds)),
             @"Likes": NSStringFromSelector(@selector(loadLikes)),
             @"Requests": NSStringFromSelector(@selector(loadFriendRequests))
             };
}

- (NSDictionary *)validDataSourceForSection:(NSString *)section
{
    NSDictionary *dataSources = @{@"Raps": self.myRaps,
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
}


- (void)refresh:(id)sender
{
    [self performSelector:NSSelectorFromString([self validSelectorsForSegmentedControl][self.currentSection])];
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
    self.tabs = @[@"Raps", @"Crowds", @"Likes", @"Requests"];
    

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
    [self.navigationItem.leftBarButtonItem setImage:[UIImage imageNamed:@"ic_profile"]];
    
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
    [self loadProfile];
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
    cell.usernameLabel.text = friendRequest.sender.username;
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
    cell.titleLabel.text = crowd.title;
    cell.numberOfMembersLabel.text = [NSString stringWithFormat:@"%lu members", (unsigned long)[crowd.members count]];
    return cell;
}

- (RCSessionTableViewCell *)createSessionCellForTable:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = @"SessionCell";
    RCSessionTableViewCell *cell = (RCSessionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    RCSession *session = [(RCLike *)[self.myLikes objectAtIndex:indexPath.row] session];
    [cell setCellSession:session];
    [cell.likesButton setSelected:YES];
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
            numElements = [self.myRaps count];
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
            height = 50;
            break;
        case 1:
            height = 70;
            break;
        case 2:
            height = 428;
            break;
        case 3:
            height = 45;
            break;
    }
    return height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    switch (self.currentSectionIndex) {
        case 0:
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
- (void)logout
{
    [self performSegueWithIdentifier:@"Logout Segue" sender:self];
}

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
    if ([segue.identifier isEqualToString:@"Logout Segue"]) {
        NSLog(@"Preparing for logout");
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"accessToken"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark API Calls
- (void)loadRaps
{
    NSLog(@"Load Raps Clicked");
}

- (void)loadCrowds
{
    NSLog(@"Load Crowds Clicked");
    if (!self.myCrowds) {
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

- (void)loadLikes
{
    NSLog(@"Loading Likes");
    if (!self.myLikes) {
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

- (void) loadFriendRequests
{
    NSLog(@"Load Friend Requests");
    if (!self.myFriendRequests) {
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

- (void)loadFriends
{
    NSLog(@"Load Friends");
    if (!self.myFriends) {
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
