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
    UIImagePickerController *imgPicker;
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
    profileImageView.layer.masksToBounds = YES;
    
    takePhoto = @"Take Photo";
    choosePhoto = @"Choose Existing Photo";
    cancel = @"Cancel";
    navTitle = @"Sign Up";
    
    [self addTextFieldPadding];
  
    imgPicker = [[UIImagePickerController alloc] init];
    
    //Adding textfield to array
    textFieldArray = @[name,email,password,confirmPassword];
    //Keyboard toolbar action to display toolbar with keyboard to move next,previous
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFieldArray]];
    [self.keyboardControls setDelegate:self];
    
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

-(void)setLocalizedString{
    
    [name changeTextLanguage:@"Name"];
    [email changeTextLanguage:@"Email"];
    [password changeTextLanguage:@"Password"];
    [confirmPassword changeTextLanguage:@"Confirm Password"];
    [takePhoto changeTextLanguage:takePhoto];
    [choosePhoto changeTextLanguage:choosePhoto];
    [cancel changeTextLanguage:cancel];
    [registerBtn changeTextLanguage:@"SIGN UP"];
    [navTitle changeTextLanguage:@"Sign Up"];
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

#pragma mark - end

#pragma mark - Register User
- (IBAction)signUpButtonAction:(id)sender
{
//    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:[dict objectForKey:@"message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        alert.tag = 1;
        [alert show];
        
    } failure:^(NSError *error) {
        
    }] ;
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark - end

#pragma mark - Image Picker
- (IBAction)imagePickerAction:(id)sender
{
    
    UIActionSheet * profileImageAction=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:cancel destructiveButtonTitle:nil otherButtonTitles:takePhoto, choosePhoto, nil];
    
    if ([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
        
            [profileImageAction showFromRect:CGRectMake(profileImageView.frame.origin.x, profileImageView.frame.origin.y + 75, 320, 120) inView:self.view animated:YES];
      }
    else{
        // In this case the device is an iPhone/iPod Touch.
         [profileImageAction showInView:[UIApplication sharedApplication].keyWindow];
    }

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)info
{
    profileImageView.image = image;
    [imgPicker dismissViewControllerAnimated:YES completion:NULL];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
}
#pragma mark - end

#pragma mark - Actionsheet
//Action sheet for setting image from camera or gallery
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==0)
    {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                  message:@"Device has no camera."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil];
            
            [myAlertView show];
            
        }
        else
        {
        //Setting image from camera
        [imgPicker setAllowsEditing:YES];
        imgPicker = [[UIImagePickerController alloc] init];
        imgPicker.delegate = self;
        imgPicker.allowsEditing = YES;
        imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
        [self presentViewController:imgPicker animated:YES completion:nil];
        }
    }
    else if(buttonIndex==1)
    {
        //Setting image from gallery
        imgPicker.delegate = self;
        imgPicker.allowsEditing = YES;
        imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imgPicker.navigationBar.tintColor = [UIColor whiteColor];
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            
            self.popover = [[UIPopoverController alloc] initWithContentViewController:imgPicker];
            self.popover.delegate = self;
            
            [self.popover presentPopoverFromRect:CGRectMake(100, 100, 311, 350) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            [self.popover setPopoverContentSize:CGSizeMake(330, 515)];

        }
        else
        {
             [self presentViewController:imgPicker animated:YES completion:nil];
        }
       
    }
    
}
#pragma mark - end

#pragma mark - Textfield Validation
- (BOOL)performValidationsForSignUp
{
    UIAlertView *alert;
    
    UIImage* placeholderImage = [UIImage imageNamed:@"PlaceholderImage"];
    NSData *placeholderImageData = UIImagePNGRepresentation(placeholderImage);
    NSData *profileImageData = UIImagePNGRepresentation(profileImageView.image);
    
    if ([profileImageData isEqualToData:placeholderImageData])
    {
        
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please upload an image." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else if ([name isEmpty] || (name.text.length == 0) || [name.text isEqualToString:@""]){
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Name cannot be blank." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else if ([email isEmpty] || (email.text.length == 0) || [email.text isEqualToString:@""]){
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Email cannot be blank." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else if (![email isValidEmail])
    {
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Invalid email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    
    }
    else if ([password isEmpty] || (password.text.length == 0) || [password.text isEqualToString:@""]){
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Password cannot be blank." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else if (password.text.length < 8)
    {
        
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Your password must be atleast 8 characters long." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
        
    }
    else if ([confirmPassword isEmpty] || (confirmPassword.text.length == 0) || [confirmPassword.text isEqualToString:@""]){
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Confirm Password cannot be blank." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else if (![password.text isEqualToString:confirmPassword.text])
    {
        
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Passwords do not match." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
        
    }
    else{
        return YES;
    }
    
}
#pragma mark - end

#pragma mark - Keyboard Controls Delegate
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

#pragma mark - Textfield Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    [self.keyboardControls setActiveField:textField];
    
    if (!iPad) {
        [scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y - 80) animated:YES];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length >= MAX_LENGTH && range.length == 0)
    {
        return NO; // return NO to not change text
    }
    else
    {
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
