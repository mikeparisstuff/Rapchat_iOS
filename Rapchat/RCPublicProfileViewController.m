//
//  RCPublicProfileViewController.m
//  Rapchat
//
//  Created by Michael Paris on 1/12/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCPublicProfileViewController.h"
#import "RCPublicProfile.h"
#import "RCLike.h"

#import "RCSessionTableViewCell.h"
#import "RCFriendTableViewCell.h"
#import "RCClipTableviewCell.h"
#import "RCUrlPaths.h"

#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

@interface RCPublicProfileViewController ()

@property (nonatomic, strong) NSArray *likes;
@property (nonatomic, strong) RCProfile *profile;

// Outlets
@property (weak, nonatomic) IBOutlet UIButton *numberOfRapsButton;
@property (weak, nonatomic) IBOutlet UIButton *numberOfLikesButton;
@property (weak, nonatomic) IBOutlet UIButton *numberOfFriendsButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (weak, nonatomic) IBOutlet UIButton *addFriendButton;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@end

@implementation RCPublicProfileViewController

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
    
    [self.segmentedControl addTarget:self action:@selector(segmentedControlIndexDidChange) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadProfile];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateProfile
{
    self.navigationItem.title = self.profile.user.username;
    [self setProfileHeaderInfo];
    [self.tableView reloadData];
}

- (void)setProfileHeaderInfo
{
    [self.numberOfFriendsButton setTitle:[NSString stringWithFormat:@"%@", self.profile.numberOfFriends] forState:UIControlStateNormal];
    [self.numberOfLikesButton setTitle:[NSString stringWithFormat:@"%@", self.profile.numberOfLikes] forState:UIControlStateNormal];
    [self.numberOfRapsButton setTitle:[NSString stringWithFormat:@"%@", self.profile.numberOfRaps] forState:UIControlStateNormal];
    [self.profilePictureImageView setImageWithURL:self.profile.profilePictureURL
                      usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    if ([self.friendIdSet containsObject:self.profile.profileId]) {
        [self.addFriendButton setTitle:@"Remove Friend" forState:UIControlStateNormal];
        [self.addFriendButton setBackgroundColor:[UIColor colorWithRed:226.0/255.0 green:66.0/255.0 blue:51.0/255.0 alpha:.95]];
        [self.addFriendButton removeTarget:self action:@selector(sendFriendRequest:) forControlEvents:UIControlEventTouchUpInside];
        [self.addFriendButton addTarget:self action:@selector(removeFriend) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.addFriendButton setTitle:@"Add Friend" forState:UIControlStateNormal];
        [self.addFriendButton removeTarget:self action:@selector(removeFriend) forControlEvents:UIControlEventTouchUpInside];
        [self.addFriendButton addTarget:self action:@selector(sendFriendRequest:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)segmentedControlIndexDidChange
{
    [self.tableView reloadData];
}


#pragma mark API Calls
- (void) loadProfile
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager getObjectsAtPath:[NSString stringWithFormat:@"/users/%@/", self.discoverUsername]
                         parameters:nil
                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                RCPublicProfile *publicProfile = [mappingResult firstObject];
                                self.likes = publicProfile.likes;
                                self.profile = publicProfile.profile;
                                self.profile.friends = [self.profile.friends sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                                    RCProfile *prof1 = (RCProfile *)obj1;
                                    RCProfile *prof2 = (RCProfile *)obj2;
                                    NSLog(@"Comparing: %@ to %@", prof1.user.username, prof2.user.username);
                                    return [prof1.user.username localizedCaseInsensitiveCompare:prof2.user.username];
                                }];
                                NSLog(@"Got Public Profile");
                                [self updateProfile];
                            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                NSLog(@"Error: %@", error);
                            }];
}

- (void)removeFriend {
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager deleteObject:nil
                           path:myFriendsEndpoint
                     parameters:@{@"username": self.discoverUsername}
                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                            NSLog(@"Successfully Removed Friend");
                            [self.addFriendButton setTitle:@"Removed" forState:UIControlStateNormal];
                            [self.addFriendButton setEnabled:NO];
                        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                            NSLog(@"Could not remove friend with error: %@", error);
                        }];
}

- (IBAction)sendFriendRequest:(UIButton *)sender {
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager postObject:nil
                         path:myFriendRequestsEndpoint
                   parameters:@{@"username": self.discoverUsername}
                      success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                          [self.addFriendButton setTitle:@"Sent!" forState:UIControlStateNormal];
                          [self.addFriendButton setEnabled:NO];
                          NSLog(@"Successfully sent friend request");
                      } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                          NSLog(@"Failed to send friend request");
                      }];

}


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
    switch ([self.segmentedControl selectedSegmentIndex]) {
        case 0:
            numElements = [self.profile.friends count];
            break;
        case 1:
            numElements = [self.likes count];
            break;
//        case 3:
//            numElements = [self.myFriendRequests count];
//            break;
    }
    return numElements;
}

// For some reason the height that is specified in the story board
// is not carried through to these calls and thus we need to specify the
// heights explicitly so that the rows do not overlap.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 50;
    switch ([self.segmentedControl selectedSegmentIndex]) {
        case 0:
            height = 75;
            break;
        case 1:
            height = 428;
            break;
//        case 3:
//            height = 45;
//            break;
    }
    return height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    switch ([self.segmentedControl selectedSegmentIndex]) {
        case 0:
            cell = [self createFriendCellForTable:tableView forIndexPath:indexPath];
            break;
        case 1:
            cell = [self createSessionCellForTable:tableView forIndexPath:indexPath];
            break;
//        case 3:
//            cell = [self createClipCellForTable:tableView forIndexPath:indexPath];
//            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([self.segmentedControl selectedSegmentIndex]) {
        case 0:
            // Load new profile
            self.discoverUsername = [(RCFriendTableViewCell *)[tableView cellForRowAtIndexPath:indexPath] getFriendsUsername];
            [self loadProfile];
            break;
            
        default:
            break;
    }
}

#pragma mark Tableview Utility Methods
- (RCSessionTableViewCell *)createSessionCellForTable:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = @"SessionCell";
    RCSessionTableViewCell *cell = (RCSessionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    RCSession *session = [(RCLike *)[self.likes objectAtIndex:indexPath.row] session];
    [cell setCellSession:session];
    [cell.likeButton setSelected:YES];
    cell.delegate = self;
    return cell;
}

- (RCFriendTableViewCell *)createFriendCellForTable:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = @"FriendCell";
    RCFriendTableViewCell *cell = (RCFriendTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    RCProfile *friend = [self.profile.friends objectAtIndex:indexPath.row];
    [cell setFriend:friend];
    cell.delegate = self;
    return cell;
}

//- (RCClipTableviewCell *)createClipCellForTable:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath
//{
//    NSString *reuseIdentifier = @"ClipCell";
//    RCClipTableviewCell *cell = (RCClipTableviewCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
//    RCClip *clip = (RCClip *)[self.myRaps objectAtIndex:indexPath.row];
//    [cell setCellClip:clip];
//    cell.delegate = self;
//    return cell;
//}


@end
