//
//  RCChooseSongTableViewController.m
//  Rapchat
//
//  Created by Michael Paris on 6/22/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCChooseSongTableViewController.h"
#import "RCAudioRecorderAndPlayer.h"

@interface RCChooseSongTableViewController ()

@property (nonatomic, strong) NSArray *beats;
@property (nonatomic, strong) RCAudioRecorderAndPlayer *player;
@property (nonatomic, strong) RCBeat *currentBeat;

@end

@implementation RCChooseSongTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.beats = @[[[RCBeat alloc] initWithResourceName:@"The Passion HiFi  - The Truth 1" AndTitle:@"The Truth"],
                   [[RCBeat alloc] initWithResourceName:@"simple_beat6" AndTitle:@"Big Black Beat"],
                   [[RCBeat alloc] initWithResourceName:@"flipwhip" AndTitle:@"White Chocolate"],
                   [[RCBeat alloc] initWithResourceName:@"beatbox100bpm" AndTitle:@"Polar Bears Are Tight"],
                   [[RCBeat alloc] initWithResourceName:@"simple_beat5" AndTitle:@"Smells like tight butthole"],
                   [[RCBeat alloc] initWithResourceName:@"simple_beat4" AndTitle:@"McLovin It"],
                   [[RCBeat alloc] initWithResourceName:@"simple_beat3" AndTitle:@"Totes McGoats"],
                   [[RCBeat alloc] initWithResourceName:@"simple_beat2" AndTitle:@"LOL"],
                   [[RCBeat alloc] initWithResourceName:@"simple_beat1" AndTitle:@"60% of the time every time"]];
    self.currentBeat = [self.beats objectAtIndex:0];
    self.player = [[RCAudioRecorderAndPlayer alloc] initWithOutputUrl:nil];
    NSLog(@"RCChooseSongTableViewController");
    self.title = @"Choose a Beat";
    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"grey_washed"]]];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewWillDisappear:(BOOL)animated
{
    
    [self.delegate selectionDidFinishWithSong:self.currentBeat];
    [self.player stopPlayer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - RCChooseSongTableViewCellDelegate
- (void)playButtonTapped
{
    [self.player startPlayerWithUrl:self.currentBeat.url];
}

- (void) pauseButtonTapped
{
    if ([self.player isPlaying]) {
        [self.player pausePlayer];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.beats count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RCChooseSongTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChooseSongCell" forIndexPath:indexPath];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RCChooseSongTableViewCell" owner:self options:nil];
        cell = (RCChooseSongTableViewCell *)[nib objectAtIndex:0];
    }
    // Configure the cell...
    cell.songTitleLabel.text = ((RCBeat*)[self.beats objectAtIndex:indexPath.row]).title;
    cell.delegate = self;
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Pause player if it is playing
    if ([self.player isPlaying]) {
        [self.player pausePlayer];
    }
    // Remove the accessory player button on last selected row
    if (self.currentBeat) {
        NSUInteger index = [self.beats indexOfObjectIdenticalTo:self.currentBeat];
        [((RCChooseSongTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]]) hideAccessoryButton];
    }
    
    self.currentBeat = [self.beats objectAtIndex:indexPath.row];
    
    [((RCChooseSongTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath]) showAccessoryButton];
    [self.player startPlayerWithUrl:self.currentBeat.url];
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
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
