//
//  RCAudioRecorderViewController.m
//  Rapchat
//
//  Created by Michael Paris on 6/18/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCAudioRecorderViewController.h"
#import "RCUrlPaths.h"
#import "SVProgressHud.h"
#import "RCWaveFormView.h"
#import "RCDataManager.h"


@interface RCAudioRecorderViewController ()
@property (strong, nonatomic) RCAudioRecorderAndPlayer *audioRecPlayer;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *checkButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *toolbarTitleLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *toolbarPlayPauseButton;

@property (weak, nonatomic) IBOutlet RCWaveFormView *waveformView;
@property (strong, nonatomic) NSURL *mixedRapUrl;
@property (strong, nonatomic) RCBeat *currentBeat;

@property (nonatomic, strong) EZAudioFile *audioFile;
@property (weak, nonatomic) IBOutlet EZAudioPlot *audioPlot;



@end

@implementation RCAudioRecorderViewController

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
    
    [self setupRecorder];
    [self setupWaveform];
    self.audioRecPlayer.delegate = self;
    self.audioRecPlayer.recorderDelegate = self;
    self.audioRecPlayer.playerDelegate = self;
    
    // Setup left Go back button
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_back"] style:UIBarButtonItemStyleDone target:self action:@selector(backButtonPressed)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"grey_washed"]]];
    [self.waveformView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"grey_washed"]]];
    [self disableButtons];
    self.currentBeat = [[RCBeat alloc] initWithResourceName:@"simple_beat6" AndTitle:@"Big Black Beat"];
    [self setupToolbar];
}

- (void) backButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) setupToolbar
{
//    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toolbarSongTapped:)];
//    [self.toolbar addGestureRecognizer:recognizer];
    self.toolbarTitleLabel.title = self.currentBeat.title;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) disableButtons
{
    [self.playButton setEnabled:NO];
    [self.cancelButton setEnabled:NO];
    [self.checkButton setEnabled:NO];
}

- (void) enableButtons
{
    [self.playButton setEnabled:YES];
    [self.cancelButton setEnabled:YES];
    [self.checkButton setEnabled:YES];
}

#pragma mark - Toolbar
- (IBAction)toolbarSongTapped:(id)sender
{
    [self performSegueWithIdentifier:@"GotoChooseSongSegue" sender:nil];
}

- (IBAction)toolbarPlayPauseTapped:(id)sender {
    NSLog(@"toolbarPlayPauseTapped");
    if ([self.audioRecPlayer isPlaying]) {
        [self.audioRecPlayer pausePlayer];
        [self.toolbarPlayPauseButton setImage:[UIImage imageNamed:@"ic_play_circ"]];
    }
    else
    {
        [self.audioRecPlayer startPlayerWithUrl:self.currentBeat.url];
        [self.toolbarPlayPauseButton setImage:[UIImage imageNamed:@"ic_pause_circ"]];
    }
}


#pragma mark - Waveform
- (void) setupWaveform
{
//    self.waveformView.antialiasingEnabled = NO;
//    self.waveformView.normalColor = [UIColor colorWithRed:51.0/255.0 green:151.0/255.0 blue:162.0/255.0 alpha:1.0];
//    self.waveformView.progressColor = [UIColor colorWithRed:231.0/255.0 green:76.0/255.0 blue:60.0/255.0 alpha:1.0];
    
    // Background color (use UIColor for iOS)
    self.audioPlot.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"grey_washed"]];
    // Waveform color (use UIColor for iOS)
    self.audioPlot.color = [UIColor whiteColor];
    self.audioPlot.gain = 3.0;
    // Plot type
    self.audioPlot.plotType     = EZPlotTypeBuffer;
    // Fill
    self.audioPlot.shouldFill   = YES;
    // Mirror
    self.audioPlot.shouldMirror = YES;
}

- (void) setWaveformUrl:(NSURL *)url
{
    self.audioFile = [EZAudioFile audioFileWithURL:url
                                       andDelegate:self];
    self.audioFile.waveformResolution = 512;
    // Get the waveform data from the audio file asynchronously
    [self.audioFile getWaveformDataWithCompletionBlock:^(float *waveformData, UInt32 length) {
        // Update the audio plot with the waveform data (use the EZPlotTypeBuffer in this case)
        [self.audioPlot updateBuffer:waveformData withBufferSize:length];
    }];
//    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
//    self.waveformView.asset = asset;
//    self.waveformView.progress = .4;
//    [self.waveformView generateWaveforms];
}


#pragma mark - Audio Functions

- (void)setupRecorder
{
    // Disable Stop/Play button when application launches
//    [self.stopButton setEnabled:NO];
//    [self.playButton setEnabled:NO];
    
    // Set the output audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"MyAudioMemo.m4a",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputFileURL.path]) {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:&error];
        if (error) {
            NSLog(@"Error removing item at path: %@", error);
        }
    }
    
    self.audioRecPlayer = [[RCAudioRecorderAndPlayer alloc] initWithOutputUrl:outputFileURL];
}

- (void)play
{
    if ((![self.audioRecPlayer isPlaying]) && self.mixedRapUrl) {
        NSLog(@"Should be playing");
        [self.audioRecPlayer startPlayerWithUrl:self.mixedRapUrl];
        [self.playButton setImage:[UIImage imageNamed:@"recorder_pause_button"] forState:UIControlStateNormal];
//        [self.playButton setTitle:@"Stop" forState:UIControlStateNormal];
    } else if ([self.audioRecPlayer isPlaying]) {
        [self.audioRecPlayer stopPlayer];
//        [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
        [self.playButton setImage:[UIImage imageNamed:@"recorder_play_button"] forState:UIControlStateNormal];
    }
}

#pragma mark - API Calls

- (void)submitRap
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSDictionary *params = @{@"title": @"A rap yo",@"is_private": @NO};
    [SVProgressHUD showWithStatus:@"Creating Session" maskType:SVProgressHUDMaskTypeGradient];
    NSMutableURLRequest *request = [objectManager multipartFormRequestWithObject:nil
                                                                          method:RKRequestMethodPOST
                                                                            path:mySessionsEndpoint
                                                                      parameters:params
                                                       constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                           [formData appendPartWithFileData:[NSData dataWithContentsOfURL:self.mixedRapUrl]
                                                                                       name:@"clip"
                                                                                   fileName:@"movie.mp4"
                                                                                   mimeType:@"video/mp4"];
                                                           //                                                           NSLog(@"Submitting thumbnail: %@", self.thumbnailImageUrl);
                                                           [formData appendPartWithFileData:UIImageJPEGRepresentation(self.waveformView.generatedNormalImage, .9)
                                                                                       name:@"waveform"
                                                                                   fileName:@"waveform.jpeg"
                                                                                   mimeType:@"image/jpg"];
                                                           //                                                            NSLog(@"Form Data: %@", formData);
                                                       }];
    RKObjectRequestOperation *operation = [objectManager objectRequestOperationWithRequest:request
                                                                                   success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                                                       [SVProgressHUD showSuccessWithStatus:@"Success"];
                                                                                       
                                                                                       [self dismissViewControllerAnimated:YES completion:nil];
                                                                                   }
                                                                                   failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                                                       [SVProgressHUD showErrorWithStatus:@"Error"];
                                                                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                                                       message:@"Sorry there was a problem uploading the clip. Please try again"
                                                                                                                                      delegate:nil
                                                                                                                             cancelButtonTitle:@"OK"
                                                                                                                             otherButtonTitles:nil, nil];
                                                                                       [alert show];
                                                                                   }];
    [operation start];
}


#pragma mark - Button Actions
- (IBAction)stopTapped:(id)sender {
    [self.audioRecPlayer stopRecorder];
    [self.audioRecPlayer stopPlayer];
}

- (IBAction)playTapped:(id)sender {
    if (self.mixedRapUrl != nil) {
        [self play];
        return;
    }
}

- (IBAction)cancelTapped:(id)sender {
    [self disableButtons];
}

- (IBAction)recordPauseTapped:(id)sender {
    
    // Stop the audio player before recording
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *filePath = [mainBundle pathForResource:@"flipwhip" ofType:@"mp3"];
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
//    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
//    NSURL *url = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"beatbox100bpm" ofType:@"mp3"]];
    
    if (![self.audioRecPlayer isRecorderRecording]) {
        [self.audioRecPlayer startPlayerWithUrl:fileUrl];
        [self.recordButton setImage:[UIImage imageNamed:@"record_button_pause"] forState:UIControlStateNormal];
        [self.audioRecPlayer startRecorder];
    } else {
        [self.audioRecPlayer stopPlayer];
        [self.audioRecPlayer stopRecorder];
        [self enableButtons];
        [self.recordButton setImage:[UIImage imageNamed:@"record_button"] forState:UIControlStateNormal];
    }
//    [self.stopButton setEnabled:YES];
//    [self.playButton setEnabled:YES];
}

- (IBAction)submitButtonTapped:(id)sender {
    [self submitRap];
}


#pragma mark - AVAudioRecorderDelegate
- (void)recorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag
{
    [self.audioRecPlayer superImposeAudioTracks];
}
- (void)playerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self.playButton setImage:[UIImage imageNamed:@"recorder_play_button"] forState:UIControlStateNormal];
}

#pragma mark - AVAudioRecorderAndPlayerDelegate

- (void) audioFilesWereSuccessfullyMixedAtURL:(NSURL *)url
{
    self.mixedRapUrl = url;
    [self setWaveformUrl:url];
    NSLog(@"audioFilesWereSuccessfullyMixedAtURL");
}

#pragma mark - RCChooseSongTableViewDelegate
- (void) selectionDidFinishWithSong:(RCBeat *)beat
{
    self.currentBeat = beat;
    self.toolbarTitleLabel.title = beat.title;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"GotoChooseSongSegue"]) {
        RCChooseSongTableViewController *cont = [segue destinationViewController];
        cont.delegate = self;
    }

    
}


@end
