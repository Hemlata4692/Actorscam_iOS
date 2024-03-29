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
}
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassword;
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (nonatomic, strong) UIPopoverController *popover;
@end

@implementation RegisterViewController
@synthesize name,email,userName,password,scrollView,confirmPassword,profileImageView;
@synthesize popover;

#pragma mark - View life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    [name addTextFieldPadding:name];
    [email addTextFieldPadding:email];
    [userName addTextFieldPadding:userName];
    [password addTextFieldPadding:password];
    [confirmPassword addTextFieldPadding:confirmPassword];
}

#pragma mark - end

#pragma mark - Register User
- (IBAction)signUpButtonAction:(id)sender
{
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [self.keyboardControls.activeField resignFirstResponder];
    if([self performValidationsForSignUp])
    {
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
        [alert show];
        
    } failure:^(NSError *error) {
        
    }] ;
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - end

#pragma mark - Image Picker
- (IBAction)imagePickerAction:(id)sender
{
    UIActionSheet * share=[[UIActionSheet alloc]initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo",@"Choose Existing Photo", nil];
    
    if ([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
        
            [share showFromRect:CGRectMake(profileImageView.frame.origin.x, profileImageView.frame.origin.y+154, 320, 120) inView:self.view animated:YES];
      }
    else{
        // In this case the device is an iPhone/iPod Touch.
         [share showInView:[UIApplication sharedApplication].keyWindow];
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
        [self presentViewController:imgPicker animated:YES completion:NULL];
        }
    }
    else if(buttonIndex==1)
    {
        //Setting image from gallery
        imgPicker.delegate = self;
        imgPicker.allowsEditing = YES;
        imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            self.popover = [[UIPopoverController alloc] initWithContentViewController:imgPicker];
            self.popover.delegate = self;
            
            [self.popover presentPopoverFromRect:CGRectMake(600, 400, 311, 350) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
            [self.popover setPopoverContentSize:CGSizeMake(330, 515)];

        }
        else
        {
             [self presentViewController:imgPicker animated:YES completion:NULL];
        }
       
    }
    
}
#pragma mark - end

#pragma mark - Textfield Validation
- (BOOL)performValidationsForSignUp
{
    UIAlertView *alert;
    if ([name isEmpty] || [email isEmpty] || [userName isEmpty] || [password isEmpty] || [confirmPassword isEmpty])
    {
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Fields cannot be blank." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else
    {
        if ([email isValidEmail])
        {
            if ([password isEmpty])
            {
                alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Password cannot be blank." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                return NO;
            }
            else if (!([password.text isEqualToString:confirmPassword.text]))
            {
                
                alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Passwords do not match." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                return NO;
            }

            else
            {
                return YES;
            }
        }
        else
        {
            alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Invalid email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return NO;
        }
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
    
    if (textField==name)
    {
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    else if (textField==email)
    {
        [scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y-90) animated:YES];
    }
    else if (textField==userName)
    {
        [scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y-100) animated:YES];
    }
    else if (textField==password)
    {
        
        [scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y-110) animated:YES];
        
    }
    else if (textField==confirmPassword)
    {
        
        [scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y-130) animated:YES];
        
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
