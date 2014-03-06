//
//  RCCameraViewController.m
//  Rapchat
//
//  Created by Michael Paris on 12/16/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import "RCCameraViewController.h"
#import "RCCameraView.h"
#import "RCFilePlayerView.h"
#import "RCPreviewFileViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "RCProgressView.h"
#import "RCUtility.h"

#define TIMER_INTERVAL 0.05
#define MAX_CLIP_LENGTH 15.0

static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * RecordingContext = &RecordingContext;
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;

// Define this content for the key-value observation context
static const NSString *ItemStatusContext;

@interface RCCameraViewController () <AVCaptureFileOutputRecordingDelegate>

// For use in the storyboards.
@property (weak, nonatomic) IBOutlet RCCameraView *previewView;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *stillButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UIButton *swapsongButton;

// Progress View
@property (nonatomic, strong) RCProgressView *progressView;
//@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic, strong) NSTimer *myTimer;


- (IBAction)recordingButtonDown:(UIButton *)sender;
- (IBAction)recordingButtonReleased:(UIButton *)sender;

- (IBAction)changeCamera:(id)sender;
- (IBAction)snapStillImage:(id)sender;
- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer;
- (IBAction)backButtonClicked:(id)sender;

// Session management.
@property (nonatomic) dispatch_queue_t sessionQueue; // Communicate with the session and other session objects on this queue.
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic) NSURL *videoURL;

// Audio Player
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

// Thumbnail
@property (nonatomic) NSURL *thumbnailUrl;

// Utilities.
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property (nonatomic) BOOL lockInterfaceRotation;
@property (nonatomic) id runtimeErrorHandlingObserver;

@end

@implementation RCCameraViewController
{
    float timerCount;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)isSessionRunningAndDeviceAuthorized
{
    return [[self session] isRunning] && [self isDeviceAuthorized];
}

+ (NSSet *)keyPathsForValuesAffectingSessionRunningAndDeviceAuthorized
{
    return [NSSet setWithObjects:@"session.running", @"deviceAuthorized", nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self.cameraButton ]
//    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonClicked:)]
    
    // Create the AVCaptureSession
    AVCaptureSession *session = [[AVCaptureSession alloc] init];

    [session setSessionPreset:AVCaptureSessionPresetMedium];
    
    
//    [session setSessionPreset:AVCaptureSessionPreset640x480];
    
    [self setSession:session];
    
    // Setup the preview view
    [[self previewView] setSession:session];
    
    // Check for device authorization
    [self checkDeviceAuthorizationStatus];
    
    // Set url
    self.thumbnailImageUrl = [NSURL URLWithString:[NSTemporaryDirectory() stringByAppendingPathComponent:[@"thumbnail" stringByAppendingPathExtension:@"jpg"]]];
    
    // Dispatch the rest of session setup to the sessionQueue so that the main queue isn't blocked.
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    [self setSessionQueue:sessionQueue];
    
    dispatch_async(sessionQueue, ^{
        [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
        
        NSError *error = nil;
        
        AVCaptureDevice *videoDevice = [RCCameraViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
        if (error)
        {
            NSLog(@"%@", error);
        }
        
        if ([session canAddInput:videoDeviceInput])
        {
            [session addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
        }
        
        AVCaptureDevice *audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
        AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
        
        if (error)
        {
            NSLog(@"%@", error);
        }
        
        if ([session canAddInput:audioDeviceInput])
        {
            [session addInput:audioDeviceInput];
        }
        
        AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        if ([session canAddOutput:movieFileOutput])
        {
            [session addOutput:movieFileOutput];
            AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            if ([connection isVideoStabilizationSupported])
                [connection setEnablesVideoStabilizationWhenAvailable:YES];
            [self setMovieFileOutput:movieFileOutput];
        }
        
        AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        if ([session canAddOutput:stillImageOutput])
        {
            [stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
            [session addOutput:stillImageOutput];
            [self setStillImageOutput:stillImageOutput];
        }
    });
    
//    [self.view sendSubviewToBack:self.progressView];
    [self setupProgressView];
    [self setupIphone5Screen];
    
    //Detect Screen Size and hide use normal progress bar
    if ([RCUtility hasIphone5Screen]) {
        [self setupIphone5Screen];
    } else {
        [self setupIphone4Screen];
    }
    
    [self setupAudio];
}

- (void) setupProgressView {
    // Create the progress view
    // On the custome view you need to set the frame twice because it overwrites the frame in init
    [self.navigationController.navigationBar setTranslucent:YES];
    self.progressView=[[RCProgressView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-96, 325, 96)];
    self.progressView.frame = CGRectMake(0, self.view.frame.size.height-96, 325, 96);
    [self.view addSubview:self.progressView];
//    [self.view sendSubviewToBack:self.previewView];
    [self.view sendSubviewToBack:self.progressView];
}

- (void)setupIphone5Screen {
    // Setup iphone 5 screen
    NSLog(@"Setup iphone 5 screen");

}

- (void)setupIphone4Screen {
    // Setup iphone 4 screen
    NSLog(@"Setting up iphone 4 screen");
}

- (void)viewWillAppear:(BOOL)animated
{
    [self disableButtons];
    // Reset the progress view
    timerCount = 0.0;
    [self.progressView setProgress:0 animated:NO];
    
    dispatch_async([self sessionQueue], ^{
        [self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
        [self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:CapturingStillImageContext];
        [self addObserver:self forKeyPath:@"movieFileOutput.recording" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:RecordingContext];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
        
        __weak RCCameraViewController *weakSelf = self;
        [self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self session] queue:nil usingBlock:^(NSNotification *note) {
            RCCameraViewController *strongSelf = weakSelf;
            dispatch_async([strongSelf sessionQueue], ^{
                // Manually restarting the session since it must have been stopped due to an error.
                [[strongSelf session] startRunning];
                [[strongSelf recordButton] setTitle:NSLocalizedString(@"Record", @"Recording button record title") forState:UIControlStateNormal];
            });
        }]];
        [[self session] startRunning];
        [self enableButtons];
        [self playAudio];
    });
    
    // Set back button if necessary
    if ([[self.navigationController viewControllers] count] > 1) {
        NSLog(@"Nav Controller is not nil");
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_back"] style:UIBarButtonItemStylePlain target:self action:@selector(backPressed)];
        self.navigationItem.leftBarButtonItem = backButton;
    }
    [super viewWillAppear:animated];
}

- (void)backPressed
{
    if ([[self.navigationController viewControllers] count] > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void) enableButtons
{
    [self.recordButton setEnabled:YES];
}

- (void)disableButtons
{
    [self.recordButton setEnabled:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[self audioPlayer] stop];
    dispatch_async([self sessionQueue], ^{
        [[self session] stopRunning];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
        [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
        
        [self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
        [self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
        [self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"PreviewVideoSegue"]) {
            if ([segue.destinationViewController isKindOfClass:[RCPreviewFileViewController class]]) {
                RCPreviewFileViewController *pfvc = (RCPreviewFileViewController *)segue.destinationViewController;
                pfvc.videoURL = self.videoURL;
                //[self.movieFileOutput outputFileURL];
                NSLog(@"PreviewVideoSegue being prepared with url: %@", pfvc.videoURL);
            }
    }
}

- (NSURL *)getVideoUrl
{
    return self.videoURL;
}

- (BOOL)shouldAutorotate
{
    // Disable autorotation of the interface when recording is in progress.
    return ![self lockInterfaceRotation];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)toInterfaceOrientation];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == CapturingStillImageContext)
    {
        BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
        
        if (isCapturingStillImage)
        {
            [self runStillImageCaptureAnimation];
        }
    }
    else if (context == RecordingContext)
    {
        BOOL isRecording = [change[NSKeyValueChangeNewKey] boolValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isRecording)
            {
                [[self cameraButton] setEnabled:NO];
                [[self homeButton] setEnabled:NO];
                [[self swapsongButton] setEnabled:NO];
//                [[self recordButton] setTitle:NSLocalizedString(@"Release To Stop", @"Recording button stop title") forState:UIControlStateNormal];
//                [self.recordButton setAlpha:0.0f];
                [[self recordButton] setEnabled:YES];
            }
            else
            {
                [[self cameraButton] setEnabled:YES];
                [[self homeButton] setEnabled:YES];
                [[self swapsongButton] setEnabled:YES];
//                [[self recordButton] setTitle:NSLocalizedString(@"Hold To Record", @"Recording button record title") forState:UIControlStateNormal];
                [[self recordButton] setEnabled:YES];
            }
        });
    }
    else if (context == SessionRunningAndDeviceAuthorizedContext)
    {
        BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isRunning)
            {
                [[self cameraButton] setEnabled:YES];
                [[self recordButton] setEnabled:YES];
                [[self stillButton] setEnabled:YES];
            }
            else
            {
                [[self cameraButton] setEnabled:NO];
                [[self recordButton] setEnabled:NO];
                [[self stillButton] setEnabled:NO];
            }
        });
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark Audio
- (void)setupAudio
{
    self.beats = @[@"flipwhip", @"simple_beat1", @"simple_beat2", @"simple_beat3", @"beatbox100bpm", @"simple_beat6", @"nil"];
    self.beatNumber = 0;
    self.currentBeat = [self.beats objectAtIndex:self.beatNumber];
}

- (void)playAudio
{
    NSLog(@"Play Audio");
//    NSString *soundFilePath = [NSString stringWithFormat:@"%@/test.mp3", [[NSBundle mainBundle] resourcePath]];
    if (![self.currentBeat isEqualToString:@"nil"]) {
        NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:self.currentBeat ofType:@"mp3"];
        NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
        
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
        self.audioPlayer.numberOfLoops = -1; //Infinite
        
        [self.audioPlayer play];
    } else {
        [self.audioPlayer pause];
    }
    
}

- (void)reloadAudio
{
    [self.audioPlayer stop];
    [self playAudio];
}

- (void)changeSong
{
    self.beatNumber = (self.beatNumber + 1) % [self.beats count];
    self.currentBeat = [self.beats objectAtIndex:self.beatNumber];
    [self reloadAudio];
}

#pragma mark Timer

- (void)startTimer
{
    NSLog(@"Starting Timer");
    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateProgressView) userInfo:nil repeats:YES];
}


- (void)updateProgressView
{
    timerCount += TIMER_INTERVAL;
//    NSLog(@"Timer set with count: %f", timerCount);
    if (timerCount <= MAX_CLIP_LENGTH) {
        [self.progressView setProgress:(float)timerCount/MAX_CLIP_LENGTH animated:YES];
        self.timerProgress =(float) timerCount/MAX_CLIP_LENGTH;
    } else {
        [self recordingButtonReleased:nil];
    }
    
}

#pragma mark Actions

- (IBAction)recordingButtonDown:(UIButton *)sender {
    [self toggleMovieRecording];
    [self startTimer];
}

- (IBAction)recordingButtonReleased:(UIButton *)sender {
    [self.myTimer invalidate];
    [self toggleMovieRecording];
}

- (IBAction)nextButtonClicked:(UIButton *)sender {
}

- (IBAction)toggleMovieRecording
{
    NSLog(@"Toggling movie recording");
    
    [[self recordButton] setEnabled:NO];
    
    dispatch_async([self sessionQueue], ^{
        if (![[self movieFileOutput] isRecording])
        {
            [self setLockInterfaceRotation:YES];
            
            if ([[UIDevice currentDevice] isMultitaskingSupported])
            {
                // Setup background task. This is needed because the captureOutput:didFinishRecordingToOutputFileAtURL: callback is not received until AVCam returns to the foreground unless you request background execution time. This also ensures that there will be time to write the file to the assets library when AVCam is backgrounded. To conclude this background execution, -endBackgroundTask is called in -recorder:recordingDidFinishToOutputFileURL:error: after the recorded file has been saved.
                [self setBackgroundRecordingID:[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil]];
            }
            
            // Update the orientation on the movie file output video connection before starting recording.
            [[[self movieFileOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation]];
            
            // Turning OFF flash for video recording
            [RCCameraViewController setFlashMode:AVCaptureFlashModeOff forDevice:[[self videoDeviceInput] device]];
            
            // Start recording to a temporary file.
            NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[@"movie" stringByAppendingPathExtension:@"mov"]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:outputFilePath]) {
                [[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:nil];
            }
            [[self movieFileOutput] startRecordingToOutputFileURL:[NSURL fileURLWithPath:outputFilePath] recordingDelegate:self];
        }
        else
        {
            [[self movieFileOutput] stopRecording];
        }
    });
    
}

- (IBAction)changeCamera:(id)sender
{
    [[self cameraButton] setEnabled:NO];
    [[self recordButton] setEnabled:NO];
    [[self stillButton] setEnabled:NO];
    
    dispatch_async([self sessionQueue], ^{
        AVCaptureDevice *currentVideoDevice = [[self videoDeviceInput] device];
        AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
        AVCaptureDevicePosition currentPosition = [currentVideoDevice position];
        
        switch (currentPosition)
        {
            case AVCaptureDevicePositionUnspecified:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
            case AVCaptureDevicePositionBack:
                preferredPosition = AVCaptureDevicePositionFront;
                break;
            case AVCaptureDevicePositionFront:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
        }
        
        AVCaptureDevice *videoDevice = [RCCameraViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
        
        [[self session] beginConfiguration];
        
        [[self session] removeInput:[self videoDeviceInput]];
        if ([[self session] canAddInput:videoDeviceInput])
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentVideoDevice];
            
            [RCCameraViewController setFlashMode:AVCaptureFlashModeAuto forDevice:videoDevice];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:videoDevice];
            
            [[self session] addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
        }
        else
        {
            [[self session] addInput:[self videoDeviceInput]];
        }
        
        [[self session] commitConfiguration];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self cameraButton] setEnabled:YES];
            [[self recordButton] setEnabled:YES];
            [[self stillButton] setEnabled:YES];
        });
    });
}

- (IBAction)backButtonClicked:(id)sender
{
    // Dismiss this view controller to go back to main application
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)snapStillImage:(id)sender
{
    dispatch_async([self sessionQueue], ^{
        // Update the orientation on the still image output video connection before capturing.
        [[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation]];
        
        // Flash set to Auto for Still Capture
        [RCCameraViewController setFlashMode:AVCaptureFlashModeAuto forDevice:[[self videoDeviceInput] device]];
        
        // Capture a still image.
        [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            
            if (imageDataSampleBuffer)
            {
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                UIImage *image = [[UIImage alloc] initWithData:imageData];
                [[[ALAssetsLibrary alloc] init] writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:nil];
            }
        }];
    });
}

- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint devicePoint = [(AVCaptureVideoPreviewLayer *)[[self previewView] layer] captureDevicePointOfInterestForPoint:[gestureRecognizer locationInView:[gestureRecognizer view]]];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
    
    
}

- (void)subjectAreaDidChange:(NSNotification *)notification
{
    CGPoint devicePoint = CGPointMake(.5, .5);
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

#pragma mark File Output Delegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    NSLog(@"Capturing Output");
    if (error)
        NSLog(@"%@", error);
    
    [self setLockInterfaceRotation:NO];
    self.videoURL = [self.movieFileOutput outputFileURL];
    
    // Note the backgroundRecordingID for use in the ALAssetsLibrary completion handler to end the background task associated with this recording. This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's -isRecording is back to NO — which happens sometime after this method returns.
    
//    UIBackgroundTaskIdentifier backgroundRecordingID = [self backgroundRecordingID];
//    [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
//
//    
//    [[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
//        if (error)
//            NSLog(@"%@", error);
//        
//        
//        [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
//        if (backgroundRecordingID != UIBackgroundTaskInvalid)
//            [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
//    }];
//    [self convertVideoToMp4];
    [self generateImage];
    [self performSegueWithIdentifier:@"PreviewVideoSegue" sender:self];


}

#pragma mark Device Configuration

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
    dispatch_async([self sessionQueue], ^{
        AVCaptureDevice *device = [[self videoDeviceInput] device];
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
            {
                [device setFocusMode:focusMode];
                [device setFocusPointOfInterest:point];
            }
            if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
            {
                [device setExposureMode:exposureMode];
                [device setExposurePointOfInterest:point];
            }
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        }
        else
        {
            NSLog(@"%@", error);
        }
    });
}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
    if ([device hasFlash] && [device isFlashModeSupported:flashMode])
    {
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            [device setFlashMode:flashMode];
            [device unlockForConfiguration];
        }
        else
        {
            NSLog(@"%@", error);
        }
    }
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = [devices firstObject];
    
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position)
        {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}

#pragma mark UI

- (void)runStillImageCaptureAnimation
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[self previewView] layer] setOpacity:0.0];
        [UIView animateWithDuration:.25 animations:^{
            [[[self previewView] layer] setOpacity:1.0];
        }];
    });
}

- (void)checkDeviceAuthorizationStatus
{
    NSString *mediaType = AVMediaTypeVideo;
    
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        if (granted)
        {
            //Granted access to mediaType
            [self setDeviceAuthorized:YES];
        }
        else
        {
            //Not granted access to mediaType
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"AVCam!"
                                            message:@"AVCam doesn't have permission to use Camera, please change privacy settings"
                                           delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
                [self setDeviceAuthorized:NO];
            });
        }
    }];
}

#pragma mark Thumbnail

-(void)generateImage
{
    AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:[self.movieFileOutput outputFileURL] options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform=TRUE;
    CMTime thumbTime = CMTimeMakeWithSeconds(0,30);
    
    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        if (result != AVAssetImageGeneratorSucceeded) {
            NSLog(@"couldn't generate thumbnail, error:%@", error);
        }
        NSLog(@"Generated thumbnail.");
        
//        [self.thumbnailImageView setImage:[UIImage imageWithCGImage:im]];
        
        NSData *thumbnailImageData=UIImageJPEGRepresentation([UIImage imageWithCGImage:im], 0.55);
        if ([[NSFileManager defaultManager] fileExistsAtPath:[self.thumbnailImageUrl absoluteString]]) {
            [[NSFileManager defaultManager] removeItemAtPath:[self.thumbnailImageUrl absoluteString] error:nil];
        }
        [thumbnailImageData writeToFile:[self.thumbnailImageUrl absoluteString] atomically:NO];
        // Wait for image to be generated before segueing to the next screen
    };
    
    CGSize maxSize = CGSizeMake(320, 320);
    generator.maximumSize = maxSize;
    [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
    
}

#pragma mark - Lazy Loading
-(NSString *)battleUsername
{
    if (! _battleUsername) {
        _battleUsername = [[NSString alloc] init];
    }
    return _battleUsername;
}

@end