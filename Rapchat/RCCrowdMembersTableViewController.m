//
//  RCCrowdMembersTableViewController.m
//  Rapchat
//
//  Created by Michael Paris on 1/25/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCCrowdMembersTableViewController.h"
#import "RCFriendTableViewCell.h"

@interface RCCrowdMembersTableViewController ()

@end

@implementation RCCrowdMembersTableViewController

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
    self.title = self.crowd.title;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Tableview Delegate
- (RCFriendTableViewCell *)createCrowdCellForTable:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = @"MemberCell";
    RCFriendTableViewCell *cell = (RCFriendTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    RCProfile *profile = (RCProfile *)[self.crowd.members objectAtIndex:indexPath.row];
    [cell setFriend:profile];
//    cell.delegate = self;
    return cell;
}

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
    return [self.crowd.members count];
}

// For some reason the height that is specified in the story board
// is not carried through to these calls and thus we need to specify the
// heights explicitly so that the rows do not overlap.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 75;
    return height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self createCrowdCellForTable:tableView forIndexPath:indexPath];
    return cell;
}

@end
