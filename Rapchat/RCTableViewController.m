//
//  RCTableViewController.m
//  Rapchat
//
//  Created by Michael Paris on 12/13/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import "RCTableViewController.h"
#import "RCTabBarController.h"

@interface RCTableViewController ()

@end

@implementation RCTableViewController

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
    
//    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonClicked:)];
//    NSArray *actionButtonItems = @[searchItem];
//    self.navigationItem.rightBarButtonItems = actionButtonItems;
    
    // Set translucent no so that the statusbar color matches
    [self.navigationController.navigationBar setTranslucent:NO];
    self.extendedLayoutIncludesOpaqueBars = YES;
    
//    self.showTabBar = YES;
    

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self setTabBarVisible];
}

//- (void)setTabBarVisible
//{
//    if (self.showTabBar) {
//        RCTabBarController *tabBarController = (RCTabBarController *)self.tabBarController;
//        [tabBarController setTabBarHidden:NO animated:YES];
//    } else {
//        RCTabBarController *tabBarController = (RCTabBarController *)self.tabBarController;
//        [tabBarController setTabBarHidden:YES animated:YES];
//    }
//}

//- (void)searchButtonClicked:(id)sender
//{
//    NSLog(@"Search Clicked");
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
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
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

//- (BOOL) prefersStatusBarHidden
//{
//    if(hidden)
//        return YES;
//    return NO;
//}


@end
