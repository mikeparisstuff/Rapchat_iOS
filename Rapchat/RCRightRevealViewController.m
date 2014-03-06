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

@interface RCRightRevealViewController ()

@property (nonatomic, strong) NSArray *myFriends;
@property (nonatomic, strong) NSString *discoverUsername;
@property (nonatomic, strong) NSString *battleUsername;
@property (nonatomic, strong) NSSet *friendIdSet;

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

- (void)refresh
{
    [self.refreshControl beginRefreshing];
    [self loadFriends];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    [self loadFriends];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if ([self.delegate respondsToSelector:@selector(pushBackFromPresentationMode)]) {
        [self.delegate pushBackFromPresentationMode];
    }
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
    return [self.myFriends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = @"FriendCell";
    RCFriendTableViewCell *cell = (RCFriendTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    RCProfile *friend = [self.myFriends objectAtIndex:indexPath.row];
    [cell setFriend:friend];
    
    cell.profilePictureImageView.layer.cornerRadius  = 5.0;
    cell.profilePictureImageView.layer.masksToBounds = YES;
    cell.battleButton.layer.cornerRadius  = 5.0;
    cell.battleButton.layer.masksToBounds = YES;
    
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}

@end
