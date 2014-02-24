//
//  RCSearchFriendsViewController.m
//  Rapchat
//
//  Created by Michael Paris on 1/5/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCSearchPeopleViewController.h"
#import "RCSendFriendRequestCell.h"
#import "RCUrlPaths.h"

#import "RCUser.h"
#import "RCProfile.h"

@interface RCSearchPeopleViewController ()

@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSArray *contentList;
@property (strong, nonatomic) NSMutableArray *filteredContentList;

@property (strong, nonatomic) NSSet *friendIds;

@end

@implementation RCSearchPeopleViewController

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
    [self loadFriends];
    self.searchBar.delegate = self;
    [self setTitle:@"Find Friends"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark API Calls
- (void)loadFriends {
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager getObjectsAtPath:myFriendsEndpoint
                         parameters:nil
                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                NSArray *friends = [mappingResult array];
                                NSMutableArray *friendIdArray = [[NSMutableArray alloc] init];
                                for (RCProfile *friend in friends) {
                                    [friendIdArray addObject:friend.user.userId];
                                }
                                self.friendIds = [NSSet setWithArray:friendIdArray];
                                NSLog(@"Done getting friends");
                            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                NSLog(@"Error getting friends: %@", error);
                            }];
}

#pragma mark UISearchBar

- (void) setupSearchBar
{
    // Not used right now. Took off search controller
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar
                                                              contentsController:self];
    self.searchController.delegate = self;
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:YES];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager getObjectsAtPath:searchPeopleEndpoint
                         parameters:@{@"username": self.searchBar.text}
                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                NSLog(@"Successfully Got Results");
                                self.contentList = [mappingResult array];
                                self.contentList = [self.contentList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                                    RCUser *u1 = (RCUser *)obj1;
                                    RCUser *u2 = (RCUser *)obj2;
                                    return [u1.username localizedCaseInsensitiveCompare:u2.username];
                                }];
                                
//                                [self.searchController.searchResultsTableView reloadData];
                                [self.tableView reloadData];
                            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                NSLog(@"Failed to find people");
                            }];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    NSLog(@"Search Display did load results");
}

#pragma mark Table View Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredContentList count];
    } else {
        return [self.contentList count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifer = @"SendFriendRequestCell";
    
    RCSendFriendRequestCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    
    // Configure the cell...
    RCUser *user;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        user = (RCUser *)[self.filteredContentList objectAtIndex:indexPath.row];
    } else {
        user = (RCUser *)[self.contentList objectAtIndex:indexPath.row];
    }
    if ([self.friendIds containsObject:user.userId]) {
        [cell.completeButton setHidden:NO];
        [cell.sendFriendRequestButton setHidden:YES];
    }

    cell.usernameLabel.text = user.username;
    return cell;
}
#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [self.filteredContentList removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.username contains[c] %@",searchText];
    self.filteredContentList = [NSMutableArray arrayWithArray:[self.contentList filteredArrayUsingPredicate:predicate]];
}


#pragma mark Lazy Instantiation
- (NSMutableArray *)filteredContentList
{
    if (!_filteredContentList) {
        _filteredContentList = [[NSMutableArray alloc] init];
    }
    return _filteredContentList;
}

- (NSArray *)contentList
{
    if (!_contentList) {
        _contentList = [[NSArray alloc] init];
    }
    return _contentList;
}

@end
