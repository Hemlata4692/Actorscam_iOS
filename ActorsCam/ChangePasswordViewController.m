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
}
@property (weak, nonatomic) IBOutlet UITextField *currentPassword;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassword;
@property (weak, nonatomic) IBOutlet UITextField *changePassword;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;

@end

@implementation ChangePasswordViewController
@synthesize currentPassword,confirmPassword,changePassword,scrollView;

#pragma mark - View life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addTextFieldPadding];
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addTextFieldPadding
{
    [currentPassword addTextFieldPadding:currentPassword];
    [confirmPassword addTextFieldPadding:confirmPassword];
    [changePassword addTextFieldPadding:changePassword];
}
#pragma mark - end

#pragma mark - Change Password
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

-(void)changePasswordMethod
{
    
    [[WebService sharedManager] changePassword:currentPassword.text newPassword:changePassword.text success:^(id responseObject) {
        
        [myDelegate StopIndicator];
        
    } failure:^(NSError *error) {
        
    }] ;
    
}
#pragma mark - end

#pragma mark - Textfield Validation
- (BOOL)performValidationsForChangePassword
{
    UIAlertView *alert;
    if ([currentPassword isEmpty] || [changePassword isEmpty] || [confirmPassword isEmpty])
    {
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Fields cannot be blank." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else if (!([changePassword.text isEqualToString:confirmPassword.text]))
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
    
    if (textField==currentPassword)
    {
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    else if (textField==changePassword)
    {
        [scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y-90) animated:YES];
    }
    else if (textField==confirmPassword)
    {
        [scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y-100) animated:YES];
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
