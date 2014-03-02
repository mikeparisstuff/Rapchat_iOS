//
//  RCPreviewVideoForReplyViewController.m
//  Rapchat
//
//  Created by Michael Paris on 12/23/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import "RCPreviewVideoForReplyViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <SVProgressHUD.h>
#import "RCVideoReencoder.h"
#import "RCConstants.h"

@interface RCPreviewVideoForReplyViewController ()

@property (nonatomic, strong)AVAssetExportSession *exportSession;
@property (nonatomic, strong) NSTimer *exportSessionTimer;
@property (nonatomic) RCVideoReencoder *videoReencoder;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;


@end

static void * TranscodingContext = &TranscodingContext;

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
    
    self.videoReencoder = [[RCVideoReencoder alloc] init];
    [self.videoReencoder addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
    
    // Add right navigation button to submit the video
//    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(submitClip)];
//    self.navigationItem.rightBarButtonItem = submitButton;
}

- (void)dealloc
{
    @try{
        [self.videoReencoder removeObserver:self forKeyPath:@"status"];
    }@catch(id anException){
        //do nothing, obviously it wasn't attached because an exception was thrown
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Actions
- (IBAction)submitButtonClicked:(UIButton *)sender {
//    [self submitClip];
//    [self convertVideoToMp4];
//    [self loadAssetToReencode];
    [self.submitButton setEnabled:NO];
    [self.videoReencoder loadAssetToReencode:self.videoURL];
}

- (void)submitClip:(NSURL *)path
{
    NSLog(@"Submitting Clip");
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
//    [self convertVideoToMp4];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self.thumbnailImageUrl absoluteString]]) {
        //        [[NSFileManager defaultManager] removeItemAtPath:[self.thumbnailImageUrl absoluteString] error:nil];
        NSLog(@"File exists at path: %@", self.thumbnailImageUrl);
        NSLog(@"File exists at video path: %@", self.videoURL);
    }
    [SVProgressHUD showWithStatus:@"Submitting Rap" maskType:SVProgressHUDMaskTypeBlack];
    
    NSMutableURLRequest *request = [objectManager multipartFormRequestWithObject:nil
                                                                          method:RKRequestMethodPOST
                                                                            path:[NSString stringWithFormat:@"/sessions/%@/clips/", self.sessionId]
                                                                      parameters:nil
                                                       constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                           [formData appendPartWithFileData:[NSData dataWithContentsOfURL:path]
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
                                                                                       [SVProgressHUD showSuccessWithStatus:@"Done"];
                                                                                       [self dismissViewControllerAnimated:YES completion:nil];
                                                                                       //                                                 [self performSegueWithIdentifier:@"BackToFeedSegue" sender:self];
                                                                                       //                                                 [self.navigationController popViewControllerAnimated:NO];
                                                                                   } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                                                       NSLog(@"Error sending clip");
                                                                                       [SVProgressHUD showErrorWithStatus:@"Error"];
                                                                                       [self.submitButton setEnabled:YES];
//                                                                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error"
//                                                                                                                                       message:[error localizedDescription]
//                                                                                                                                      delegate:nil
//                                                                                                                             cancelButtonTitle:@"OK"
//                                                                                                                             otherButtonTitles:nil, nil];
//                                                                                       [alert show];
                                                                                       NSLog(@"Hit error: %@", error);
                                                                                   }];
    [operation start];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"] && [[change objectForKey:NSKeyValueChangeNewKey] isEqualToString:RCVideoReencoderDidFinishSuccessfully]) {
        NSLog(@"keypath: %@", keyPath);
        [self submitClip:[NSURL fileURLWithPath:self.videoReencoder.outputURL]];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}



@end
