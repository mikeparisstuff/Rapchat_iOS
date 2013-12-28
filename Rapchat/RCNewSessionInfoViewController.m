//
//  RCCreateNewSessionViewController.m
//  Rapchat
//
//  Created by Michael Paris on 12/23/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import "RCNewSessionInfoViewController.h"

@interface RCNewSessionInfoViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;

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
    
    NSLog(@"Loading image with url: %@", self.thumbnailImageURL);
    [self.backgroundImageView setImage:[[UIImage alloc] initWithContentsOfFile:[self.thumbnailImageURL absoluteString]]];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(submitSession)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Submit Session
- (void)submitSession
{
    
}

#pragma mark Text Field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

@end
