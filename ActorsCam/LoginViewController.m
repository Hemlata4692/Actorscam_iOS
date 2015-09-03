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

#import "ChooseLanguageViewController.h"

@interface LoginViewController ()<UITextFieldDelegate,BSKeyboardControlsDelegate>
{
    NSArray *textFieldArray;
}
@property (weak, nonatomic) IBOutlet UITextField *userEmail;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *forgotPasswordView;
@property (weak, nonatomic) IBOutlet UILabel *hereLabel;
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@property (weak, nonatomic) IBOutlet UITextField *forgotPasswordEmail;
@property (weak, nonatomic) IBOutlet UIButton *sendLinkBtn;
@property (weak, nonatomic) IBOutlet UIView *forgotPasswordPopUp;
@property (weak, nonatomic) IBOutlet UIButton *signUp;
@property (weak, nonatomic) IBOutlet UIButton *languageLabel;

@end

@implementation LoginViewController
@synthesize userEmail,password,loginBtn,forgotPasswordBtn,scrollView;
@synthesize forgotPasswordEmail,forgotPasswordView,sendLinkBtn,forgotPasswordPopUp;

#pragma mark - View life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addTextFieldPadding];
    [self addCornerRadius];
    
    forgotPasswordView.hidden=YES;
    //Adding textfield to array
    textFieldArray = @[userEmail,password];
    //Keyboard toolbar action to display toolbar with keyboard to move next,previous
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFieldArray]];
    [self.keyboardControls setDelegate:self];
    
    UITapGestureRecognizer* forgotPasswordViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
    
    forgotPasswordViewTap.numberOfTapsRequired = 1;
    forgotPasswordViewTap.numberOfTouchesRequired = 1;
    [forgotPasswordView addGestureRecognizer: forgotPasswordViewTap];
//    UITapGestureRecognizer *forgotPasswordViewTap =
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    [self setLocalizedString];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    statusBarView.backgroundColor = [UIColor colorWithRed:83.0/255.0 green:24.0/255.0 blue:152.0/255.0 alpha:1.0];
    [self.view addSubview:statusBarView];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
}

-(void)setLocalizedString{

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)addTextFieldPadding
{
    
    [userEmail addTextFieldPadding:userEmail];
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
    
    [self.view endEditing:YES];
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];

    if([self performValidationsForLogin])
    {
        [myDelegate ShowIndicator];
        [self performSelector:@selector(loginUser) withObject:nil afterDelay:.1];
    }

}

-(void)loginUser
{
    [[WebService sharedManager] userLogin:userEmail.text Password:password.text success:^(id responseObject) {
        NSLog(@"response is %@",responseObject);
       
        [myDelegate StopIndicator];
        NSDictionary *dict = (NSDictionary *)responseObject;
        [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"userid"] forKey:@"UserId"];
        [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"username"] forKey:@"UserName"];
        [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"profileImageUrl"] forKey:@"profileImageUrl"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
        [self.navigationController pushViewController:objReveal animated:YES];
    } failure:^(NSError *error) {
        
    }] ;
    
}
#pragma mark - end

#pragma mark - Forgot Password Actions
- (IBAction)forgotPasswordButtonAction:(id)sender
{
    
    forgotPasswordView.hidden=NO;
    
}

- (IBAction)sendForgotPasswordLink:(id)sender
{
    
    [self.view endEditing:YES];
    password.text = @"";
    if([self performValidationsForForgotPassword])
    {
        [myDelegate ShowIndicator];
        [self performSelector:@selector(forgotPassword) withObject:nil afterDelay:.1];
    }
//    forgotPasswordView.hidden=YES;
    
}

-(void)forgotPassword
{
    [[WebService sharedManager] forgotPassword:forgotPasswordEmail.text success:^(id responseObject){
        
        [myDelegate StopIndicator];
        forgotPasswordEmail.text = @"";
        forgotPasswordView.hidden=YES;
          NSLog(@"forgot password response is %@",responseObject);
        forgotPasswordView.hidden=YES;
    } failure:^(NSError *error) {
        
    }] ;
    
}


-(void)handleSingleTap{
    
    forgotPasswordEmail.text = @"";
    forgotPasswordView.hidden=YES;
    
}

#pragma mark - end

#pragma mark - Textfield Validation Action
- (BOOL)performValidationsForLogin
{
    
    UIAlertView *alert;
    if ([userEmail isEmpty])
    {
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please enter the Email." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else
    {
        if ([userEmail isValidEmail])
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

- (BOOL)performValidationsForForgotPassword
{
    
    UIAlertView *alert;
    if ([forgotPasswordEmail isEmpty])
    {
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please enter the Email." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else
    {
        if ([forgotPasswordEmail isValidEmail])
        {
            return YES;
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
    
    if (textField==userEmail)
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

#pragma mark - choose Language Action
- (IBAction)chooseLanguageAction:(UIButton *)sender {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ChooseLanguageViewController *chooseLangView =[storyboard instantiateViewControllerWithIdentifier:@"ChooseLanguageView"];
    chooseLangView.myVC = (LoginViewController*)self;
//    [self.view ]
    [self addChildViewController:chooseLangView];
    [self.view addSubview:chooseLangView.view];
    [chooseLangView didMoveToParentViewController:self];
}
#pragma mark - end
@end
