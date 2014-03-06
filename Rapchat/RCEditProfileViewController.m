//
//  RCEditProfileViewController.m
//  Rapchat
//
//  Created by Michael Paris on 1/4/14.
//  Copyright (c) 2014 Michael Paris. All rights reserved.
//

#import "RCEditProfileViewController.h"
#import "RCUrlPaths.h"
#import <SVProgressHUD.h>
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

@interface RCEditProfileViewController ()
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (nonatomic) NSUInteger previousPhoneNumberLength;

@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic) UIImage *profilePicture;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (nonatomic) UIView *viewForPicker;
@property (nonatomic) NSArray *pickerViewArray;

@end

@implementation RCEditProfileViewController
{
    int selectedPickerIndex;
    BOOL needsImageUpdate;
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
    self.pickerViewArray = @[@"Choose Photo From Library", @"Take New Photo"];
    needsImageUpdate = NO;
    [self.phoneTextField addTarget:self action:@selector(phoneNumberChanged) forControlEvents:UIControlEventEditingChanged];
    self.title = @"Edit Profile";
    
    self.profilePictureImageView.layer.cornerRadius = 5.0;
    self.profilePictureImageView.layer.masksToBounds = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshUI];
    self.previousPhoneNumberLength = [self.phoneTextField.text length];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshUI
{
    [self.firstNameTextField setText:self.profile.user.firstName];
    [self.lastNameTextField setText:self.profile.user.lastName];
    [self.emailTextField setText:self.profile.user.email];
    [self.phoneTextField setText:self.profile.phoneNumber];
    if (self.profile.profilePictureURL) {
        [self.profilePictureImageView setImageWithURL:self.profile.profilePictureURL
                          usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
}

#pragma mark Seques
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Logout Segue"]) {
        NSLog(@"Preparing for logout");
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"accessToken"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark Actions

- (IBAction)goBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)updateProfile:(UIButton *)sender {
    [self.view endEditing:YES];
    if (needsImageUpdate && [self validateInfo]) {
        [self updateProfileWithNewImage];
    } else if ([self validateInfo]) {
        [self updateProfileNoImage];
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

#pragma mark API Calls
- (void)updateProfileWithNewImage
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [SVProgressHUD showWithStatus:@"Updating Profile" maskType:SVProgressHUDMaskTypeBlack];
    
    NSMutableURLRequest *request = [objectManager multipartFormRequestWithObject:nil
                                                                          method:RKRequestMethodPUT
                                                                            path:myProfileEndpoint
                                                                      parameters:@{@"first_name": self.firstNameTextField.text,
                                                                                   @"last_name": self.lastNameTextField.text,
                                                                                   @"email": self.emailTextField.text,
                                                                                   @"phone_number": self.phoneTextField.text}
                                                       constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                           [formData appendPartWithFileData:UIImageJPEGRepresentation(self.profilePicture, .5)
                                                                                       name:@"profile_picture"
                                                                                   fileName:@"profile_picture.jpg"
                                                                                   mimeType:@"image/jpg"];
                                                       }];
    RKObjectRequestOperation *operation = [objectManager objectRequestOperationWithRequest:request
                                                                                   success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                                                       self.profile = [mappingResult firstObject];
                                                                                       [SVProgressHUD showSuccessWithStatus:@"Updated!"];
                                                                                       [self.navigationController popViewControllerAnimated:YES];
                                                                                   }
                                                                                   failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                                                       [SVProgressHUD showErrorWithStatus:@"Network Failure"];
                                                                                   }];
    [operation start];
}

- (void)updateProfileNoImage
{
    [self.view endEditing:YES];
    if ([self validateInfo]) {
        RKObjectManager *objectManager = [RKObjectManager sharedManager];
        [SVProgressHUD showWithStatus:@"Updating" maskType:SVProgressHUDMaskTypeGradient];
        [objectManager putObject:nil
                            path:myProfileEndpoint
                      parameters:@{@"first_name": self.firstNameTextField.text,
                                   @"last_name": self.lastNameTextField.text,
                                   @"email": self.emailTextField.text,
                                   @"phone_number": self.phoneTextField.text}
                         success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                             self.profile = [mappingResult firstObject];
                             [SVProgressHUD showSuccessWithStatus:@"Success"];
                             [self.navigationController popViewControllerAnimated:YES];
                         } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                             [self refreshUI];
                             [SVProgressHUD showErrorWithStatus:@"Failed"];
                         }];
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
        [self.profilePictureImageView setImage:self.profilePicture];
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
//    [self dismissViewControllerAnimated:YES completion:nil];
    [UIView animateWithDuration:.3 animations:^{
        self.viewForPicker.frame = CGRectMake(0, self.view.frame.size.height, 320, 206);
    } completion:^(BOOL finished) {
        [self.viewForPicker removeFromSuperview];
        self.viewForPicker = nil;
        self.imagePickerController = nil;
    }];
}

# pragma mark validation
- (void)phoneNumberChanged
{
    NSLog(@"Phone Number Changed");
    // Append a - to the number when it is 3 or 7 characters long
    if ( ([self.phoneTextField.text length] == 3 || [self.phoneTextField.text length] == 7) &&  [self.phoneTextField.text length] > self.previousPhoneNumberLength) {
        [self.phoneTextField setText:[self.phoneTextField.text stringByAppendingString:@"-"]];
    }
    self.previousPhoneNumberLength = [self.phoneTextField.text length];
}

- (BOOL)validateInfo
{
    if ([self.phoneTextField.text length]) {
        NSError *error = NULL;
        NSRegularExpression *phoneRegEx = [[NSRegularExpression alloc] initWithPattern:@"^\\d{3}-\\d{3}-\\d{4}$"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        NSString *string = self.phoneTextField.text;
        if (![phoneRegEx numberOfMatchesInString:string options:0 range:NSMakeRange(0, [string length])] == 1) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Phone Number"
                                                            message:@"Should be of form xxx-xxx-xxxx"
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
            [alert show];
            return NO;
        }
    }
    return YES;
}

@end
