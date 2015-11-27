//
//  ChangePasswordViewController.m
//  ActorsCam
//
//  Created by Hema on 17/08/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "UITextField+Padding.h"
#import "UITextField+Validations.h"
#import "BSKeyboardControls.h"

@interface ChangePasswordViewController ()<BSKeyboardControlsDelegate>
{
    NSArray *textFieldArray;
    NSString *navTitle;
}
@property (weak, nonatomic) IBOutlet UITextField *currentPassword;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassword;
@property (weak, nonatomic) IBOutlet UITextField *changePassword;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *submitBtn;

//iPad
@property (weak, nonatomic) IBOutlet UITextField *ipad_currentPassword;
@property (weak, nonatomic) IBOutlet UITextField *ipad_confirmPassword;
@property (weak, nonatomic) IBOutlet UITextField *ipad_changePassword;
@property (strong, nonatomic) IBOutlet UIButton *ipad_submitBtn;

@property (nonatomic, strong) BSKeyboardControls *keyboardControls;

@end

@implementation ChangePasswordViewController
@synthesize currentPassword,confirmPassword,changePassword,scrollView,submitBtn;
@synthesize ipad_currentPassword,ipad_confirmPassword,ipad_changePassword,ipad_submitBtn;

#pragma mark - View life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    navTitle = @"Change Password";
    
    if (iPad) {
        
        currentPassword = ipad_currentPassword;
        confirmPassword = ipad_confirmPassword;
        changePassword = ipad_changePassword;
        submitBtn = ipad_submitBtn;
        
    }
    
    [self addTextFieldPadding];
    [self setLocalizedString];
    
    //Remove swipe gesture for sidebar
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers)
    {
        [self.view removeGestureRecognizer:recognizer];
    }
    
    //Adding textfield to array
    textFieldArray = @[currentPassword,changePassword,confirmPassword];
    //Keyboard toolbar action to display toolbar with keyboard to move next,previous
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFieldArray]];
    [self.keyboardControls setDelegate:self];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    self.title = navTitle;
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setLocalizedString{
    [currentPassword changeTextLanguage:@"Current password"];
    [confirmPassword changeTextLanguage:@"Confirm password"];
    [changePassword changeTextLanguage:@"New password"];
    [submitBtn changeTextLanguage:@"SUBMIT"];
    navTitle = [navTitle changeTextLanguage:@"Change password"];
}

-(void)addTextFieldPadding
{
    [currentPassword addTextFieldPadding:currentPassword color:[UIColor lightGrayColor]];
    [confirmPassword addTextFieldPadding:confirmPassword color:[UIColor lightGrayColor]];
    [changePassword addTextFieldPadding:changePassword color:[UIColor lightGrayColor]];
    
}

#pragma mark - end

#pragma mark - View IB actions
- (IBAction)changePasswordButtonAction:(id)sender
{
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [self.keyboardControls.activeField resignFirstResponder];
    if([self performValidationsForChangePassword])
    {
            [myDelegate ShowIndicator];
            [self performSelector:@selector(changePasswordMethod) withObject:nil afterDelay:.1];
    }

}
#pragma mark - end

#pragma mark - Change password web-service
-(void)changePasswordMethod
{
    
    [[WebService sharedManager] changePassword:currentPassword.text newPassword:changePassword.text success:^(id responseObject) {
        
        [myDelegate StopIndicator];
        NSString* msg = [responseObject objectForKey:@"message"];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[@"Success" changeTextLanguage:@"Success"] message:[msg changeTextLanguage:@"Your password is changed successfully."] delegate:self cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"] otherButtonTitles:nil, nil];
       
        [alert show];
         alert.tag=1;

        
    } failure:^(NSError *error) {
        
    }] ;
    
}
#pragma mark - end

#pragma mark - UIAlertView delegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==1 && buttonIndex==0)
    {
         UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
         UIViewController * dashboard = [storyboard instantiateViewControllerWithIdentifier:@"DashboardView"];
        [self.navigationController pushViewController:dashboard animated:YES];
    }
}
#pragma mark - end

#pragma mark - Email validation
- (BOOL)performValidationsForChangePassword
{
    UIAlertView *alert;
    if ([currentPassword isEmpty] || (currentPassword.text.length == 0) || [currentPassword.text isEqualToString:@""]){
        alert = [[UIAlertView alloc]initWithTitle:[@"Alert" changeTextLanguage:@"Alert"] message:@"Current password cannot be blank." delegate:self cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"] otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else if (currentPassword.text.length < 8)
    {
        alert = [[UIAlertView alloc]initWithTitle:[@"Alert" changeTextLanguage:@"Alert"] message:@"Your current password must be atleast 8 characters long." delegate:self cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"] otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else if ([changePassword isEmpty] || (changePassword.text.length == 0) || [changePassword.text isEqualToString:@""]){
        alert = [[UIAlertView alloc]initWithTitle:[@"Alert" changeTextLanguage:@"Alert"] message:@"New password cannot be blank." delegate:self cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"] otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else if (changePassword.text.length < 8)
    {
        alert = [[UIAlertView alloc]initWithTitle:[@"Alert" changeTextLanguage:@"Alert"] message:@"Your new password must be atleast 8 characters long." delegate:self cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"] otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else if ([confirmPassword isEmpty] || (confirmPassword.text.length == 0) || [confirmPassword.text isEqualToString:@""]){
        alert = [[UIAlertView alloc]initWithTitle:[@"Alert" changeTextLanguage:@"Alert"] message:@"Confirm password cannot be blank." delegate:self cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"] otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else if (confirmPassword.text.length < 8)
    {
        alert = [[UIAlertView alloc]initWithTitle:[@"Alert" changeTextLanguage:@"Alert"] message:[@"Your confirm password must be atleast 8 characters long." changeTextLanguage:@"Your confirm password must be atleast 8 characters long."] delegate:self cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"] otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else if (!([changePassword.text isEqualToString:confirmPassword.text]))
    {
        alert = [[UIAlertView alloc]initWithTitle:[@"Alert" changeTextLanguage:@"Alert"] message:[@"Passwords do not match." changeTextLanguage:@"Passwords do not match."] delegate:self cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"] otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else
    {
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
        if([[UIScreen mainScreen] bounds].size.height<490)
        {
            if (textField==confirmPassword)
            {
                [scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y-115) animated:YES];
            }
        }
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
