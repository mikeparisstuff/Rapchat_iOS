//
//  RCPreviewVideoForReplyViewController.m
//  Rapchat
//
//  Created by Michael Paris on 12/23/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import "RCPreviewVideoForReplyViewController.h"

@interface RCPreviewVideoForReplyViewController ()

@end

@implementation RCPreviewVideoForReplyViewController


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
    
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    // Add right navigation button to submit the video
//    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(submitClip)];
//    self.navigationItem.rightBarButtonItem = submitButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Actions
- (IBAction)submitButtonClicked:(UIButton *)sender {
    [self submitClip];
}

- (void)submitClip
{
    NSLog(@"Submitting Clip");
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self.thumbnailImageUrl absoluteString]]) {
        //        [[NSFileManager defaultManager] removeItemAtPath:[self.thumbnailImageUrl absoluteString] error:nil];
        NSLog(@"File exists at path: %@", self.thumbnailImageUrl);
    }
    NSMutableURLRequest *request = [objectManager multipartFormRequestWithObject:nil
                                                                          method:RKRequestMethodPOST
                                                                            path:[NSString stringWithFormat:@"/sessions/%@/clips/", self.sessionId]
                                                                      parameters:nil
                                                       constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                           [formData appendPartWithFileData:[NSData dataWithContentsOfURL:self.videoURL]
                                                                                       name:@"clip"
                                                                                   fileName:@"movie.mp4"
                                                                                   mimeType:@"video/mp4"];
                                                           //                                                           NSLog(@"Submitting thumbnail: %@", self.thumbnailImageUrl);
                                                           [formData appendPartWithFileData:[NSData dataWithContentsOfFile:[self.thumbnailImageUrl absoluteString]]
                                                                                       name:@"thumbnail"
                                                                                   fileName:@"thumbnail.jpg"
                                                                                   mimeType:@"image/jpg"];
                                                           //                                                            NSLog(@"Form Data: %@", formData);
                                                       }];
    NSLog(@"URLRequest: %@", request);
    
    RKObjectRequestOperation *operation = [objectManager objectRequestOperationWithRequest:request
                                                                                   success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                                                       NSLog(@"Successfully uploaded video to server");
                                                                                       //                                                 [self.navigationController popToRootViewControllerAnimated:NO];
                                                                                       [self dismissViewControllerAnimated:YES completion:nil];
                                                                                       //                                                 [self performSegueWithIdentifier:@"BackToFeedSegue" sender:self];
                                                                                       //                                                 [self.navigationController popViewControllerAnimated:NO];
                                                                                   } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                                                       NSLog(@"Error sending clip");
                                                                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error"
                                                                                                                                       message:[error localizedDescription]
                                                                                                                                      delegate:nil
                                                                                                                             cancelButtonTitle:@"OK"
                                                                                                                             otherButtonTitles:nil, nil];
                                                                                       [alert show];
                                                                                       NSLog(@"Hit error: %@", error);
                                                                                   }];
    [operation start];
}


@end
