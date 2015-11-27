//
//  RegisterViewController.m
//  ActorsCam
//
//  Created by Hema on 17/08/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "RegisterViewController.h"
#import "UITextField+Padding.h"
#import "UITextField+Validations.h"
#import "BSKeyboardControls.h"
#import "WebService.h"


@interface RegisterViewController ()<BSKeyboardControlsDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverControllerDelegate>
{
    NSArray *textFieldArray;
    NSString *takePhoto, *choosePhoto, *cancel, *navTitle;
}
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassword;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

//iPad
@property (weak, nonatomic) IBOutlet UITextField *ipad_name;
@property (weak, nonatomic) IBOutlet UITextField *ipad_email;
@property (weak, nonatomic) IBOutlet UITextField *ipad_password;
@property (weak, nonatomic) IBOutlet UIButton *ipad_registerBtn;
@property (weak, nonatomic) IBOutlet UITextField *ipad_confirmPassword;
@property (weak, nonatomic) IBOutlet UIImageView *ipad_profileImageView;

@property (nonatomic, strong) UIPopoverController *popover;
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation RegisterViewController
@synthesize name,email,password,scrollView,confirmPassword,profileImageView,registerBtn;
@synthesize popover;

@synthesize ipad_name,ipad_email,ipad_password,ipad_confirmPassword,ipad_profileImageView,ipad_registerBtn;


#pragma mark - View life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (iPad) {
        
        name = ipad_name;
        email = ipad_email;
        password = ipad_password;
        confirmPassword = ipad_confirmPassword;
        registerBtn = ipad_registerBtn;
        ipad_profileImageView.frame = CGRectMake(ipad_profileImageView.frame.origin.x, ipad_profileImageView.frame.origin.y, 200, 200);
        profileImageView = ipad_profileImageView;
        
    }
    
    profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2;
    profileImageView.clipsToBounds= YES;
    
    takePhoto = @"Take Photo";
    choosePhoto = @"Choose Existing Photo";
    cancel = @"Cancel";
    navTitle = @"Sign Up";
    
    [self addTextFieldPadding];
    
    //Adding textfield to array
    textFieldArray = @[name,email,password,confirmPassword];
    //Keyboard toolbar action to display toolbar with keyboard to move next,previous
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFieldArray]];
    [self.keyboardControls setDelegate:self];
    
    [self setLocalizedString];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = navTitle;
    if([[UIScreen mainScreen] bounds].size.height > 570)
    {
        scrollView.scrollEnabled=NO;
    }
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addTextFieldPadding
{
    [name addTextFieldPadding:name color:[UIColor lightGrayColor]];
    [email addTextFieldPadding:email color:[UIColor lightGrayColor]];
    [password addTextFieldPadding:password color:[UIColor lightGrayColor]];
    [confirmPassword addTextFieldPadding:confirmPassword color:[UIColor lightGrayColor]];
}

-(void)setLocalizedString{
    
    [name changeTextLanguage:@"Name"];
    [email changeTextLanguage:@"Email address"];
    [password changeTextLanguage:@"Password"];
    [confirmPassword changeTextLanguage:@"Confirm password"];
    takePhoto = [takePhoto changeTextLanguage:takePhoto];
    choosePhoto = [choosePhoto changeTextLanguage:choosePhoto];
    cancel = [cancel changeTextLanguage:cancel];
    [registerBtn changeTextLanguage:@"SIGN UP"];
    navTitle = [navTitle changeTextLanguage:@"Sign Up"];
}
#pragma mark - end

#pragma mark - View IB actions
- (IBAction)signUpButtonAction:(id)sender
{
    
    [self.keyboardControls.activeField resignFirstResponder];
    if([self performValidationsForSignUp])
    {
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        [myDelegate ShowIndicator];
        [self performSelector:@selector(signUpUser) withObject:nil afterDelay:.1];
    }

}

-(void)signUpUser
{
    
    [[WebService sharedManager] registerUser:email.text password:password.text name:name.text image:profileImageView.image  success:^(id responseObject) {
        
        [myDelegate StopIndicator];
        NSDictionary *dict = (NSDictionary *)responseObject;
        NSString *msg = [dict objectForKey:@"message"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[@"Success" changeTextLanguage:@"Success"] message:[msg changeTextLanguage:@"Thank you for registering on Actor CAM!"] delegate:self cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"] otherButtonTitles:nil, nil];
        alert.tag = 1;
        [alert show];
        
    } failure:^(NSError *error) {
        
    }] ;
    
}

- (IBAction)imagePickerAction:(id)sender
{
    
    UIActionSheet * profileImageAction=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:cancel destructiveButtonTitle:nil otherButtonTitles:takePhoto, choosePhoto, nil];
    
    if ([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
        
        [profileImageAction showFromRect:CGRectMake(profileImageView.frame.origin.x-60, profileImageView.frame.origin.y + 82, 320, 120) inView:self.view animated:YES];
    }
    else{
        // In this case the device is an iPhone/iPod Touch.
        [profileImageAction showInView:[UIApplication sharedApplication].keyWindow];
    }
    
}

#pragma mark - end

#pragma mark - UIAlertView delegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark - end

#pragma mark - Image picker

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)info
{
    profileImageView.image = image;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
}
#pragma mark - end

#pragma mark - Actionsheet
//Action sheet for setting image from camera or gallery
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != 2) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.navigationBar.tintColor = [UIColor whiteColor];
            [imagePickerController setAllowsEditing:YES];
            if (buttonIndex==1) {
                imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
            else{
                imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            }
            imagePickerController.delegate = (id)self;
            
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
            [self presentViewController:imagePickerController animated:YES completion:nil];
            
        }
        
        else  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            UIImagePickerController *pickerImg = [[UIImagePickerController alloc] init];
            if (buttonIndex==1) {
                pickerImg.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                pickerImg.delegate = (id)self;
                pickerImg.navigationBar.tintColor = [UIColor whiteColor];
                pickerImg.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
                popover = [[UIPopoverController alloc] initWithContentViewController:pickerImg];
                popover.delegate = self;
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    // Place image picker on the screen
                    [self.popover presentPopoverFromRect:CGRectMake(50,-430, 668, 668) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:NO]; [self.popover setPopoverContentSize:CGSizeMake(668,668)];
                }];
                
            }
            else {
                if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])  {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[@"Error" changeTextLanguage:@"Error"] message:[@"Device has no camera." changeTextLanguage:@"Device has no camera."] delegate:self cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"] otherButtonTitles:nil];
                    [alert show];
                }
                else{
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        // Place image picker on the screen
                        pickerImg.delegate = self;
                        pickerImg.sourceType=UIImagePickerControllerSourceTypeCamera;
                        [self presentViewController:pickerImg animated:YES completion:NULL];
                    }];
                }
            }
        }
    }
}
#pragma mark - end

#pragma mark - Email validation
- (BOOL)performValidationsForSignUp
{
    UIAlertView *alert;
    
    UIImage* placeholderImage = [UIImage imageNamed:@"PlaceholderImage"];
    NSData *placeholderImageData = UIImagePNGRepresentation(placeholderImage);
    NSData *profileImageData = UIImagePNGRepresentation(profileImageView.image);
    
    if ([profileImageData isEqualToData:placeholderImageData])
    {
        
        alert = [[UIAlertView alloc]initWithTitle:[@"Alert" changeTextLanguage:@"Alert"] message:[@"Please upload an image." changeTextLanguage:@"Please upload an image."] delegate:self cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"] otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else if ([name isEmpty] || (name.text.length == 0) || [name.text isEqualToString:@""]){
        alert = [[UIAlertView alloc]initWithTitle:[@"Alert" changeTextLanguage:@"Alert"] message:[@"Name cannot be blank." changeTextLanguage:@"Name cannot be blank."] delegate:self cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"] otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else if ([email isEmpty] || (email.text.length == 0) || [email.text isEqualToString:@""]){
        alert = [[UIAlertView alloc]initWithTitle:[@"Alert" changeTextLanguage:@"Alert"] message:[@"Email address cannot be blank." changeTextLanguage:@"Email address cannot be blank."] delegate:self cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"] otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else if (![email isValidEmail])
    {
        alert = [[UIAlertView alloc]initWithTitle:[@"Alert" changeTextLanguage:@"Alert"] message:[@"Invalid email address." changeTextLanguage:@"Invalid email address."] delegate:nil cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"] otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    
    }
    else if ([password isEmpty] || (password.text.length == 0) || [password.text isEqualToString:@""]){
        alert = [[UIAlertView alloc]initWithTitle:[@"Alert" changeTextLanguage:@"Alert"] message:[@"Password cannot be blank." changeTextLanguage:@"Password cannot be blank."] delegate:self cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"] otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else if (password.text.length < 8)
    {
        
        alert = [[UIAlertView alloc]initWithTitle:[@"Alert" changeTextLanguage:@"Alert"] message:[@"Your password must be atleast 8 characters long." changeTextLanguage:@"Your password must be atleast 8 characters long."] delegate:self cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"] otherButtonTitles:nil, nil];
        [alert show];
        return NO;
        
    }
    else if ([confirmPassword isEmpty] || (confirmPassword.text.length == 0) || [confirmPassword.text isEqualToString:@""]){
        alert = [[UIAlertView alloc]initWithTitle:[@"Alert" changeTextLanguage:@"Alert"] message:[@"Confirm password cannot be blank." changeTextLanguage:@"Confirm password cannot be blank."] delegate:self cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"] otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else if (![password.text isEqualToString:confirmPassword.text])
    {
        
        alert = [[UIAlertView alloc]initWithTitle:[@"Alert" changeTextLanguage:@"Alert"] message:[@"Passwords do not match." changeTextLanguage:@"Passwords do not match."] delegate:self cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"] otherButtonTitles:nil, nil];
        [alert show];
        return NO;
        
    }
    else{
        return YES;
    }
    
}
#pragma mark - end

#pragma mark - Keyboard controls delegate
- (void)keyboardControls:(BSKeyboardControls *)keyboardControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction
{
    UIView *view;
    
    if ([[UIDevice currentDevice].systemVersion floatValue]< 7.0) {
        view = field.superview.superview;
    } else {
        view = field.superview.superview.superview;
    }
}

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControls
{
    
    [keyboardControls.activeField resignFirstResponder];
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
}
#pragma mark - end

#pragma mark - Textfield delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    [self.keyboardControls setActiveField:textField];
    
    if (!iPad) {
        [scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y - 80) animated:YES];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == name) {
        
        if (textField.text.length >= MAX_LENGTH && range.length == 0)
        {
            return NO; // return NO to not change text
        }
        else
        {
            return YES;
        }
    }
    else{
        return YES;
    }
}


-(void)textFieldDidEndEditing:(UITextField *)textField {
    
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - end
@end
