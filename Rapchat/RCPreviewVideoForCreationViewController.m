//
//  RCPreviewVideoForCreationViewController.m
//  Rapchat
//
//  Created by Michael Paris on 12/23/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import "RCPreviewVideoForCreationViewController.h"
#import "RCNewSessionInfoViewController.h"

@interface RCPreviewVideoForCreationViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

@implementation RCPreviewVideoForCreationViewController

static NSString *NEW_SESSION_INFO_SEGUE =  @"NewSessionInfoSegue";

- (BOOL)prefersStatusBarHidden
{
    return YES;
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
    
//    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(nextButtonClicked)];
//    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:NEW_SESSION_INFO_SEGUE]) {
        if ([segue.destinationViewController isKindOfClass:[RCNewSessionInfoViewController class]]) {
            RCNewSessionInfoViewController *controller = segue.destinationViewController;
            controller.videoURL = self.videoURL;
            controller.thumbnailImageURL = self.thumbnailImageUrl;
            NSLog(@"Prepared NewSessionInfo");
        }
    }
}


#pragma mark Actions
- (IBAction)nextButtonClicked:(UIButton *)sender {
    [self performSegueWithIdentifier:NEW_SESSION_INFO_SEGUE sender:self];
}


@end
