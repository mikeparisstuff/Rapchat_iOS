//
//  RCRegisterScreenViewController.m
//  Rapchat
//
//  Created by Michael Paris on 12/13/13.
//  Copyright (c) 2013 Michael Paris. All rights reserved.
//

#import "RCRegisterScreenViewController.h"
#import "RCProfile.h"

#import "RCUrlPaths.h"

#define kOFFSET_FOR_KEYBOARD 50.0

@interface RCRegisterScreenViewController ()
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield2;

@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic) UIImage *profilePicture;
@property (nonatomic) UIView *viewForPicker;
@property (nonatomic) NSArray *pickerViewArray;
@property (weak, nonatomic) IBOutlet UIButton *profilePictureButton;

@end

@implementation RCRegisterScreenViewController
{
    int selectedPickerIndex;
    BOOL needsImageUpdate;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SegueToHomeFromRegisterScreen"]) {
        NSLog(@"Preparing for segue");
        self.navigationController.navigationBarHidden = YES;
        
    }
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
    
    // Make Done button appear when on password2 box
    [self.passwordTextfield2 setReturnKeyType:UIReturnKeyDone];
    [self.passwordTextfield2 addTarget:self
                               action:@selector(registerButtonClicked)
                     forControlEvents:UIControlEventEditingDidEndOnExit];
    
    needsImageUpdate = NO;
    self.pickerViewArray = @[@"Choose Photo From Library", @"Take New Photo"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark API Calls
- (void)registerProfile
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager.HTTPClient setDefaultHeader:@"Authorization" value:nil];
    [objectManager postObject:nil
                         path:usersEndpoint
                   parameters:@{@"username":self.usernameTextfield.text,
                                @"password":self.passwordTextfield.text,
                                @"first_name":self.firstNameTextField.text,
                                @"last_name":self.lastNameTextField.text,
                                @"email":self.emailTextfield.text
                                }
                      success:^(RKObjectRequestOperation *operation, RKMappingResult* mappingResult) {
                          RCProfile *registerProfile = [mappingResult firstObject];
                          if(registerProfile.accessToken) {
                              [[NSUserDefaults standardUserDefaults] setObject:registerProfile.accessToken forKey:@"accessToken"];
                              [objectManager.HTTPClient setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Token %@", registerProfile.accessToken]];
                              [[NSUserDefaults standardUserDefaults] synchronize];
                              [self performSegueWithIdentifier:@"SegueToHomeFromRegisterScreen" sender:self];
                          }else {
                              NSLog(@"Error Registering Profile");
                          }
                      }failure:^(RKObjectRequestOperation *operation, NSError *error) {
                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error"
                                                                          message:[error localizedDescription]
                                                                         delegate:nil
                                                                cancelButtonTitle:@"OK"
                                                                otherButtonTitles:nil, nil];
                          [alert show];
                          NSLog(@"Hit error: %@", error);
                      }];
}

- (void)registerProfileWithNewImage
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager.HTTPClient setDefaultHeader:@"Authorization" value:nil];
    NSMutableURLRequest *request = [objectManager multipartFormRequestWithObject:nil
                                                                          method:RKRequestMethodPOST
                                                                            path:usersEndpoint
                                                                      parameters:@{@"username":self.usernameTextfield.text,
                                                                                   @"password":self.passwordTextfield.text,
                                                                                   @"first_name":self.firstNameTextField.text,
                                                                                   @"last_name":self.lastNameTextField.text,
                                                                                   @"email":self.emailTextfield.text
                                                                                   }
                                                       constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                           [formData appendPartWithFileData:UIImageJPEGRepresentation(self.profilePicture, .5)
                                                                                       name:@"profile_picture"
                                                                                   fileName:@"profile_picture.jpg"
                                                                                   mimeType:@"image/jpg"];
                                                       }];
    RKObjectRequestOperation *operation = [objectManager objectRequestOperationWithRequest:request
                                                                                   success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                                                       RCProfile *registerProfile = [mappingResult firstObject];
                                                                                       if(registerProfile.accessToken) {
                                                                                           [[NSUserDefaults standardUserDefaults] setObject:registerProfile.accessToken forKey:@"accessToken"];
                                                                                           [objectManager.HTTPClient setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Token %@", registerProfile.accessToken]];
                                                                                           [[NSUserDefaults standardUserDefaults] synchronize];
                                                                                           [self performSegueWithIdentifier:@"SegueToHomeFromRegisterScreen" sender:self];
                                                                                       }else {
                                                                                           NSLog(@"Error Registering Profile");
                                                                                       }
                                                                                   }
                                                                                   failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                                                       NSLog(@"Error registering user: %@", error);
                                                                                   }];
    [operation start];
}

#pragma mark UIKeyboard methods

-(void)keyboardWillShow {
    NSLog(@"Keyboard will show");
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)keyboardWillHide {
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

- (IBAction)textFieldDidBeginEditing:(UITextField *)sender {
    //move the main view, so that the keyboard does not hide it.
    
    if  (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
}
- (IBAction)textFieldShouldReturn:(UITextField *)sender {
    [self keyboardWillHide];
    [self.view endEditing:YES];
}


//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
//        tableViewRect.origin.y += kOFFSET_FOR_KEYBOARD;
//        tableViewRect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
//        tableViewRect.origin.y -= kOFFSET_FOR_KEYBOARD;
//        tableViewRect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

#pragma mark Swipe Gestures
-(void)handleSwipe:(UISwipeGestureRecognizer *)recognizer
{
    NSLog(@"Swipe down recognized");
    [self.view endEditing:YES];
}

#pragma mark Actions

- (IBAction)registerButtonClicked {
    if ([self.passwordTextfield.text isEqualToString:self.passwordTextfield2.text]) {

        [self.view endEditing:YES];
        if (needsImageUpdate) {
            [self registerProfileWithNewImage];
        } else {
            [self registerProfile];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password Error"
                                                        message:@"The passwords you entered do not match."
                                                       delegate:nil
                                              cancelButtonTitle:@"Try Again"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (IBAction)beginUpdatingProfilePicture:(UIButton *)sender {
    self.viewForPicker = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, 320, 206)];
    
    UIPickerView *typeOfCameraPickerView = [[UIPickerView alloc] init];
    typeOfCameraPickerView.frame = CGRectMake(0, 44, 320, 162);
    typeOfCameraPickerView.dataSource = self;
    typeOfCameraPickerView.delegate = self;
    typeOfCameraPickerView.showsSelectionIndicator = YES;
    [typeOfCameraPickerView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:typeOfCameraPickerView];
    
    UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,320,44)];
    [pickerToolbar setBarStyle:UIBarStyleBlackTranslucent];
    //    self.chooseButton = [[UIBarButtonItem alloc] initWithTitle:@"Choose" style:UIBarButtonItemStyleBordered target:self action:@selector(goToImagePicker)];
    UIBarButtonItem *chooseButton = [[UIBarButtonItem alloc] initWithTitle:@"Choose" style:UIBarButtonItemStyleBordered target:self action:@selector(goToImagePicker)];
    UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(imagePickerControllerDidCancel:)];
    pickerToolbar.items = @[chooseButton, dismissButton];
    [pickerToolbar setTintColor:[UIColor whiteColor]];
    [self.viewForPicker addSubview:typeOfCameraPickerView];
    [self.viewForPicker addSubview:pickerToolbar];
    [self.view addSubview:self.viewForPicker];
    [UIView animateWithDuration:.3 animations:^{
        self.viewForPicker.frame = CGRectMake(0, self.view.frame.size.height - 206, 320, 206);
    }];
    selectedPickerIndex = (int)[typeOfCameraPickerView selectedRowInComponent:0];
}

- (void) goToImagePicker
{
    NSLog(@"Goto Image Picker");
    switch (selectedPickerIndex) {
        case 0:
            [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
        case 1:
            [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
            break;
        default:
            break;
    }
}

#pragma mark PickerViewDatasource and Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.pickerViewArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (row) {
        case 0:
            selectedPickerIndex = 0;
            //            [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
        case 1:
            selectedPickerIndex = 1;
            //            [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
            break;
        default:
            break;
    }
}

#pragma mark UIImagePickerControllerDelegate
- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)finishAndUpdate
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.profilePicture) {
        [self.profilePictureButton setImage:self.profilePicture forState:UIControlStateNormal];
    }
    [UIView animateWithDuration:.3 animations:^{
        self.viewForPicker.frame = CGRectMake(0, self.view.frame.size.height, 320, 206);
    }];
    needsImageUpdate = YES;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
    self.profilePicture = image;
    [self finishAndUpdate];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [UIView animateWithDuration:.3 animations:^{
        self.viewForPicker.frame = CGRectMake(0, self.view.frame.size.height, 320, 206);
    } completion:^(BOOL finished) {
        [self.viewForPicker removeFromSuperview];
        self.viewForPicker = nil;
        self.imagePickerController = nil;
    }];
}



@end
