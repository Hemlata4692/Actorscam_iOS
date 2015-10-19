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
    NSArray *textFieldArray, *pickerArrayItem;
}

@property (weak, nonatomic) IBOutlet UITextField *userEmail;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (strong, nonatomic) IBOutlet UITextField *managerCategory;
@property (strong, nonatomic) IBOutlet UIButton *categoryPicker;;
@property (weak, nonatomic) IBOutlet UIButton *addEditManager;

//iPad
@property (weak, nonatomic) IBOutlet UITextField *ipad_userEmail;
@property (weak, nonatomic) IBOutlet UITextField *ipad_userName;
@property (strong, nonatomic) IBOutlet UITextField *ipad_managerCategory;
@property (strong, nonatomic) IBOutlet UIButton *ipad_categoryPicker;
@property (weak, nonatomic) IBOutlet UIButton *ipad_addEditManager;


@property (strong, nonatomic) IBOutlet UIPickerView *categoryPickerView;
@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *toolbarDone;
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation AddManagerViewController
@synthesize navTitle, userEmail, userName, emailId, name, managerId, category;
@synthesize managerCategory,categoryPicker,categoryPickerView,toolBar,toolbarDone;
@synthesize addEditManager,scrollView;

@synthesize ipad_userEmail, ipad_userName;
@synthesize ipad_managerCategory,ipad_categoryPicker;
@synthesize ipad_addEditManager;

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (iPad) {
        
        userEmail = ipad_userEmail;
        userName = ipad_userName;
        managerCategory = ipad_managerCategory;
        categoryPicker = ipad_categoryPicker;
        addEditManager = ipad_addEditManager;
        
    }
    
    categoryPickerView.translatesAutoresizingMaskIntoConstraints=YES;
    toolBar.translatesAutoresizingMaskIntoConstraints=YES;
    [self hidePickerWithAnimation];
    
    [self addTextFieldPadding];
    pickerArrayItem = @[[@"Agent" changeTextLanguage:@"Agent"], [@"Manager" changeTextLanguage:@"Manager"], [@"Self" changeTextLanguage:@"Self"], [@"Other" changeTextLanguage:@"Other"]];
    
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
    managerCategory.text = category;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setLocalizedString{
    
    [userName changeTextLanguage:@"Name"];
    [userEmail changeTextLanguage:@"Email address"];
    [managerCategory changeTextLanguage:@"Category"];
    [addEditManager changeTextLanguage:@"SAVE"];
    [toolbarDone.title changeTextLanguage:toolbarDone.title];
    [navTitle changeTextLanguage:navTitle];
    [category changeTextLanguage:category];
}

-(void)addTextFieldPadding
{
    [managerCategory addTextFieldPadding:managerCategory color:[UIColor lightGrayColor]];
    [userEmail addTextFieldPadding:userEmail color:[UIColor lightGrayColor]];
    [userName addTextFieldPadding:userName color:[UIColor lightGrayColor]];
    
}
#pragma mark - end

#pragma mark - Picker view animation
-(void)showPickerWithAnimation
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    categoryPickerView.backgroundColor=[UIColor whiteColor];
    
    categoryPickerView.frame = CGRectMake(categoryPickerView.frame.origin.x, (self.view.frame.size.height-categoryPickerView.frame.size.height) , self.view.frame.size.width, categoryPickerView.frame.size.height);
    
    toolBar.backgroundColor=[UIColor whiteColor];
    toolBar.frame = CGRectMake(toolBar.frame.origin.x, categoryPickerView.frame.origin.y-44, self.view.frame.size.width, toolBar.frame.size.height);
    [UIView commitAnimations];
    
}

-(void)hidePickerWithAnimation
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    categoryPickerView.frame = CGRectMake(categoryPickerView.frame.origin.x, 1500, self.view.frame.size.width, categoryPickerView.frame.size.height);
    toolBar.frame = CGRectMake(toolBar.frame.origin.x, 1500, self.view.frame.size.width, toolBar.frame.size.height);
    [UIView commitAnimations];
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
    
}

#pragma mark - end

#pragma mark - Textfield delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    [self.keyboardControls setActiveField:textField];
    [self hidePickerWithAnimation];
    
    if (!iPad) {
    if([[UIScreen mainScreen] bounds].size.height < 500)
    {
        if (textField==userName || textField==userEmail)
        {
            [scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y - 75) animated:YES];
        }
    }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == userName) {
        
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

#pragma mark - Pickerview delegate methods
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return pickerArrayItem.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [pickerArrayItem objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    managerCategory.text=[pickerArrayItem objectAtIndex:row];
}
#pragma mark - end

#pragma mark - View IB actions
- (IBAction)doneAction:(UIBarButtonItem *)sender {
    NSInteger index = [categoryPickerView selectedRowInComponent:0];
    managerCategory.text=[pickerArrayItem objectAtIndex:index];
    
    [self hidePickerWithAnimation];
}

//Select category drop-down
- (IBAction)pickerViewAction:(UIButton *)sender {
    [self.view endEditing:YES];
    [self showPickerWithAnimation];;
}

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
        [[WebService sharedManager] addManager:userName.text managerEmail:userEmail.text category:(NSString *)managerCategory.text success:^(id responseObject) {
            [myDelegate StopIndicator];
            NSDictionary *dict = (NSDictionary *)responseObject;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:[dict objectForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alert.tag = 1;
            [alert show];

            
        } failure:^(NSError *error) {
            
        }] ;
    }
    else{
        //edit manager
         [[WebService sharedManager] updateManager:userName.text managerEmail:userEmail.text managerId:managerId category:(NSString *)managerCategory.text success:^(id responseObject) {
            [myDelegate StopIndicator];
             NSDictionary *dict = (NSDictionary *)responseObject;
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:[dict objectForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
              alert.tag = 1;
             [alert show];

            
        } failure:^(NSError *error) {
            
        }] ;
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

#pragma mark - Email validation
- (BOOL)performValidationsForManageData
{
    
    UIAlertView *alert;
    if ([managerCategory isEmpty])
    {
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please choose a category." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    if ([userName isEmpty])
    {
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Name cannot be blank." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else if ([userEmail isEmpty])
    {
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Email address cannot be blank." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else if (![userEmail isValidEmail])
    {
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Invalid email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else
    {
        return YES;
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
