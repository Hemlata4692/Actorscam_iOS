//
//  AddManagerViewController.m
//  ActorsCam
//
//  Created by Hema on 19/08/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "AddManagerViewController.h"
#import "UITextField+Padding.h"
#import "UITextField+Validations.h"
#import "BSKeyboardControls.h"
#import "UIView+RoundedCorner.h"

@interface AddManagerViewController ()<UITextFieldDelegate,BSKeyboardControlsDelegate>
{
    NSArray *textFieldArray;
}


@property (weak, nonatomic) IBOutlet UITextField *userEmail;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UIButton *addEditManager;
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@end

@implementation AddManagerViewController
@synthesize navTitle, userEmail, userName, emailId, name, managerId;
@synthesize addEditManager;

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addTextFieldPadding];
    
    textFieldArray = @[userName, userEmail];
    //Keyboard toolbar action to display toolbar with keyboard to move next,previous
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFieldArray]];
    [self.keyboardControls setDelegate:self];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = navTitle;
    userEmail.text = emailId;
    userName.text = name;
    
}

-(void)addTextFieldPadding
{
    [addEditManager setCornerRadius:5.0f];
    [userEmail addTextFieldPadding:userEmail];
    [userName addTextFieldPadding:userName];
    
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
    
}

#pragma mark - end

#pragma mark - Textfield Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    [self.keyboardControls setActiveField:textField];
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [textField resignFirstResponder];
    return YES;
    
}
#pragma mark - end
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - add/Edit Manager Action
- (IBAction)addEditManagerAction:(UIButton *)sender {
    
    [self.view endEditing:YES];
    if([self performValidationsForManageData])
    {
        [myDelegate ShowIndicator];
        [self performSelector:@selector(callAddEditManager) withObject:nil afterDelay:.1];
    }
}

-(void)callAddEditManager
{
    if ([emailId isEqualToString:@""] || emailId.length == 0) {
        //Add manager
        [[WebService sharedManager] addManager:userName.text managerEmail:userEmail.text success:^(id responseObject) {
            NSLog(@"response is %@",responseObject);
            [myDelegate StopIndicator];
            NSDictionary *dict = (NSDictionary *)responseObject;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:[dict objectForKey:@"message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            alert.tag = 1;
            [alert show];

            
        } failure:^(NSError *error) {
            
        }] ;
    }
    else{
        //edit manager
         [[WebService sharedManager] updateManager:userName.text managerEmail:userEmail.text managerId:managerId success:^(id responseObject) {
            NSLog(@"response is %@",responseObject);
            [myDelegate StopIndicator];
             NSDictionary *dict = (NSDictionary *)responseObject;
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:[dict objectForKey:@"message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
              alert.tag = 1;
             [alert show];

            
        } failure:^(NSError *error) {
            
        }] ;
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
          [self.navigationController popViewControllerAnimated:YES];
    }
  
}
#pragma mark - end

#pragma mark - Textfield Validation Action
- (BOOL)performValidationsForManageData
{
    
    UIAlertView *alert;
    if ([userEmail isEmpty])
    {
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Email cannot be blank." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else
    {
        if ([userEmail isValidEmail])
        {
            if ([userName isEmpty])
            {
                alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Name cannot be blank." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
