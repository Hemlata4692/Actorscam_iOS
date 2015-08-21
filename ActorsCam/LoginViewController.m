//
//  LoginViewController.m
//  ActorsCam
//
//  Created by Hema on 17/08/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "LoginViewController.h"
#import "UITextField+Padding.h"
#import "UITextField+Validations.h"
#import "BSKeyboardControls.h"
#import "UIView+RoundedCorner.h"
#import "SWRevealViewController.h"

@interface LoginViewController ()<UITextFieldDelegate,BSKeyboardControlsDelegate>
{
    NSArray *textFieldArray;
}
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *forgotPasswordView;
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@property (weak, nonatomic) IBOutlet UITextField *forgotPasswordEmail;
@property (weak, nonatomic) IBOutlet UIButton *sendLinkBtn;
@property (weak, nonatomic) IBOutlet UIView *forgotPasswordPopUp;

@end

@implementation LoginViewController
@synthesize userName,password,loginBtn,forgotPasswordBtn,scrollView;
@synthesize forgotPasswordEmail,forgotPasswordView,sendLinkBtn,forgotPasswordPopUp;
#pragma mark - View life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addTextFieldPadding];
    [self addCornerRadius];
    
    forgotPasswordView.hidden=YES;
    //Adding textfield to array
    textFieldArray = @[userName,password];
    //Keyboard toolbar action to display toolbar with keyboard to move next,previous
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFieldArray]];
    [self.keyboardControls setDelegate:self];
    
    NSLog(@"Login viewcontroller");
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)addTextFieldPadding
{
    [userName addTextFieldPadding:userName];
    [password addTextFieldPadding:password];
    [forgotPasswordEmail addTextFieldPadding:forgotPasswordEmail];
}
-(void)addCornerRadius
{
    [loginBtn setCornerRadius:5.0f];
    [sendLinkBtn setCornerRadius:5.0f];
    [forgotPasswordPopUp setCornerRadius:2.0f];
}

#pragma mark - end

#pragma mark - Login Actions
- (IBAction)loginButtonAction:(id)sender
{
//    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
//    [userName resignFirstResponder];
//    [password resignFirstResponder];
//    if([self performValidationsForLogin])
//    {
//        //        [myDelegate ShowIndicator];
//        //        [self performSelector:@selector(loginUser) withObject:nil afterDelay:.1];
//    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
    myDelegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [myDelegate.window setRootViewController:objReveal];
    [myDelegate.window setBackgroundColor:[UIColor whiteColor]];
    [myDelegate.window makeKeyAndVisible];

}

#pragma mark - end

#pragma mark - Forgot Password Actions

- (IBAction)sendForgotPasswordLink:(id)sender
{
    forgotPasswordView.hidden=YES;
}

- (IBAction)forgotPasswordButtonAction:(id)sender
{
    forgotPasswordView.hidden=NO;
}
#pragma mark - end
#pragma mark - Textfield Validation Action

- (BOOL)performValidationsForLogin
{
    UIAlertView *alert;
    if ([userName isEmpty] || [password isEmpty])
    {
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please fill in all fields." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    
    else if (password.text.length<6)
    {
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Password should be at least six digits." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else
    {
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
    
    if (textField==userName)
    {
        [scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y-120) animated:YES];
    }
    else if (textField==password)
    {
        
        [scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y-140) animated:YES];
        
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
