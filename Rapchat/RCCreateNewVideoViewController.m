//
//  RCCreateNewVideoViewController.m
//  Rapchat
//
//  Created by Michael Paris on 12/8/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import "RCCreateNewVideoViewController.h"

@interface RCCreateNewVideoViewController ()
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@end

@implementation RCCreateNewVideoViewController

- (IBAction)backButtonClicked
{
//    [self.navigationController popViewControllerAnimated:YES];
//    [self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)beatsButtonClicked:(id)sender
{
    NSLog(@"Record Button Clicked");
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
    
    // Set the beats button on the middle of the toolbar
    [self setBeatsButtonOnMiddleOfToolbar];

    
    NSLog(@"RCCreateNewVideoViewController on screen");

}

- (void)setBeatsButtonOnMiddleOfToolbar
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *buttonImage = [UIImage imageNamed:@"ic_beats_flat"];
    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    CGFloat heightDifference = buttonImage.size.height - self.toolbar.frame.size.height;
    if (heightDifference < 0)
        button.center = self.toolbar.center;
    else
    {
        CGPoint center = self.toolbar.center;
        center.y = center.y - heightDifference/2.0;
        button.center = center;
    }
    [button addTarget:self action:@selector(beatsButtonClicked:) forControlEvents:UIControlEventAllEvents];
    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
