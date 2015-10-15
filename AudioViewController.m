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
#import "UITextField+Validations.h"
#import "UIView+Toast.h"

#import <AVFoundation/AVFoundation.h>

@interface AudioViewController ()<MFMailComposeViewControllerDelegate,BSKeyboardControlsDelegate,AVAudioRecorderDelegate, AVAudioPlayerDelegate>{
    NSMutableArray *pickerArray, *managerListArray, *categoryList, *managerNameList;
    NSString *pickerChecker, *navTitle;
    NSDictionary *selectedData;
    int selectedCategoryIndex, selectedManagerIndex;
    
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    NSTimer *myTimer;
    int second, minute, hour, continousSecond;
    
    UIBarButtonItem *retakeBarButton,*refreshBarButton;
}

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


//iPad
@property (strong, nonatomic) IBOutlet UIView *ipad_mainView;

@property (strong, nonatomic) IBOutlet UILabel *ipad_timeLabel;
@property (strong, nonatomic) IBOutlet UIButton *ipad_playOutlet;
@property (strong, nonatomic) IBOutlet UIButton *ipad_recordOulet;

@property (strong, nonatomic) IBOutlet UIView *ipad_noManagerView;
@property (weak, nonatomic) IBOutlet UILabel *ipad_noManager;
@property (strong, nonatomic) IBOutlet UIButton *ipad_addRepresentative;

@property (weak, nonatomic) IBOutlet UIView *ipad_selectManagerView;
@property (weak, nonatomic) IBOutlet UILabel *ipad_selectRepresentativeLabel;
@property (strong, nonatomic) IBOutlet UITextField *ipad_selectCategory;
@property (weak, nonatomic) IBOutlet UITextField *ipad_managerName;
@property (strong, nonatomic) IBOutlet UILabel *ipad_notesLabel;
@property (strong, nonatomic) IBOutlet UITextView *ipad_noteTextView;
@property (weak, nonatomic) IBOutlet UIButton *ipad_sendButton;

@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPickerView *managerListPickerView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *toolBarDone;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@end

@implementation AudioViewController
@synthesize scrollView;
@synthesize timeLabel,playOutlet,recordOulet;
@synthesize noManagerView,noManager,addRepresentative;
@synthesize selectManagerView,selectRepresentativeLabel,selectCategory,managerName,notesLabel,noteTextView,sendButton;

@synthesize ipad_timeLabel,ipad_playOutlet,ipad_recordOulet;
@synthesize ipad_noManagerView,ipad_noManager,ipad_addRepresentative;
@synthesize ipad_selectManagerView,ipad_selectRepresentativeLabel,ipad_selectCategory,ipad_managerName,ipad_notesLabel,ipad_noteTextView,ipad_sendButton;
@synthesize managerListPickerView,toolBar,toolBarDone;

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (iPad) {
        self.mainView = self.ipad_mainView;
        
        timeLabel = ipad_timeLabel;
        playOutlet = ipad_playOutlet;
        recordOulet = ipad_recordOulet;
        
        noManagerView = ipad_noManagerView;
        noManager = ipad_noManager;
        addRepresentative = ipad_addRepresentative;
        
        selectManagerView = ipad_selectManagerView;
        selectRepresentativeLabel = ipad_selectRepresentativeLabel;
        selectCategory = ipad_selectCategory;
        managerName = ipad_managerName;
        notesLabel = ipad_notesLabel;
        noteTextView = ipad_noteTextView;
        sendButton = ipad_sendButton;
    }

    managerListPickerView.translatesAutoresizingMaskIntoConstraints=YES;
    toolBar.translatesAutoresizingMaskIntoConstraints=YES;
    //Keyboard toolbar action to display toolbar with keyboard to move next,previous
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:@[noteTextView]]];
    [self.keyboardControls setDelegate:self];
    
    navTitle = @"Record Audio";
    
    [self recordAudioFile];
    // Do any additional setup after loading the view.
}

#pragma mark - Allocation of audio file
-(void)recordAudioFile{
    playOutlet.enabled = NO;
    sendButton.enabled = NO;
    
    second = 0;
    minute = 0;
    hour = 0;
    continousSecond = 0;
    [playOutlet setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [playOutlet setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateSelected];
    [recordOulet setImage:[UIImage imageNamed:@"record"] forState:UIControlStateNormal];
    [recordOulet setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateSelected];
    playOutlet.selected = NO;
    recordOulet.selected = NO;
    
    timeLabel.text = [NSString stringWithFormat:@"00:00:00"];
    
    //    Create Audio file in nsdocument and outputUrl of audio file
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"ActorCamAudio.m4a"];
    NSURL *outputFileURL = [NSURL URLWithString:filePath];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    //    Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    //    Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
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
    
    if (!iPad) {
        self.mainView.translatesAutoresizingMaskIntoConstraints = NO;
        self.mainView.frame = CGRectMake(0, 0, self.view.frame.size.width, 658);
    }
    
    UIView *rightPadding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 0)];
    managerName.rightView = rightPadding;
    managerName.rightViewMode = UITextFieldViewModeAlways;
    
    [managerName setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [selectCategory setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    noteTextView.layer.borderColor = [UIColor colorWithRed:190.0/255.0 green:190.0/255.0 blue:190.0/255.0 alpha:1.0].CGColor;
    noteTextView.layer.borderWidth = 1;
    
    selectManagerView.hidden = NO;
    noManagerView.hidden = YES;
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = navTitle;
    
    self.navigationItem.rightBarButtonItem = nil;
     CGRect framing = CGRectMake(0, 0, 30, 30);
    UIButton *refresh = [[UIButton alloc] initWithFrame:framing];
    [refresh setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
    refreshBarButton =[[UIBarButtonItem alloc] initWithCustomView:refresh];
    [refresh addTarget:self action:@selector(refreshButtonAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = refreshBarButton;

    
    [myDelegate ShowIndicator];
    [self performSelector:@selector(managerListing) withObject:nil afterDelay:.1];
}

-(void)refreshButtonAction{
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
    
    [navTitle changeTextLanguage:@"Record Audio"];
}
#pragma mark - end

#pragma mark - Picker view animation
-(void)showPickerWithAnimation
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
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
    
    managerListPickerView.frame = CGRectMake(managerListPickerView.frame.origin.x, 1500, self.view.frame.size.width, managerListPickerView.frame.size.height);
    toolBar.frame = CGRectMake(toolBar.frame.origin.x, 1500, self.view.frame.size.width, toolBar.frame.size.height);
    [UIView commitAnimations];
}
#pragma mark - end

#pragma mark - TextView delegate
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    [self hidePickerWithAnimation];
    
    [self.keyboardControls setActiveField:textView];
    if (iPad) {
        [scrollView setContentOffset:CGPointMake(0, textView.frame.origin.y + textView.frame.size.height) animated:YES];
    }
    else{
        [scrollView setContentOffset:CGPointMake(0, textView.frame.origin.y + textView.frame.size.height + 200) animated:YES];
    }
    
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
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

#pragma mark - Send image action
- (IBAction)sendAction:(id)sender {
    
    [myDelegate ShowIndicator];
    [self performSelector:@selector(audioAttachment) withObject:nil afterDelay:.1];
    
}

-(void)audioAttachment{
    
    [self hidePickerWithAnimation];
    [myTimer invalidate];
    myTimer = nil;
    
    playOutlet.enabled = YES;
    playOutlet.selected = NO;
    recordOulet.selected = NO;
    
    if (player.playing) {
        [player stop];
    }
    
    UIAlertView *alert;
    if ([selectCategory isEmpty])
    {
        [myDelegate StopIndicator];
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please choose a category." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }
    else if ([managerName isEmpty])
    {
        [myDelegate StopIndicator];
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Name cannot be blank." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }
    else{
        if (managerListArray.count != 0) {
            NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            NSString* filepath = [documentsPath stringByAppendingPathComponent:@"ActorCamAudio.m4a"];
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filepath];
            if (fileExists) {
                if ([MFMailComposeViewController canSendMail])
                    
                {
                    // Email Subject
                    
                    NSString *emailTitle = @"Actor CAM - New Audio from model";
                    
                    NSArray *toRecipents = [NSArray arrayWithObject:[selectedData objectForKey:@"managerEmail"]];
                    
                    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
                    
                    mc.mailComposeDelegate = self;
                    
                    [mc setSubject:emailTitle];
                    
                    [mc setMessageBody:noteTextView.text isHTML:NO];
                    
                    timeLabel.text = [NSString stringWithFormat:@"00:00:00"];
                    
                    continousSecond = 0;
                    playOutlet.selected = NO;
                    recordOulet.selected = NO;
                    
                    NSData *soundFile = [[NSData alloc] initWithContentsOfFile:filepath];
                    
                    [mc addAttachmentData:soundFile mimeType:@"audio/mp4" fileName:@"ActorCamAudio.m4a"];
                    //            }
                    
                    mc.navigationBar.tintColor = [UIColor whiteColor];
                    //            mc.navigationBar.ti
                    [mc setToRecipients:toRecipents];
                    [myDelegate StopIndicator];
                    [self presentViewController:mc animated:YES completion:NULL];
                    
                }
                
                else
                    
                {
                    [myDelegate StopIndicator];
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
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            [self.view makeToast:@"Your email was not sent."];
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}
#pragma mark - end

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Pickerview delegate methods
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
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
        return @"";
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
        }
    }
}
#pragma mark - end

#pragma mark - Toolbar done action
- (IBAction)DoneAction:(UIBarButtonItem *)sender {
    
    if (managerListArray.count != 0) {
        
        NSInteger index = [managerListPickerView selectedRowInComponent:0];
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
            [managerListPickerView reloadAllComponents];
            
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

#pragma mark - Manager listing method
-(void)managerListing
{
    [[WebService sharedManager] managerListing:^(id responseObject) {
       // NSLog(@"response is %@",responseObject);
        [myDelegate StopIndicator];
        pickerChecker = @"manager";
        [managerListArray removeAllObjects];
        categoryList = [responseObject objectForKey:@"category_type"];
        managerListArray = [responseObject objectForKey:@"managerList"];
        
        if(managerListArray.count != 0){
            selectCategory.text = [categoryList objectAtIndex:0];
            noManagerView.hidden = YES;
            selectManagerView.hidden = NO;
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
             [managerListPickerView reloadAllComponents];
        }
        else{
            if (!iPad) {
                 self.mainView.translatesAutoresizingMaskIntoConstraints = YES;
            self.mainView.frame = CGRectMake(0, 0, self.view.frame.size.width,  noManagerView.frame.origin.y + noManagerView.frame.size.height + 50);
            }
           
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

#pragma mark - Add representation action
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

#pragma mark - Select manager action
- (IBAction)selectManagerAction:(UIButton *)sender {
    [self showPickerWithAnimation];
    
    pickerChecker = @"manager";
    if (!iPad) {
        [scrollView setContentOffset:CGPointMake(0, managerName.frame.origin.y + 145) animated:YES];
    }
    
    if (managerListArray.count != 0) {
    [managerListPickerView selectRow:selectedManagerIndex inComponent:0 animated:NO];
    }
}
#pragma mark - end

#pragma mark - Select category textfield
- (IBAction)selectCategoryAction:(UIButton *)sender {
    [self showPickerWithAnimation];
    
    [pickerArray removeAllObjects];
    
    pickerChecker = @"category";
    pickerArray = [categoryList mutableCopy];
    if (!iPad) {
        [scrollView setContentOffset:CGPointMake(0, managerName.frame.origin.y + 80) animated:YES];
    }
    
    [managerListPickerView reloadAllComponents];
    if (managerListArray.count != 0) {
    [managerListPickerView selectRow:selectedCategoryIndex inComponent:0 animated:NO];
    }
    
}

#pragma mark - Play action
- (IBAction)play:(UIButton *)sender {
    
    recordOulet.selected = NO;
    
    [myTimer invalidate];
    myTimer = nil;
    
    [recorder stop];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    
    if (!playOutlet.isSelected) {
        continousSecond = 0;
        timeLabel.text = [NSString stringWithFormat:@"00:00:00"];
        
        playOutlet.selected = YES;
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
        [player setDelegate:self];
        [player play];
        myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                   target:self
                                                 selector:@selector(targetMethod)
                                                 userInfo:nil
                                                  repeats:YES];
    }
    else{
        playOutlet.selected = NO;
        [player stop];
    }
   
}
#pragma mark - end

#pragma mark - Record action
- (IBAction)record:(UIButton *)sender {
    [myTimer invalidate];
    myTimer = nil;
    
    playOutlet.enabled = YES;
    playOutlet.selected = NO;
    
    sendButton.enabled = YES;
    
    if (player.playing) {
        [player stop];
    }
    
    if (!recorder.recording) {
        recordOulet.selected = YES;
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        // Start recording
        [recorder record];
        continousSecond = 0;
        timeLabel.text = [NSString stringWithFormat:@"00:00:00"];
        myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                   target:self
                                                 selector:@selector(targetMethod)
                                                 userInfo:nil
                                                  repeats:YES];
        
    } else {
        recordOulet.selected = NO;
        
        [recorder stop];
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
        
    }
    
}
#pragma mark - end

#pragma mark - Set timer
-(void)targetMethod{
    continousSecond++;
    hour = (continousSecond / 3600)%24;
    minute = (continousSecond /60) % 60;
    second = (continousSecond  % 60);
    timeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hour,minute,second];
    
    if (recordOulet.isSelected) {
        unsigned long long size = [[NSFileManager defaultManager] attributesOfItemAtPath:[recorder.url path] error:nil].fileSize;
        if (size >= (1024*1024*20)) {
            [self.view makeToast:@"File size cannot exceed 20 MB."];
            [myTimer invalidate];
            myTimer = nil;
            [recorder stop];
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            [audioSession setActive:NO error:nil];
        }
    }

//    NSLog(@"This is the file size of the recording in bytes: %llu", size);
}
#pragma mark - end

#pragma mark - AVAudioRecorderDelegate

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    
    NSLog(@"finish");
}

#pragma mark - AVAudioPlayerDelegate

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    playOutlet.selected = NO;
    timeLabel.text = [NSString stringWithFormat:@"00:00:00"];
    [myTimer invalidate];
    myTimer = nil;
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
