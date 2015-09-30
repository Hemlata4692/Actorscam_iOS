//
//  AudioViewController.m
//  ActorsCam
//
//  Created by Ranosys on 30/09/15.
//  Copyright © 2015 Ranosys. All rights reserved.
//

#import "AudioViewController.h"
#import "DashboardViewController.h"
#import <MessageUI/MessageUI.h>
#import "BSKeyboardControls.h"
#import "AddManagerViewController.h"

@interface AudioViewController ()<MFMailComposeViewControllerDelegate,BSKeyboardControlsDelegate>{
    NSMutableArray *pickerArray, *managerListArray, *categoryList, *managerNameList;
    NSString *pickerChecker, *navTitle;
    NSDictionary *selectedData;
    int selectedCategoryIndex, selectedManagerIndex;
}

@property (nonatomic, strong) BSKeyboardControls *keyboardControls;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *mainView;

@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIButton *playOutlet;
@property (strong, nonatomic) IBOutlet UIButton *recordOulet;


@property (strong, nonatomic) IBOutlet UIView *noManagerView;
@property (weak, nonatomic) IBOutlet UILabel *noManager;
@property (strong, nonatomic) IBOutlet UIButton *addRepresentative;

@property (weak, nonatomic) IBOutlet UIView *selectManagerView;
@property (weak, nonatomic) IBOutlet UILabel *selectRepresentativeLabel;
@property (strong, nonatomic) IBOutlet UITextField *selectCategory;
@property (weak, nonatomic) IBOutlet UITextField *managerName;
@property (strong, nonatomic) IBOutlet UILabel *notesLabel;
@property (strong, nonatomic) IBOutlet UITextView *noteTextView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (weak, nonatomic) IBOutlet UIPickerView *managerListPickerView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *toolBarDone;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@end

@implementation AudioViewController
@synthesize scrollView;
@synthesize noManagerView,noManager,addRepresentative;
@synthesize selectManagerView,selectRepresentativeLabel,selectCategory,managerName,notesLabel,noteTextView,sendButton;
@synthesize managerListPickerView,toolBar,toolBarDone;

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    managerListPickerView.translatesAutoresizingMaskIntoConstraints=YES;
    toolBar.translatesAutoresizingMaskIntoConstraints=YES;
    //Keyboard toolbar action to display toolbar with keyboard to move next,previous
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:@[noteTextView]]];
    [self.keyboardControls setDelegate:self];
    
    navTitle = @"Audio Record";
   
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self hidePickerWithAnimation];
    
    pickerChecker = @"";
    pickerArray = [NSMutableArray new];
    managerListArray = [NSMutableArray new];
    categoryList = [NSMutableArray new];
    noManagerView.hidden = YES;
    selectManagerView.hidden = NO;
    
    selectedCategoryIndex = 0;
    selectedManagerIndex = 0;
    
    self.mainView.translatesAutoresizingMaskIntoConstraints = NO;
    self.mainView.frame = CGRectMake(0, 0, self.view.frame.size.width, 658);
    
    UIView *rightPadding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 0)];
    managerName.rightView = rightPadding;
    managerName.rightViewMode = UITextFieldViewModeAlways;
    
    [managerName setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    noteTextView.layer.borderColor = [UIColor colorWithRed:190.0/255.0 green:190.0/255.0 blue:190.0/255.0 alpha:1.0].CGColor;
    noteTextView.layer.borderWidth = 1;
    
    selectManagerView.hidden = NO;
    noManagerView.hidden = YES;
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = navTitle;
    
    [myDelegate ShowIndicator];
    [self performSelector:@selector(managerListing) withObject:nil afterDelay:.1];
}

-(void)setLocalizedString{
    [noManager changeTextLanguage:@"You don't have any representative added yet!"];
    [addRepresentative changeTextLanguage:@"ADD REPRESENTATIVE"];
    
    [selectRepresentativeLabel changeTextLanguage:@"Select Representative"];
    [selectCategory changeTextLanguage:@"Category"];
    [managerName changeTextLanguage:@"Name"];
    [notesLabel changeTextLanguage:@"Notes"];
    [sendButton changeTextLanguage:@"SUBMIT"];
    
    [navTitle changeTextLanguage:@"Preview"];
}
#pragma mark - end

#pragma mark - Picker view animation
-(void)showPickerWithAnimation
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    //    [_sliderScrollView setContentOffset:CGPointMake(0, _sliderScrollView.frame.origin.y+100) animated:YES];
    
    managerListPickerView.backgroundColor=[UIColor whiteColor];
    
    managerListPickerView.frame = CGRectMake(managerListPickerView.frame.origin.x, (self.view.frame.size.height-managerListPickerView.frame.size.height) , self.view.frame.size.width, managerListPickerView.frame.size.height);
    
    toolBar.backgroundColor=[UIColor whiteColor];
    toolBar.frame = CGRectMake(toolBar.frame.origin.x, managerListPickerView.frame.origin.y-44, self.view.frame.size.width, toolBar.frame.size.height);
    [UIView commitAnimations];
    
}

-(void)hidePickerWithAnimation
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    managerListPickerView.frame = CGRectMake(managerListPickerView.frame.origin.x, 1000, self.view.frame.size.width, managerListPickerView.frame.size.height);
    toolBar.frame = CGRectMake(toolBar.frame.origin.x, 1000, self.view.frame.size.width, toolBar.frame.size.height);
    [UIView commitAnimations];
}
#pragma mark - end

#pragma mark - TextView Delegate
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    [self hidePickerWithAnimation];
    
    [self.keyboardControls setActiveField:textView];
    [scrollView setContentOffset:CGPointMake(0, textView.frame.origin.y + textView.frame.size.height + 200) animated:YES];
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
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

#pragma mark - send Image Button Action
- (IBAction)sendAction:(id)sender {
    [self hidePickerWithAnimation];
    if (managerListArray.count != 0) {
        if ([MFMailComposeViewController canSendMail])
            
        {
            // Email Subject
            
            NSString *emailTitle = @"Actor's CAM - New Audio from  model";
            
            NSArray *toRecipents = [NSArray arrayWithObject:[selectedData objectForKey:@"managerEmail"]];
            
            MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
            
            mc.mailComposeDelegate = self;
            
            [mc setSubject:emailTitle];
            
            [mc setMessageBody:noteTextView.text isHTML:NO];
            
            //        for (UIImage *yourImage in imageArray )
            //
            //        {
            //
            //            NSData *imgData = UIImagePNGRepresentation(yourImage);
            //
            //            [mc addAttachmentData:imgData mimeType:@"image/png" fileName:[NSString stringWithFormat:@"a.png"]];
            //
            //            //movie path
            //
            //            //           NSURL * videoURL = [[NSURL alloc] initFileURLWithPath:moviePath];
            //
            //            //            [mc addAttachmentData:[NSData dataWithContentsOfURL:videoURL] mimeType:@"video/quicktime" fileName:@"defectVideo.MOV"];
            //
            //
            //
            //            //audio
            //
            //            //            NSString *mp3File = [NSTemporaryDirectory() stringByAppendingPathComponent: @"tmp.mp3"];
            //            //
            //            //            NSURL    *fileURL = [[NSURL alloc] initFileURLWithPath:mp3File];
            //            //
            //            //            NSData *soundFile = [[NSData alloc] initWithContentsOfURL:fileURL];
            //            //
            //            //            [mc addAttachmentData:soundFile mimeType:@"audio/mpeg" fileName:@"tmp.mp3"];
            //
            //
            //
            //        }
            //
            
            mc.navigationBar.tintColor = [UIColor whiteColor];
            [mc setToRecipients:toRecipents];
            [self presentViewController:mc animated:YES completion:NULL];
            
        }
        
        else
            
        {
            
            UIAlertView *alertView = [[UIAlertView alloc]
                                      
                                      initWithTitle:nil
                                      
                                      message:@"Email account is not configured in your device."
                                      
                                      delegate:self
                                      
                                      cancelButtonTitle:@"OK"
                                      
                                      otherButtonTitles:nil];
            
            [alertView show];
            
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}
#pragma mark - end

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Pickerview Delegate Methods
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (managerListArray.count != 0) {
    return 1;
    }
    else{
    return 0;
    }
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (managerListArray.count != 0) {
        if ([pickerChecker isEqualToString:@"manager"]) {
            return pickerArray.count;
        }
        else if ([pickerChecker isEqualToString:@"category"]){
            return categoryList.count;
        }
        else{
            return 1;
        }

    }
    else{
        return 0;
    }

}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (managerListArray.count != 0) {
        if ([pickerChecker isEqualToString:@"manager"]) {
            return [[pickerArray objectAtIndex:row] objectForKey:@"managerName"];
        }
        else if ([pickerChecker isEqualToString:@"category"]){
            NSString *categoryString = [pickerArray objectAtIndex:row];
            return [categoryString changeTextLanguage:categoryString];
        }
        else{
            return @"";
        }

    }
    else{
        return 0;
    }
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (managerListArray.count != 0) {
        if ([pickerChecker isEqualToString:@"manager"]) {
            managerName.text = [[pickerArray objectAtIndex:row] objectForKey:@"managerName"];
        }
        else if ([pickerChecker isEqualToString:@"category"]){
            NSString *categoryString = [pickerArray objectAtIndex:row];
            selectCategory.text = [categoryString changeTextLanguage:categoryString];
            //        [selectCategory changeTextLanguage:[categoryString changeTextLanguage:categoryString]];
        }
    }
}
#pragma mark - end

#pragma mark - Toolbar Done Action
- (IBAction)DoneAction:(UIBarButtonItem *)sender {
   
    
    if (managerListArray.count != 0) {
        
        NSInteger index = [managerListPickerView selectedRowInComponent:0];
        //    managerName.text=[pickerArray objectAtIndex:index];
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        
        if ([pickerChecker isEqualToString:@"category"]){
            selectedCategoryIndex = (int)index;
            selectedManagerIndex = 0;
            pickerChecker = @"manager";
            [pickerArray removeAllObjects];
            int managerNameIndex = 0;
            for (int i=0; i < managerListArray.count; i++) {
                if ([selectCategory.text isEqualToString:[[managerListArray objectAtIndex:i] objectForKey:@"category"]]) {
                    if (managerNameIndex == 0) {
                        managerNameIndex++;
                        selectedData = [[managerListArray objectAtIndex:i] copy];
                        managerName.text = [[managerListArray objectAtIndex:i] objectForKey:@"managerName"];
                    }
                    
                    [pickerArray addObject:[managerListArray objectAtIndex:i]];
                }
                
            }
            
            NSString *categoryString = [categoryList objectAtIndex:index];
            selectCategory.text = [categoryString changeTextLanguage:categoryString];
            //            [selectCategory changeTextLanguage:[categoryList objectAtIndex:index]];
            [managerListPickerView reloadAllComponents];
            
            //            [myDelegate ShowIndicator];
            //            [self performSelector:@selector(managerListing) withObject:nil afterDelay:.1];
        }
        else{
            selectedManagerIndex = (int)index;
            selectedData = [[pickerArray objectAtIndex:index] copy];
            managerName.text=[[pickerArray objectAtIndex:index] objectForKey:@"managerName"];
        }
    }
     [self hidePickerWithAnimation];
}
#pragma mark - end


#pragma mark - Manager Listing method
-(void)managerListing
{
    [[WebService sharedManager] managerListing:^(id responseObject) {
        NSLog(@"response is %@",responseObject);
        [myDelegate StopIndicator];
        pickerChecker = @"category";
        [managerListArray removeAllObjects];
        //        categoryList = [responseObject objectForKey:@"category_type"];
        [categoryList addObject:@"Agent"];
        [categoryList addObject:@"manager"];
        managerListArray = [responseObject objectForKey:@"managerList"];
        
        if(managerListArray.count != 0){
            selectCategory.text = [categoryList objectAtIndex:0];
            noManagerView.hidden = YES;
            selectManagerView.hidden = NO;
            for (int i=0; i < managerListArray.count; i++) {
                if ([selectCategory.text isEqualToString:[[managerListArray objectAtIndex:i] objectForKey:@"category"]]) {
                    managerName.text = [[managerListArray objectAtIndex:i] objectForKey:@"managerName"];
                    selectedData = [[managerListArray objectAtIndex:i] copy];
                    break;
                }
            }
        }
        else{
            self.mainView.translatesAutoresizingMaskIntoConstraints = YES;
            self.mainView.frame = CGRectMake(0, 0, self.view.frame.size.width,  noManagerView.frame.origin.y + noManagerView.frame.size.height + 50);
            managerName.text=@"";
            selectCategory.text = @"";
            noManagerView.hidden = NO;
            selectManagerView.hidden = YES;
        }
    } failure:^(NSError *error) {
        
    }] ;
    
}
#pragma mark - end

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
}

#pragma mark - Add Representation Action
- (IBAction)addRepresentativeAction:(UIButton *)sender {
    [self hidePickerWithAnimation];
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AddManagerViewController *addManagerView =[storyboard instantiateViewControllerWithIdentifier:@"AddManagerViewController"];
    addManagerView.navTitle = @"Add Representative";
    addManagerView.emailId = @"";
    addManagerView.name = @"";
    addManagerView.managerId = @"";
    addManagerView.category = @"";
    [self.navigationController pushViewController:addManagerView animated:YES];
}
#pragma mark - end

#pragma mark - select Manager Action
- (IBAction)selectManagerAction:(UIButton *)sender {
    [self showPickerWithAnimation];
    
    pickerChecker = @"manager";
    //    [pickerArray removeAllObjects];
    //    pickerArray = [managerListArray mutableCopy];
    [scrollView setContentOffset:CGPointMake(0, managerName.frame.origin.y + 145) animated:YES];
    if (managerListArray.count != 0) {
    [managerListPickerView selectRow:selectedManagerIndex inComponent:0 animated:NO];
    }
    //    [managerListPickerView reloadAllComponents];
}
#pragma mark - end

#pragma mark - Select category textfield
- (IBAction)selectCategoryAction:(UIButton *)sender {
    [self showPickerWithAnimation];
    
    [pickerArray removeAllObjects];
    
    pickerChecker = @"category";
    pickerArray = [categoryList mutableCopy];
    [scrollView setContentOffset:CGPointMake(0, managerName.frame.origin.y + 80) animated:YES];
    [managerListPickerView reloadAllComponents];
    if (managerListArray.count != 0) {
    [managerListPickerView selectRow:selectedCategoryIndex inComponent:0 animated:NO];
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
