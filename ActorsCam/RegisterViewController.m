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

@interface RegisterViewController ()<BSKeyboardControlsDelegate>
{
    NSArray *textFieldArray;
}
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassword;
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@end

@implementation RegisterViewController
@synthesize name,email,userName,password,scrollView,confirmPassword;

#pragma mark - View life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addTextFieldPadding];
  
    //Adding textfield to array
    textFieldArray = @[name,email,userName,password,confirmPassword];
    //Keyboard toolbar action to display toolbar with keyboard to move next,previous
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFieldArray]];
    [self.keyboardControls setDelegate:self];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
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

#pragma mark - Button Actions

- (IBAction)signUpButtonAction:(id)sender
{
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [self.keyboardControls.activeField resignFirstResponder];
    if([self performValidationsForSignUp])
    {
//        [myDelegate ShowIndicator];
//        [self performSelector:@selector(loginUser) withObject:nil afterDelay:.1];
    }

}

#pragma mark - end

#pragma mark - Textfield Validation Action

- (BOOL)performValidationsForSignUp
{
    UIAlertView *alert;
    if ([name isEmpty] || [email isEmpty] || [userName isEmpty] || [password isEmpty] || [confirmPassword isEmpty])
    {
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please fill in all fields." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else
    {
        if ([email isValidEmail])
        {
            if ([password isEmpty])
            {
                alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please enter the Password." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                return NO;
            }
            else if (password.text.length<6)
            {
                
                alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Password should be at least six digits." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                return NO;
            }
            else if (!([password.text isEqualToString:confirmPassword.text]))
            {
                
                alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Password and confirm password must be same." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
            alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please enter valid Email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
