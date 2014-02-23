//
//  RCMyRapsTableViewViewController.m
//  Rapchat
//
//  Created by Michael Paris on 1/12/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCMyRapsTableViewViewController.h"
#import "RCClipTableviewCell.h"
#import "RCClip.h"
#import "RCUrlPaths.h"
#import <SVProgressHUD.h>

@interface RCMyRapsTableViewViewController ()

@property (nonatomic, strong) NSArray *myRaps;
@property (nonatomic, strong) NSURL *clipUrl;
@property (nonatomic, strong) NSNumber *selectedSessionId;

@end

@implementation RCMyRapsTableViewViewController

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
    self.title = @"My Raps";
    [self loadRaps:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateGui
{
    [self.tableView reloadData];
    [SVProgressHUD showSuccessWithStatus:@"Success"];
}

#pragma mark Tableview Delegate
- (RCClipTableviewCell *)createClipCellForTable:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = @"ClipCell";
    RCClipTableviewCell *cell = (RCClipTableviewCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    RCClip *clip = (RCClip *)[self.myRaps objectAtIndex:indexPath.row];
    [cell setCellClip:clip];
    cell.delegate = self;
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
    return [self.myRaps count];
}

// For some reason the height that is specified in the story board
// is not carried through to these calls and thus we need to specify the
// heights explicitly so that the rows do not overlap.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 428;
    return height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self createClipCellForTable:tableView forIndexPath:indexPath];
    return cell;
}

#pragma mark Clip cell delegate
- (void)playVideoInCell:(id)sender
{
    RCClip *clip = [sender getCellClip];
    self.clipUrl = clip.url;
    self.selectedSessionId = clip.clipId;
    [self performSegueWithIdentifier:@"PlayVideoSegue" sender:self];
}

#pragma mark API Calls
- (void)loadRaps:(BOOL)forceRefresh
{
    NSLog(@"Load Raps Clicked");
    if (!self.myRaps || forceRefresh) {
        RKObjectManager *objectManager = [RKObjectManager sharedManager];
        [SVProgressHUD showWithStatus:@"Loading Raps" maskType:SVProgressHUDMaskTypeGradient];
        [objectManager getObjectsAtPath:myClipsEndpoint
                             parameters:nil
                                success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                    self.myRaps = [mappingResult array];
                                    [self updateGui];
                                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                    [SVProgressHUD showErrorWithStatus:@"Network Error"];
                                }];
    }
}
@end
