//
//  VideoPreviewViewController.m
//  ActorsCam
//
//  Created by Ranosys on 02/10/15.
//  Copyright © 2015 Ranosys. All rights reserved.
//

#import "VideoPreviewViewController.h"
#import "DashboardViewController.h"
#import <MessageUI/MessageUI.h>
#import "BSKeyboardControls.h"
#import "AddManagerViewController.h"
#import "UITextField+Validations.h"
#import "UIView+Toast.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface VideoPreviewViewController ()<MFMailComposeViewControllerDelegate,BSKeyboardControlsDelegate,UIGestureRecognizerDelegate>{
    NSMutableArray *pickerArray, *managerListArray, *categoryList, *managerNameList;
    NSString *pickerChecker, *navTitle;
    NSDictionary *selectedData;
    int selectedCategoryIndex, selectedManagerIndex;
    MPMoviePlayerController *player;
    UIImage *videoImage;
    UIBarButtonItem *retakeBarButton,*refreshBarButton;
}

@property (strong, nonatomic) IBOutlet UIView *mainView;

@property (strong, nonatomic) IBOutlet UIView *videoPlayer;
@property (weak, nonatomic) IBOutlet UIImageView *intialVideoImage;
@property (weak, nonatomic) IBOutlet UIButton *playOutlet;

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

@property (strong, nonatomic) IBOutlet UIView *ipad_videoPlayer;
@property (weak, nonatomic) IBOutlet UIImageView *ipad_intialVideoImage;
@property (weak, nonatomic) IBOutlet UIButton *ipad_playOutlet;

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

@implementation VideoPreviewViewController
@synthesize scrollView,playOutlet,intialVideoImage;
@synthesize noManagerView,noManager,addRepresentative;
@synthesize selectManagerView,selectRepresentativeLabel,selectCategory,managerName,notesLabel,noteTextView,sendButton;
@synthesize managerListPickerView,toolBar,toolBarDone;
@synthesize filePath,videoPlayer;

@synthesize ipad_playOutlet,ipad_intialVideoImage;
@synthesize ipad_noManagerView,ipad_noManager,ipad_addRepresentative;
@synthesize ipad_selectManagerView,ipad_selectRepresentativeLabel,ipad_selectCategory,ipad_managerName,ipad_notesLabel,ipad_noteTextView,ipad_sendButton,ipad_videoPlayer;

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (iPad) {
        self.mainView = self.ipad_mainView;
        
        intialVideoImage = ipad_intialVideoImage;
        playOutlet = ipad_playOutlet;
        videoPlayer = ipad_videoPlayer;
        
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

    //set image at imageview during stop video time
    NSURL *videoURl = [NSURL fileURLWithPath:[filePath absoluteString]];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURl options:nil];
    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generate.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 60);
    CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
   
    UIImage *img = [[UIImage alloc] initWithCGImage:imgRef];
    [intialVideoImage setImage:img];
    videoImage = img;
    intialVideoImage.hidden = NO;
    intialVideoImage.userInteractionEnabled = YES;
//    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [intialVideoImage addGestureRecognizer:singleTap];
    
    navTitle = @"Preview";
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
    
    [playOutlet setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    playOutlet.selected = NO;
    playOutlet.hidden = NO;
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = navTitle;
    
    UIBarButtonItem *barButton;
    CGRect framing = CGRectMake(0, 0, 30, 40);
    UIButton *button = [[UIButton alloc] initWithFrame:framing];
    [button setImage:[UIImage imageNamed:@"backarrow"] forState:UIControlStateNormal];
    barButton =[[UIBarButtonItem alloc] initWithCustomView:button];
    [button addTarget:self action:@selector(backButton:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = barButton;
    
    self.navigationItem.rightBarButtonItem = nil;
    framing = CGRectMake(0, 0, 30, 30);
    UIButton *retake = [[UIButton alloc] initWithFrame:framing];
    [retake setImage:[UIImage imageNamed:@"previewCamera"] forState:UIControlStateNormal];
    retakeBarButton =[[UIBarButtonItem alloc] initWithCustomView:retake];
    [retake addTarget:self action:@selector(cameraButton:) forControlEvents:UIControlEventTouchUpInside];
    
    framing = CGRectMake(0, 0, 30, 30);
    UIButton *refresh = [[UIButton alloc] initWithFrame:framing];
    [refresh setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
    refreshBarButton =[[UIBarButtonItem alloc] initWithCustomView:refresh];
    [refresh addTarget:self action:@selector(refreshButtonAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItems=[NSArray arrayWithObjects:retakeBarButton,refreshBarButton, nil];
    
    [self performSelector:@selector(addVideo) withObject:nil afterDelay:0.1];
    
    [myDelegate ShowIndicator];
    [self performSelector:@selector(managerListing) withObject:nil afterDelay:.1];
}

-(void)refreshButtonAction{
    [myDelegate ShowIndicator];
    [self performSelector:@selector(managerListing) withObject:nil afterDelay:.1];
}

#pragma mark- Pan Gesture Selector Action

-(void)panAction:(UITapGestureRecognizer *)recognizer
{
    if(player.playbackState == MPMoviePlaybackStatePaused){
        NSLog(@"Yes Playing");
        [player play];
    }
    
    else{
        playOutlet.hidden = NO;
        intialVideoImage.image = nil;
        //        [intialVideoImage setImage:videoImage];
        [player pause];
    }
}

#pragma mark - Keyboard events

- (IBAction)playAction:(UIButton *)sender {
    playOutlet.hidden = YES;
    playOutlet.selected = YES;
    intialVideoImage.image = nil;
    [player play];
}

#pragma mark- Add Video on View
-(void)addVideo
{
    
//    NSURL *urlString = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Untitled" ofType:@"mov"]];

//    player  = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:[urlString absoluteString]]];
    player  = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:[filePath absoluteString]]];
    
    [player.view setFrame:videoPlayer.frame];
    player.controlStyle =  MPMovieControlStyleNone;
    player.shouldAutoplay=NO;
    player.repeatMode = NO;
    player.scalingMode = MPMovieScalingModeAspectFit;
    
    [videoPlayer addSubview:player.view];
    [player prepareToPlay];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MPMoviePlayerLoadStateDidChange:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MPMoviePlayerLoadStateDidChange:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    
    [player stop];
}

#pragma mark- MPMoviePlayerLoadStateDidChange Notification
- (void)MPMoviePlayerLoadStateDidChange:(NSNotification *)notification {
    
    if ((player.loadState & MPMovieLoadStatePlaythroughOK) == MPMovieLoadStatePlaythroughOK) {
            playOutlet.hidden = NO;
            [intialVideoImage setImage:videoImage];
            [player stop];
            NSLog(@"Playing OK");
    }
    NSLog(@"loadState=%lu",(unsigned long)player.loadState);
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

#pragma mark - TextView Delegate
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
    playOutlet.hidden = NO;
    [intialVideoImage setImage:videoImage];
    [player stop];

    UIAlertView *alert;
    if ([selectCategory isEmpty])
    {
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please choose a category." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }
    else if ([managerName isEmpty])
    {
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Name cannot be blank." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }
    else{
        if (managerListArray.count != 0) {
            
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[filePath absoluteString]];
            if (fileExists) {
                if ([MFMailComposeViewController canSendMail])
                    
                {
                    // Email Subject
                    
                    NSString *emailTitle = @"Actor's CAM - New Video from model";
                    
                    NSArray *toRecipents = [NSArray arrayWithObject:[selectedData objectForKey:@"managerEmail"]];
                    
                    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
                    
                    mc.mailComposeDelegate = self;
                    
                    [mc setSubject:emailTitle];
                    
                    [mc setMessageBody:noteTextView.text isHTML:NO];
                    
                    NSURL * videoURL = [[NSURL alloc] initFileURLWithPath:[filePath absoluteString]];
                    
                    [mc addAttachmentData:[NSData dataWithContentsOfURL:videoURL] mimeType:@"video/quicktime" fileName:@"ActorCamVideo.MOV"];
                    
                    mc.navigationBar.tintColor = [UIColor whiteColor];
                    //            mc.navigationBar.ti
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

#pragma mark - Pickerview Delegate Methods
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
   return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if ([pickerChecker isEqualToString:@"manager"]) {
        return pickerArray.count;
    }
    else if ([pickerChecker isEqualToString:@"category"]){
        return categoryList.count;
    }
    else{
        return 0;
    }
    
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //    if (managerListArray.count != 0) {
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
    
    //    }
    //    else{
    //        return 0;
    //    }
    
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


#pragma mark - Toolbar Done Action
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

#pragma mark - Manager Listing method
-(void)managerListing
{
    [[WebService sharedManager] managerListing:^(id responseObject) {
        NSLog(@"response is %@",responseObject);
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

#pragma mark - back/camera Button
- (IBAction)backButton:(UIButton *)sender {
    [self hidePickerWithAnimation];
    
    for (id controller in [self.navigationController viewControllers])
    {
        if ([controller isKindOfClass:[DashboardViewController class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
            break;
        }
    }
}

- (IBAction)cameraButton:(UIButton *)sender {
    [self hidePickerWithAnimation];
    
    [self.navigationController popViewControllerAnimated:YES];
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
