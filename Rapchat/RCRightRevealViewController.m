//
//  RCRightRevealViewController.m
//  Rapchat
//
//  Created by Michael Paris on 3/2/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCRightRevealViewController.h"
#import "RCUrlPaths.h"
#import "RCProfile.h"
#import "RCFriendTableViewCell.h"
#import "RCPublicProfileViewController.h"
#import "RCCreateNewSessionCameraViewController.h"
#import "RCFriendRequestWrapper.h"
#import "RCFriendRequestTableViewCell.h"

@interface RCRightRevealViewController ()

@property (nonatomic, strong) NSArray *myFriends;
@property (nonatomic, strong) NSArray *myFriendRequests;
@property (nonatomic, strong) NSString *discoverUsername;
@property (nonatomic, strong) NSString *battleUsername;
@property (nonatomic, strong) NSSet *friendIdSet;
@property (weak, nonatomic) IBOutlet UISegmentedControl *friendsAndRequestsSegmentedControl;

@end

@implementation RCRightRevealViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (IBAction)segmentedControlSelectedIndexDidChange:(id)sender {
    [self.tableView reloadData];
}

- (void)refresh
{
    [self.refreshControl beginRefreshing];
    [self loadFriends];
    [self loadFriendRequests];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    [self loadFriends];
    [self loadFriendRequests];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if ([self.delegate respondsToSelector:@selector(pushBackFromPresentationMode)]) {
        [self.delegate pushBackFromPresentationMode];
    }
    [self.friendsAndRequestsSegmentedControl setTitle:[NSString stringWithFormat:@"Requests: %lu", (unsigned long)[self.myFriendRequests count]] forSegmentAtIndex:1];
    [self updateGui];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark GUI Helpers

- (void)updateGui
{
    [self.tableView reloadData];
    if (self.refreshControl.isRefreshing) {
        [self.refreshControl endRefreshing];
    }
}


#pragma mark Segues
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToFindFriends"]) {
        if ([self.delegate respondsToSelector:@selector(pushToPresentationMode)]) {
            NSLog(@"IN SEGUE");
            [self.delegate pushToPresentationMode];
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
            [self.delegate pushToPresentationMode];
            NSLog(@"Prepared GotoProfileSegue");
        }
    }
    if ([segue.identifier isEqualToString:@"BattleUserSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navController = segue.destinationViewController;
            if ([[navController topViewController] isKindOfClass:[RCCreateNewSessionCameraViewController class]]) {
                RCCreateNewSessionCameraViewController *RCnsc = (RCCreateNewSessionCameraViewController *)[navController topViewController];
                RCnsc.battleUsername = self.battleUsername;
                // Depending on which button was clicked set isBattle Yes or No
                RCnsc.isBattle = YES;
                NSLog(@"Prepared BattleUserSegue");
            }
        }
    }
}

#pragma mark API
- (void)loadFriends
{
    NSLog(@"Load Friends");
        RKObjectManager *objectManager = [RKObjectManager sharedManager];
        
        [objectManager getObjectsAtPath:myFriendsEndpoint
                             parameters:nil
                                success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                    self.myFriends = [mappingResult array];
                                    self.myFriends = [self.myFriends sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                                        RCProfile *prof1 = (RCProfile *)obj1;
                                        RCProfile *prof2 = (RCProfile *)obj2;
                                        NSLog(@"Comparing: %@ to %@", prof1.user.username, prof2.user.username);
                                        return [prof1.user.username localizedCaseInsensitiveCompare:prof2.user.username];
                                    }];
                                    [self updateGui];
                                }failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                }];
}

- (void) loadFriendRequests
{
    NSLog(@"Load Friend Requests");
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
        
    [objectManager getObjectsAtPath:myFriendRequestsEndpoint
                            parameters:nil
                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                RCFriendRequestWrapper *fw = [mappingResult firstObject];
                                self.myFriendRequests = fw.pendingMe;
                                NSLog(@"Loading Requests: %@", self.myFriendRequests);
                                [self updateGui];
                            }failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                NSLog(@"Error loading friend requests");
                            }];
    
}

#pragma mark RCFriendTableViewCellProtocol
-(void)gotoProfile:(NSString *)username
{
    self.discoverUsername = username;
    [self performSegueWithIdentifier:@"GotoProfileSegue" sender:nil];
    
}

- (void)startBattleWithUsername:(NSString *)username
{
    self.battleUsername = username;
    [self performSegueWithIdentifier:@"BattleUserSegue" sender:nil];
}

#pragma mark Tableview Delegate and Datasource

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
    if ([self.friendsAndRequestsSegmentedControl selectedSegmentIndex] == 0) {
        return [self.myFriends count];
    } else {
        return [self.myFriendRequests count];
    }
}

- (RCFriendTableViewCell *)createFriendTableViewCellForTableview:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = @"FriendCell";
    RCFriendTableViewCell *cell = (RCFriendTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    RCProfile *friend = [self.myFriends objectAtIndex:indexPath.row];
    [cell setFriend:friend];
    
//    cell.profilePictureImageView.layer.cornerRadius  = 5.0;
//    cell.profilePictureImageView.layer.masksToBounds = YES;
    cell.battleButton.layer.cornerRadius  = 5.0;
    cell.battleButton.layer.masksToBounds = YES;
    cell.delegate = self;
    return cell;
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
    [cell setFriendRequest:friendRequest];
    return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if ([self.friendsAndRequestsSegmentedControl selectedSegmentIndex] == 0) {
        cell = [self createFriendTableViewCellForTableview:tableView atIndexPath:indexPath];
    } else {
        cell = [self createFriendRequestCellForTable:tableView atIndexPath:indexPath];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}

#pragma mark - Lazy Loading
-(NSArray *)myFriendRequests
{
    if (_myFriendRequests == nil) {
        _myFriendRequests = [[NSArray alloc] init];
    }
    return _myFriendRequests;
}

- (NSArray *)myFriends
{
    if (_myFriends == nil) {
        _myFriends = [[NSArray alloc] init];
    }
    return _myFriends;
}

@end
