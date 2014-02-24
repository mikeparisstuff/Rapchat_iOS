//
//  RCFeedbackViewController.m
//  Rapchat
//
//  Created by Michael Paris on 2/19/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCFeedbackViewController.h"
#import "RCUrlPaths.h"
#import <SVProgressHUD.h>


@interface RCFeedbackViewController ()
@property (weak, nonatomic) IBOutlet UITextView *feedbackTextview;

@end

@implementation RCFeedbackViewController

static NSString *STARTING_TEXT = @"Find any bugs, problems, or have any better ideas? Let us know and help make Rapback even better!";

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
    [self setTitle:@"Thank You"];
    [self.navigationItem.leftBarButtonItem setImage:[UIImage imageNamed:@"ic_feedback_nav"]];
    [self.navigationItem.leftBarButtonItem setImageInsets:UIEdgeInsetsZero];
    self.feedbackTextview.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) popToFeed {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:nil];
    UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"LiveFeedController"];
    [self.navigationController setViewControllers:@[controller] animated:YES];
}

#pragma mark Utilities
- (BOOL)validateMessage {
    if ([self.feedbackTextview.text length] != 0 &&  ![self.feedbackTextview.text isEqualToString:STARTING_TEXT]) {
        return YES;
    }
    return NO;
}

#pragma mark Actions
- (IBAction)submitFeedback {
    if ([self validateMessage]) {
        RKObjectManager *objectManager = [RKObjectManager sharedManager];
        [SVProgressHUD showWithStatus:@"Submitting" maskType:SVProgressHUDMaskTypeGradient];
        [objectManager postObject:nil
                             path:feedbackEndpoint
                       parameters:@{@"message": self.feedbackTextview.text}
                    success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                        [SVProgressHUD showSuccessWithStatus:@"Thanks!"];
                        [self popToFeed];
                        NSLog(@"Successfully submitted feedback");
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            NSLog(@"Failed to send feedback");
        }];
    }
}

#pragma mark Textview Delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"]) {
        
        [self.feedbackTextview resignFirstResponder];
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    // For any other character return TRUE so that the text gets added to the view
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([self.feedbackTextview.text isEqualToString:STARTING_TEXT]) {
        self.feedbackTextview.text = @"";
        [self.feedbackTextview setTextAlignment:NSTextAlignmentLeft];
    }
    return YES;
}

@end
