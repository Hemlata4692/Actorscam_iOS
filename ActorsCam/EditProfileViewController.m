//
//  EditProfileViewController.m
//  ActorsCam
//
//  Created by Hema on 19/08/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "EditProfileViewController.h"
#import "UITextField+Padding.h"
#import "UITextField+Validations.h"
#import "BSKeyboardControls.h"
#import "WebService.h"
#import <UIImageView+AFNetworking.h>

@interface EditProfileViewController ()<BSKeyboardControlsDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverControllerDelegate>
{
//    NSArray *textFieldArray;
    UIImagePickerController *imgPicker;
}
@property (weak, nonatomic) IBOutlet UITextField *name;
//@property (weak, nonatomic) IBOutlet UITextField *email;
//@property (weak, nonatomic) IBOutlet UITextField *userName;
//@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *save;
//@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
//@property (weak, nonatomic) IBOutlet UITextField *confirmPassword;
//@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@property (weak, nonatomic) IBOutlet UITextField *emailId;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
//@property (nonatomic, strong) UIPopoverController *popover;

@end

@implementation EditProfileViewController
@synthesize name,profileImageView,emailId;
//@synthesize popover;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addTextFieldPadding];
//    name.backgroundColor = [UIColor redColor];
    imgPicker = [[UIImagePickerController alloc] init];
    
    //Adding textfield to array
//    textFieldArray = @[name,email,password,confirmPassword];
    //Keyboard toolbar action to display toolbar with keyboard to move next,previous
//    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFieldArray]];
//    [self.keyboardControls setDelegate:self];

    
    // Do any additional setup after loading the view.
    [myDelegate ShowIndicator];
    [self performSelector:@selector(getprofile) withObject:nil afterDelay:.1];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
  
}

-(void)getprofile
{
    [[WebService sharedManager] getprofile:^(id responseObject) {
        [myDelegate StopIndicator];
        NSDictionary *dict = (NSDictionary *)responseObject;
        
        name.text = [dict objectForKey:@"username"];
        emailId.text = [dict objectForKey:@"email"];
        __weak UIImageView *weakRef = profileImageView;
        NSString *tempImageString = [dict objectForKey:@"profileImageUrl"];
        
        NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:tempImageString]
                                                      cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                  timeoutInterval:60];
        
        [profileImageView setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"picture"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            weakRef.contentMode = UIViewContentModeScaleAspectFit;
            weakRef.clipsToBounds = YES;
            weakRef.image = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            
        }];

    } failure:^(NSError *error) {

    }] ;

}


-(void)addTextFieldPadding
{
    [name addTextFieldPadding:name];
    [emailId addTextFieldPadding:emailId];
//    [userName addTextFieldPadding:userName];
//    [password addTextFieldPadding:password];
//    [confirmPassword addTextFieldPadding:confirmPassword];
}

#pragma mark - Register User Actions

- (IBAction)SaveButtonAction:(id)sender
{
//    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
//    [self.keyboardControls.activeField resignFirstResponder];
    [self.view endEditing:YES];
    //    if([self performValidationsForSignUp])
    //    {
    [myDelegate ShowIndicator];
    [self performSelector:@selector(changeProfile) withObject:nil afterDelay:.1];
    // }
    
}

-(void)changeProfile
{
    [[WebService sharedManager] updateprofile:name.text image:profileImageView.image success:^(id responseObject) {
        
        [myDelegate StopIndicator];
        NSDictionary *dict = (NSDictionary *)responseObject;
        [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"image"] forKey:@"profileImageUrl"];
        [[NSUserDefaults standardUserDefaults] setObject:name.text forKey:@"UserName"];
        
        //        [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"UserId"] forKey:@"userid"];
        //        [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"Name"] forKey:@"name"];
        //        [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"ProfileImage"] forKey:@"profileImageUrl"];
        //        [[NSUserDefaults standardUserDefaults] synchronize];
        //        UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        //        UIViewController *view1=[sb instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
        //        myDelegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        //        [myDelegate.window setRootViewController:view1];
        //        [myDelegate.window setBackgroundColor:[UIColor whiteColor]];
        //        [myDelegate.window makeKeyAndVisible];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:[dict objectForKey:@"message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        
    } failure:^(NSError *error) {
        
    }] ;
    //    [[WebService sharedManager] postanswer:@"1440072790" answer:@"testing12358" image:profileImageView.image embedUrl:@"" groupId:@"1" success:^(id responseData) {
    //        [myDelegate StopIndicator];
    //        NSLog(@"responseData %@",responseData);
    //
    //    } failure:^(NSError *error) {
    //
    //    }];
    
    
}
//
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    [self.navigationController popViewControllerAnimated:YES];
//}
#pragma mark - end
//
//#pragma mark - Image Picker
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
//
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)info
{
    profileImageView.image = image;
    [imgPicker dismissViewControllerAnimated:YES completion:NULL];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
}
//
#pragma mark - end
//
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
//        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//        {
//            self.popover = [[UIPopoverController alloc] initWithContentViewController:imgPicker];
//            self.popover.delegate = self;
//            
//            [self.popover presentPopoverFromRect:CGRectMake(600, 400, 311, 350) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
//            [self.popover setPopoverContentSize:CGSizeMake(330, 515)];
//            
//        }
//        else
//        {
            [self presentViewController:imgPicker animated:YES completion:NULL];
//        }
        
    }
    
}
#pragma mark - end
//
//
//#pragma mark - Textfield Validation Action
//
//- (BOOL)performValidationsForSignUp
//{
//    UIAlertView *alert;
//    if ([name isEmpty] || [email isEmpty] || [userName isEmpty] || [password isEmpty] || [confirmPassword isEmpty])
//    {
//        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please fill in all fields." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
//        return NO;
//    }
//    else
//    {
//        if ([email isValidEmail])
//        {
//            if ([password isEmpty])
//            {
//                alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please enter the Password." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                [alert show];
//                return NO;
//            }
//            else if (password.text.length<6)
//            {
//                
//                alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Password should be at least six digits." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                [alert show];
//                return NO;
//            }
//            else if (!([password.text isEqualToString:confirmPassword.text]))
//            {
//                
//                alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Password and confirm password must be same." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                [alert show];
//                return NO;
//            }
//            
//            else
//            {
//                return YES;
//            }
//        }
//        else
//        {
//            alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please enter valid Email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//            [alert show];
//            return NO;
//        }
//    }
//    
//    
//}
//#pragma mark - end
//
//#pragma mark - Keyboard Controls Delegate
//- (void)keyboardControls:(BSKeyboardControls *)keyboardControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction
//{
//    UIView *view;
//    
//    if ([[UIDevice currentDevice].systemVersion floatValue]< 7.0) {
//        view = field.superview.superview;
//    } else {
//        view = field.superview.superview.superview;
//    }
//}
//
//- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControls
//{
//    [keyboardControls.activeField resignFirstResponder];
//    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
//    
//    
//}
//
//#pragma mark - end
//
#pragma mark - Textfield Delegates

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
//    [self.keyboardControls setActiveField:textField];
//    
//    if (textField==name)
//    {
//        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
//    }
//    else if (textField==email)
//    {
//        [scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y-90) animated:YES];
//    }
//    else if (textField==userName)
//    {
//        [scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y-100) animated:YES];
//    }
//    else if (textField==password)
//    {
//        
//        [scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y-110) animated:YES];
//        
//    }
//    else if (textField==confirmPassword)
//    {
//        
//        [scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y-130) animated:YES];
//        
//    }
//    
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    
//    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - end
@end
