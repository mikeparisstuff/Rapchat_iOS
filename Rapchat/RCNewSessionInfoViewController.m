//
//  RCCreateNewSessionViewController.m
//  Rapchat
//
//  Created by Michael Paris on 12/23/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import "RCNewSessionInfoViewController.h"
#import "RCFriendTableViewCell.h"
#import "RCCrowdTableViewCell.h"
#import "RCProfile.h"
#import "RCCrowd.h"
#import "RCVideoReencoder.h"
#import "RCConstants.h"
#import "RCUrlPaths.h"

@interface RCNewSessionInfoViewController ()
//@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *crowdTitleView;


// New Session Data
@property (nonatomic) RCCrowd *selectedCrowd;
@property (nonatomic) NSMutableArray *selectedFriendsForCrowd;

// Data sources
@property (nonatomic, strong) NSArray *myCrowds;
@property (nonatomic, strong) NSArray *myFriends;

// Video Reencoder
@property (nonatomic) RCVideoReencoder *videoReencoder;

@end

@implementation RCNewSessionInfoViewController

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
    self.titleTextField.delegate = self;
    
    [self setTitle:@"New Session"];

    self.videoReencoder = [[RCVideoReencoder alloc] init];
    [self.videoReencoder addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
    
//    NSLog(@"Loading image with url: %@", self.thumbnailImageURL);
//    [self.backgroundImageView setImage:[[UIImage alloc] initWithContentsOfFile:[self.thumbnailImageURL absoluteString]]];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonClicked)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self.segmentedControl selectedSegmentIndex] == 0) {
        [self setCrowdTitleViewEnabled:NO];
    }
    
    [self performSelector:NSSelectorFromString([self validSelectorsForSegmentedControl][[self.segmentedControl selectedSegmentIndex]])];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Observers
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"] && [[change objectForKey:NSKeyValueChangeNewKey] isEqualToString:RCVideoReencoderDidFinishSuccessfully]) {
//        NSLog(@"keypath: %@", keyPath);
        self.videoURL = [NSURL fileURLWithPath:self.videoReencoder.outputURL];
        [self submitSession];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark Submit Session
- (void)doneButtonClicked
{
    [self.videoReencoder loadAssetToReencode:self.videoURL];
}

- (void)submitSession {
    if ([self confirmValidData]) {
        switch ([self.segmentedControl selectedSegmentIndex]) {
            case 0:
                [self submitSessionWithExistingCrowd];
                break;
            case 1:
                [self submitSessionWithNewCrowd];
                break;
        }
    }
}

- (void)submitSessionWithExistingCrowd
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];

    NSLog(@"Submitting Clip with Existing Crowd");
    NSMutableURLRequest *request = [objectManager multipartFormRequestWithObject:nil
                                                                          method:RKRequestMethodPOST
                                                                            path:mySessionsEndpoint
                                                                      parameters:@{
                                                                                   @"crowd": self.selectedCrowd.crowdId,
                                                                                   @"use_existing_crowd": @YES,
                                                                                   @"title": self.titleTextField.text
                                                                                   }
                                                       constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                           [formData appendPartWithFileData:[NSData dataWithContentsOfURL:self.videoURL]
                                                                                       name:@"clip"
                                                                                   fileName:@"movie.mp4"
                                                                                   mimeType:@"video/mp4"];
                                                           //                                                           NSLog(@"Submitting thumbnail: %@", self.thumbnailImageUrl);
                                                           [formData appendPartWithFileData:[NSData dataWithContentsOfFile:[self.thumbnailImageURL absoluteString]]
                                                                                       name:@"thumbnail"
                                                                                   fileName:@"thumbnail.jpg"
                                                                                   mimeType:@"image/jpg"];
                                                           //                                                            NSLog(@"Form Data: %@", formData);
                                                       }];
    RKObjectRequestOperation *operation = [objectManager objectRequestOperationWithRequest:request
                                                                                   success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                                                       [self dismissViewControllerAnimated:YES completion:nil];
                                                                                   }
                                                                                   failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error"
                                                                                                                                       message:[error localizedDescription]
                                                                                                                                      delegate:nil
                                                                                                                             cancelButtonTitle:@"OK"
                                                                                                                             otherButtonTitles:nil, nil];
                                                                                       [alert show];
                                                                                   }];
    [operation start];
}

- (void)submitSessionWithNewCrowd
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    NSMutableArray *crowdMembers = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.selectedFriendsForCrowd count]; i++) {
        if ([self.selectedFriendsForCrowd[i] isKindOfClass:[RCProfile class]]) {
            RCProfile *profile = (RCProfile *)self.selectedFriendsForCrowd[i];
            [crowdMembers addObject:profile.user.username];
        }
    }
    NSError *error = [[NSError alloc] init];
    NSData *memberData = [NSJSONSerialization dataWithJSONObject:crowdMembers options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:memberData encoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [objectManager multipartFormRequestWithObject:nil
                                                                          method:RKRequestMethodPOST
                                                                            path:mySessionsEndpoint
                                                                      parameters:@{
                                                                                   @"crowd_title": self.crowdTitleView.text,
                                                                                   @"crowd_members": jsonString,
                                                                                   @"use_existing_crowd": @"False",
                                                                                   @"title": self.titleTextField.text
                                                                                   }
                                                       constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                           [formData appendPartWithFileData:[NSData dataWithContentsOfURL:self.videoURL]
                                                                                       name:@"clip"
                                                                                   fileName:@"movie.mp4"
                                                                                   mimeType:@"video/mp4"];
                                                           //                                                           NSLog(@"Submitting thumbnail: %@", self.thumbnailImageUrl);
                                                           [formData appendPartWithFileData:[NSData dataWithContentsOfFile:[self.thumbnailImageURL absoluteString]]
                                                                                       name:@"thumbnail"
                                                                                   fileName:@"thumbnail.jpg"
                                                                                   mimeType:@"image/jpg"];
                                                           //                                                            NSLog(@"Form Data: %@", formData);
                                                       }];
    RKObjectRequestOperation *operation = [objectManager objectRequestOperationWithRequest:request
                                                                                   success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                                                       [self dismissViewControllerAnimated:YES completion:nil];
                                                                                   }
                                                                                   failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error"
                                                                                                                                       message:[error localizedDescription]
                                                                                                                                      delegate:nil
                                                                                                                             cancelButtonTitle:@"OK"
                                                                                                                             otherButtonTitles:nil, nil];
                                                                                       [alert show];
                                                                                   }];
    [operation start];
    
}

- (BOOL) confirmValidData
{
    if ([self.titleTextField.text length] > 0) {
        switch ([self.segmentedControl selectedSegmentIndex]) {
            case 0:
                if (self.selectedCrowd) {
                    return YES;
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Select a Crowd!"
                                                                    message:@"You must select a crowd"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil, nil];
                    [alert show];
                }
                break;
            case 1:
                if ([self.selectedFriendsForCrowd count] > 0 && [self.crowdTitleView.text length] > 0) {
                    return YES;
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Need Friends!"
                                                                    message:@"You must select atleast 1 friend"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil, nil];
                    [alert show];
                }
                break;
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Need a Title!"
                                                        message:@"You must give a title"
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
    return NO;
}

#pragma mark Text Field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
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
    switch ([self.segmentedControl selectedSegmentIndex]) {
        case 0:
            numElements = [self.myCrowds count];
            break;
        case 1:
            numElements = [self.myFriends count];
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
    switch ([self.segmentedControl selectedSegmentIndex]) {
        case 0:
            height = 70;
            break;
        case 1:
            height = 60;
            break;
    }
    return height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    switch ([self.segmentedControl selectedSegmentIndex]) {
        case 0:
            cell = [self createCrowdCellForTable:tableView atIndexPath:indexPath];
            break;
        case 1:
            cell = [self createFriendCellForTable:tableView atIndexPath:indexPath];
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    switch ([self.segmentedControl selectedSegmentIndex]) {
        case 0:
            // Only 1 crowd should be able to be selected
            [self clearCheckmarksForTableView:tableView];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_checkbox_green"]];
            self.selectedCrowd = [self.myCrowds objectAtIndex:indexPath.row];
            break;
        case 1:
            if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.accessoryView = nil;
                NSLog(@"Removing friend from cell %ld", (long)indexPath.row);
                // Remove friend from array when deselecting row
                [self.selectedFriendsForCrowd removeObject:[self.myFriends objectAtIndex:indexPath.row]];
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_checkbox_green"]];
                // Add friend when selecting row
                NSLog(@"Adding friend from cell %ld", (long)indexPath.row);
                [self.selectedFriendsForCrowd addObject:[self.myFriends objectAtIndex:indexPath.row]];
            }
            break;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (cell.isSelected) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark; // No reason to create a new one every time, right?
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

#pragma mark Segmented Control Delegate
- (IBAction)segmentItemChanged:(UISegmentedControl *)sender
{
    switch ([sender selectedSegmentIndex]) {
        case 0:
            [self setCrowdTitleViewEnabled:NO];
            break;
        case 1:
            [self setCrowdTitleViewEnabled:YES];
            break;
    }
    [self performSelector:NSSelectorFromString([self validSelectorsForSegmentedControl][[self.segmentedControl selectedSegmentIndex]])];
}

- (void) setCrowdTitleViewEnabled:(BOOL)enabled
{
    if (enabled) {
        [self.crowdTitleView setEnabled:YES];
        [self.crowdTitleView setBackgroundColor:[UIColor whiteColor]];
    } else {
        [self.crowdTitleView setEnabled:NO];
        [self.crowdTitleView setBackgroundColor:[UIColor lightGrayColor]];
    }
    
}

#pragma mark Utility Methods
- (NSArray *)validSelectorsForSegmentedControl
{
    return @[@"loadExistingCrowds", @"loadFriends"];
}

- (void)updateGui
{
    [self.tableView reloadData];
}

- (void)clearCheckmarksForTableView:(UITableView *)tableView
{
    for (int i = 0; i < [self.myCrowds count]; i++) {
        [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]].accessoryType = UITableViewCellAccessoryNone;
        [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]].accessoryView = nil;
    }
}

- (RCFriendTableViewCell *)createFriendCellForTable:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = @"FriendCell";
    RCFriendTableViewCell *cell = (RCFriendTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[RCFriendTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    // Configure the cell...
    RCProfile *friend = [self.myFriends objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.usernameLabel.text = friend.user.username;
//    NSLog(@"Inserting Cell with Profile: %@", cell);
    return cell;
}

- (RCCrowdTableViewCell *)createCrowdCellForTable:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = @"CrowdCell";
    RCCrowdTableViewCell *cell = (RCCrowdTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[RCCrowdTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    // Configure the cell...
    RCCrowd *crowd = [self.myCrowds objectAtIndex:indexPath.row];
    cell.titleLabel.text = crowd.title;
    cell.numberOfMembersLabel.text = [NSString stringWithFormat:@"%lu members", (unsigned long)[crowd.members count]];
    return cell;
}

#pragma mark API Calls
- (void)loadExistingCrowds
{
    NSLog(@"Load Crowds Clicked");
    if (!self.myCrowds) {
        RKObjectManager *objectManager = [RKObjectManager sharedManager];
        [objectManager getObjectsAtPath:myCrowdsEndpoint
                             parameters:nil
                                success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                    self.myCrowds = [mappingResult array];
//                                    NSLog(@"Got Crowds: %@", self.myCrowds);
                                    self.myCrowds = [self.myCrowds sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                                        RCCrowd *c1 = (RCCrowd *)obj1;
                                        RCCrowd *c2 = (RCCrowd *)obj2;
                                        return [c1.title compare:c2.title];
                                    }];
                                    [self updateGui];
                                }failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error"
                                                                                    message:[error localizedDescription]
                                                                                   delegate:nil
                                                                          cancelButtonTitle:@"OK"
                                                                          otherButtonTitles:nil, nil];
                                    [alert show];
                                }];
    } else {
        [self updateGui];
    }
}

- (void)loadFriends
{
    NSLog(@"Load Friends");
    if (!self.myFriends) {
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
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error"
                                                                                    message:[error localizedDescription]
                                                                                   delegate:nil
                                                                          cancelButtonTitle:@"OK"
                                                                          otherButtonTitles:nil, nil];
                                    [alert show];
                                }];
    } else {
        [self updateGui];
    }
}

#pragma mark Getters and Setters
- (NSMutableArray *)selectedFriendsForCrowd
{
    if (!_selectedFriendsForCrowd) {
        _selectedFriendsForCrowd = [[NSMutableArray alloc] init];
    }
    return _selectedFriendsForCrowd;
}


@end
