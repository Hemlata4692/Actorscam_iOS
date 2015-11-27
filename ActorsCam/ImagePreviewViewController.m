//
//  ImagePreviewViewController.m
//  ActorsCam
//
//  Created by Ranosys on 24/08/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "ImagePreviewViewController.h"
#import "DashboardViewController.h"
#import <MessageUI/MessageUI.h>
#import "BSKeyboardControls.h"
#import "UITextField+Validations.h"
#import "AddManagerViewController.h"

#import "UIView+Toast.h"

#define kCellsPerRow 3

@interface ImagePreviewViewController ()<MFMailComposeViewControllerDelegate,BSKeyboardControlsDelegate>{
    NSMutableArray *pickerArray, *managerListArray, *categoryList, *managerNameList;
    int selectedImage, selectedCategoryIndex, selectedManagerIndex;
    NSString *pickerChecker, *navTitle;
    NSDictionary *selectedData;
    UIBarButtonItem *retakeBarButton,*refreshBarButton;
    BOOL reloadDataChecker;
}

@property (strong, nonatomic) IBOutlet UIView *mainView;

@property (weak, nonatomic) IBOutlet UIImageView *imagePreviewView;
@property (weak, nonatomic) IBOutlet UICollectionView *previewCollectionView;

@property (strong, nonatomic) IBOutlet UIView *noManagerView;
@property (weak, nonatomic) IBOutlet UILabel *noManager;
@property (strong, nonatomic) IBOutlet UIButton *addRepresentative;

@property (weak, nonatomic) IBOutlet UIView *selectManagerView;
@property (weak, nonatomic) IBOutlet UILabel *selectRepresentativeLabel;
@property (strong, nonatomic) IBOutlet UITextField *selectCategory;
@property (weak, nonatomic) IBOutlet UITextField *managerName;
@property (strong, nonatomic) IBOutlet UILabel *notesLabel;
@property (strong, nonatomic) IBOutlet UITextView *noteTextView;
@property (weak, nonatomic) IBOutlet UIButton *sendImageButton;


//iPad
@property (strong, nonatomic) IBOutlet UIView *ipad_mainView;

@property (weak, nonatomic) IBOutlet UIImageView *ipad_imagePreviewView;
@property (weak, nonatomic) IBOutlet UICollectionView *ipad_previewCollectionView;

@property (strong, nonatomic) IBOutlet UIView *ipad_noManagerView;
@property (weak, nonatomic) IBOutlet UILabel *ipad_noManager;
@property (strong, nonatomic) IBOutlet UIButton *ipad_addRepresentative;

@property (weak, nonatomic) IBOutlet UIView *ipad_selectManagerView;
@property (weak, nonatomic) IBOutlet UILabel *ipad_selectRepresentativeLabel;
@property (strong, nonatomic) IBOutlet UITextField *ipad_selectCategory;
@property (weak, nonatomic) IBOutlet UITextField *ipad_managerName;
@property (strong, nonatomic) IBOutlet UILabel *ipad_notesLabel;
@property (strong, nonatomic) IBOutlet UITextView *ipad_noteTextView;
@property (weak, nonatomic) IBOutlet UIButton *ipad_sendImageButton;


@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPickerView *managerListPickerView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *toolBarDone;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@end

@implementation ImagePreviewViewController

@synthesize scrollView,imagePreviewView,previewCollectionView;
@synthesize noManagerView,noManager,addRepresentative;
@synthesize selectManagerView,selectRepresentativeLabel,selectCategory,managerName,notesLabel,noteTextView,sendImageButton;
@synthesize managerListPickerView,toolBar,toolBarDone;

@synthesize imageArray,customCameraVC;

@synthesize ipad_imagePreviewView,ipad_previewCollectionView;
@synthesize ipad_noManagerView,ipad_noManager,ipad_addRepresentative;
@synthesize ipad_selectManagerView,ipad_selectRepresentativeLabel,ipad_selectCategory,ipad_managerName,ipad_notesLabel,ipad_noteTextView,ipad_sendImageButton;

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (iPad) {
        self.mainView = self.ipad_mainView;
        
        imagePreviewView = ipad_imagePreviewView;
        previewCollectionView = ipad_previewCollectionView;
        
        noManagerView = ipad_noManagerView;
        noManager = ipad_noManager;
        addRepresentative = ipad_addRepresentative;
        
        selectManagerView = ipad_selectManagerView;
        selectRepresentativeLabel = ipad_selectRepresentativeLabel;
        selectCategory = ipad_selectCategory;
        managerName = ipad_managerName;
        notesLabel = ipad_notesLabel;
        noteTextView = ipad_noteTextView;
        sendImageButton = ipad_sendImageButton;
    }

    reloadDataChecker = NO;
    managerListPickerView.translatesAutoresizingMaskIntoConstraints=YES;
    toolBar.translatesAutoresizingMaskIntoConstraints=YES;
    //Keyboard toolbar action to display toolbar with keyboard to move next,previous
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:@[noteTextView]]];
    [self.keyboardControls setDelegate:self];
    
    navTitle = @"Preview";
    imagePreviewView.userInteractionEnabled = YES;
    
    if (!iPad) {
        UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)self.previewCollectionView.collectionViewLayout;
        CGFloat availableWidthForCells = CGRectGetWidth(self.view.frame) - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing * (kCellsPerRow -1)-5;
        CGFloat cellWidth = (availableWidthForCells / kCellsPerRow);
        flowLayout.itemSize = CGSizeMake(cellWidth, flowLayout.itemSize.height);

    }
    
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRecognizer:)];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRecognizer:)];
    
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    // Adding the swipe gesture on image view
    [imagePreviewView addGestureRecognizer:swipeLeft];
    [imagePreviewView addGestureRecognizer:swipeRight];
    
    [self setLocalizedString];
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
    
    selectedImage = 0;
    imagePreviewView.image = [imageArray objectAtIndex:selectedImage];
    
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
    noteTextView.layer.borderColor = [UIColor colorWithRed:190.0/255.0 green:190.0/255.0 blue:190.0/255.0 alpha:1.0].CGColor;
    noteTextView.layer.borderWidth = 1;
    
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
    
    [myDelegate ShowIndicator];
    [self performSelector:@selector(managerListing) withObject:nil afterDelay:.1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    customCameraVC.imageArray = [imageArray mutableCopy];
}

-(void)setLocalizedString{
    [noManager changeTextLanguage:@"You don't have any representative added yet!"];
    [addRepresentative changeTextLanguage:@"ADD REPRESENTATIVE"];
    
    [selectRepresentativeLabel changeTextLanguage:@"Select Representative"];
    [selectCategory changeTextLanguage:@"Category"];
    [managerName changeTextLanguage:@"Name"];
    [notesLabel changeTextLanguage:@"Notes"];
    [sendImageButton changeTextLanguage:@"SUBMIT"];
    
    [toolBarDone changeTextLanguage:@"Done"];
    navTitle = [navTitle changeTextLanguage:@"Preview"];
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

#pragma mark - Collection view
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return imageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView1 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *myCell = [collectionView1
                                    dequeueReusableCellWithReuseIdentifier:@"myCell"
                                    forIndexPath:indexPath];
    UIImageView *image;
    if(collectionView1 == ipad_previewCollectionView){
        image = (UIImageView*)[myCell viewWithTag:1];
        if ((indexPath.row == 3) && (image !=nil) ) {
            reloadDataChecker = NO;
        }
    }
    else{
        image = (UIImageView*)[myCell viewWithTag:1];
    }
    image.image = [imageArray objectAtIndex:indexPath.row];
    if (selectedImage == indexPath.row) {
        image.layer.borderColor = [UIColor colorWithRed:253.0/255.0 green:138.0/255.0 blue:43.0/255.0 alpha:1.0].CGColor;
        image.layer.borderWidth = 2;
    }
    else{
        image.layer.borderColor = [UIColor clearColor].CGColor;
        image.layer.borderWidth = 2;
    }
    return myCell;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
   
    if (iPad) {
        if (reloadDataChecker) {
             NSLog(@"checker");
            [previewCollectionView reloadData];
        }
        
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView1
{
    if ((scrollView1.contentOffset.x > 2) && iPad) {
        reloadDataChecker = NO;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIImageView *image = (UIImageView*)[cell viewWithTag:1];
    image.layer.borderColor = [UIColor colorWithRed:253.0/255.0 green:138.0/255.0 blue:43.0/255.0 alpha:1.0].CGColor;
    image.layer.borderWidth = 2;
    selectedImage = (int)indexPath.row;
     imagePreviewView.image = [imageArray objectAtIndex:selectedImage];;
    for (int i=0; i<imageArray.count; i++) {
        if (i!=indexPath.row) {
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
            UICollectionViewCell *cell1 = [collectionView cellForItemAtIndexPath:newIndexPath];
            UIImageView *image = (UIImageView*)[cell1 viewWithTag:1];
            image.layer.borderColor = [UIColor clearColor].CGColor;
            image.layer.borderWidth = 2;
        }
    }
    
}
#pragma mark - end

#pragma mark - View IB actions
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
    self.customCameraVC.imageArray = [imageArray mutableCopy];
    [self.navigationController popViewControllerAnimated:YES];
}

//Select manager drop-down
- (IBAction)selectManagerAction:(UIButton *)sender {
    [self showPickerWithAnimation];
    
    pickerChecker = @"manager";
    if (!iPad) {
        [scrollView setContentOffset:CGPointMake(0, managerName.frame.origin.y + 145) animated:YES];
    }
    
    [managerListPickerView selectRow:selectedManagerIndex inComponent:0 animated:NO];
}

//Select category drop-down
- (IBAction)selectCategoryAction:(UIButton *)sender {
    [self showPickerWithAnimation];
    
    [pickerArray removeAllObjects];
    
    pickerChecker = @"category";
    pickerArray = [categoryList mutableCopy];
    if (!iPad) {
        [scrollView setContentOffset:CGPointMake(0, managerName.frame.origin.y + 80) animated:YES];
    }
    [managerListPickerView reloadAllComponents];
    [managerListPickerView selectRow:selectedCategoryIndex inComponent:0 animated:NO];
}

-(void)refreshButtonAction{
    [myDelegate ShowIndicator];
    [self performSelector:@selector(managerListing) withObject:nil afterDelay:.1];
}

- (IBAction)doneAction:(UIBarButtonItem *)sender {
    [self hidePickerWithAnimation];
    
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
                if ([selectCategory.text isEqualToString:[[NSString stringWithFormat:@"%@",[[managerListArray objectAtIndex:i] objectForKey:@"category"]] changeTextLanguage:[NSString stringWithFormat:@"%@",[[managerListArray objectAtIndex:i] objectForKey:@"category"]]]]) {
                    

                    if (managerNameIndex == 0) {
                        managerNameIndex++;
                        selectedData = [[managerListArray objectAtIndex:i] copy];
                        managerName.text = [[managerListArray objectAtIndex:i] objectForKey:@"managerName"];
                    }
                    
//                    [pickerArray addObject:[managerListArray objectAtIndex:i]];
                }
                [pickerArray addObject:[managerListArray objectAtIndex:i]];

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
}

- (IBAction)deleteImageAction:(UIButton *)sender {
    [self hidePickerWithAnimation];
    [imageArray removeObjectAtIndex:selectedImage];
    selectedImage = 0;
    if (imageArray.count!=0) {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:selectedImage inSection:0];
        [self.previewCollectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
        imagePreviewView.image = [imageArray objectAtIndex:selectedImage];;
        [previewCollectionView reloadData];
    }
    else{
        self.customCameraVC.imageArray = [imageArray mutableCopy];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (IBAction)sendImageButtonAction:(id)sender {
    
    [myDelegate ShowIndicator];
    [self performSelector:@selector(imageAttachment) withObject:nil afterDelay:.1];
    
}

-(void)imageAttachment{
    [self hidePickerWithAnimation];
    UIAlertView *alert;
    if ([selectCategory isEmpty])
    {
        [myDelegate StopIndicator];
        alert = [[UIAlertView alloc]initWithTitle:[@"Alert" changeTextLanguage:@"Alert"] message:[@"Please choose a category." changeTextLanguage:@"Please choose a category."] delegate:self cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"] otherButtonTitles:nil, nil];
        [alert show];
        
    }
    else if ([managerName isEmpty])
    {
        [myDelegate StopIndicator];
        alert = [[UIAlertView alloc]initWithTitle:[@"Alert" changeTextLanguage:@"Alert"] message:[@"Name cannot be blank." changeTextLanguage:@"Name cannot be blank."] delegate:self cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"] otherButtonTitles:nil, nil];
        [alert show];
        
    }
    else{
        if (managerListArray.count != 0) {
            if ([MFMailComposeViewController canSendMail])
                
            {
                // Email Subject
                
                NSString *emailTitle = [@"Actor CAM - New Images from model" changeTextLanguage:@"Actor CAM - New Images from model"];
                
                NSArray *toRecipents = [NSArray arrayWithObject:[selectedData objectForKey:@"managerEmail"]];
                
                MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
                
                mc.mailComposeDelegate = self;
                
                [mc setSubject:emailTitle];
                
                [mc setMessageBody:noteTextView.text isHTML:NO];
                
                for (UIImage *yourImage in imageArray )
                    
                {
                    NSData *imgData;
                    if([[UIScreen mainScreen] bounds].size.height < 490) {
                        imgData = UIImageJPEGRepresentation(yourImage, 0.9f);
                    }
                    else{
                        imgData = UIImageJPEGRepresentation(yourImage, 1.00f);
                    }
                    
                    [mc addAttachmentData:imgData mimeType:@"image/jpeg" fileName:@"ActorImages.jpeg"];
                    
                }
                
                mc.navigationBar.tintColor = [UIColor whiteColor];
                [mc setToRecipients:toRecipents];
                [myDelegate StopIndicator];
                [self presentViewController:mc animated:YES completion:NULL];
                
            }
            
            else
                
            {
                [myDelegate StopIndicator];
                UIAlertView *alertView = [[UIAlertView alloc]
                                          
                                          initWithTitle:[@"Alert" changeTextLanguage:@"Alert"]
                                          
                                          message:[@"Email account is not configured in your device." changeTextLanguage:@"Email account is not configured in your device."]
                                          
                                          delegate:self
                                          
                                          cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"]
                                          
                                          otherButtonTitles:nil];
                
                [alertView show];
                
            }
        }
    }
}

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

#pragma mark - MFMailComposeViewController delegate
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

#pragma mark - UISwipeGesture handler
- (void)addAnimationPresentToView:(UIView *)viewTobeAnimated
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.30;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [transition setValue:@"IntroSwipeIn" forKey:@"IntroAnimation"];
    transition.fillMode=kCAFillModeForwards;
    transition.type = kCATransitionPush;
    transition.subtype =kCATransitionFromRight;
    [viewTobeAnimated.layer addAnimation:transition forKey:nil];
    
}

- (void)addAnimationPresentToViewOut:(UIView *)viewTobeAnimated
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.30;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [transition setValue:@"IntroSwipeIn" forKey:@"IntroAnimation"];
    transition.fillMode=kCAFillModeForwards;
    transition.type = kCATransitionPush;
    transition.subtype =kCATransitionFromLeft;
    [viewTobeAnimated.layer addAnimation:transition forKey:nil];
    
}

- (void)swipeRecognizer:(UISwipeGestureRecognizer *)sender {
    if(sender.direction==UISwipeGestureRecognizerDirectionLeft){
        NSLog(@"right");
        
        selectedImage++;
        if(selectedImage<imageArray.count){
            
            BOOL flag = NO;
            for (UICollectionViewCell *cell in [self.previewCollectionView visibleCells]) {
                NSIndexPath *indexPath = [self.previewCollectionView indexPathForCell:cell];
                if (indexPath.row != selectedImage) {
                    flag = YES;
                }
                else{
                    flag = NO;
                    break;
                }
                NSLog(@"%@",indexPath);
            }
            
            if (flag) {
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:selectedImage inSection:0];
                [self.previewCollectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
            }

            UIImageView *moveIMageView = imagePreviewView;
            [self addAnimationPresentToView:moveIMageView];
            imagePreviewView.image = [imageArray objectAtIndex:selectedImage];;
            [self.previewCollectionView reloadData];
        }
        else{
            selectedImage = (int)imageArray.count-1;
        }
    }
    else{
        NSLog(@"left");
        selectedImage--;
        if(selectedImage>=0){
            
            BOOL flag = NO;
            for (UICollectionViewCell *cell in [self.previewCollectionView visibleCells]) {
                NSIndexPath *indexPath = [self.previewCollectionView indexPathForCell:cell];
                if (indexPath.row != selectedImage) {
                    flag = YES;
                }
                else{
                    flag = NO;
                    break;
                }
                NSLog(@"%@",indexPath);
            }
            
            if (flag) {
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:selectedImage inSection:0];
                [self.previewCollectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
            }
            
            UIImageView *moveIMageView = imagePreviewView;
            [self addAnimationPresentToViewOut:moveIMageView];
            imagePreviewView.image = [imageArray objectAtIndex:selectedImage];;
            [self.previewCollectionView reloadData];
        }
        else{
            selectedImage=0;
        }
        
    }
    
}
#pragma mark - end

#pragma mark - Pickerview delegate methods
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
        return 1;
    }
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
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

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([pickerChecker isEqualToString:@"manager"]) {
         managerName.text = [[pickerArray objectAtIndex:row] objectForKey:@"managerName"];
    }
    else if ([pickerChecker isEqualToString:@"category"]){
        NSString *categoryString = [pickerArray objectAtIndex:row];
        selectCategory.text = [categoryString changeTextLanguage:categoryString];
    }
}
#pragma mark - end

#pragma mark - Manager listing web-service
-(void)managerListing
{
    [[WebService sharedManager] managerListing:^(id responseObject) {
      //  NSLog(@"response is %@",responseObject);
        [myDelegate StopIndicator];
        pickerChecker = @"manager";
        [managerListArray removeAllObjects];
        categoryList = [responseObject objectForKey:@"category_type"];
        managerListArray = [responseObject objectForKey:@"managerList"];
       
        if(managerListArray.count != 0){
//            selectCategory.text = [categoryList objectAtIndex:0];
            selectCategory.text = [[NSString stringWithFormat:@"%@",[categoryList objectAtIndex:0]] changeTextLanguage:[NSString stringWithFormat:@"%@",[categoryList objectAtIndex:0]]];
            
            noManagerView.hidden = YES;
            selectManagerView.hidden = NO;
            
            int managerNameIndex = 0;
            for (int i=0; i < managerListArray.count; i++) {
                 if ([selectCategory.text isEqualToString:[[NSString stringWithFormat:@"%@",[[managerListArray objectAtIndex:i] objectForKey:@"category"]] changeTextLanguage:[NSString stringWithFormat:@"%@",[[managerListArray objectAtIndex:i] objectForKey:@"category"]]]]) {
                    
                    if (managerNameIndex == 0) {
                        managerNameIndex++;
                        selectedData = [[managerListArray objectAtIndex:i] copy];
                        managerName.text = [[managerListArray objectAtIndex:i] objectForKey:@"managerName"];
                    }
                    
//                    [pickerArray addObject:[managerListArray objectAtIndex:i]];
                }
                [pickerArray addObject:[managerListArray objectAtIndex:i]];
            }
            
            [managerListPickerView reloadAllComponents];
        }
        else{
            if (!iPad) {
                 self.mainView.translatesAutoresizingMaskIntoConstraints = YES;
            self.mainView.frame = CGRectMake(0, 0,self.view.frame.size.width, noManagerView.frame.origin.y + noManagerView.frame.size.height + 50);
            }
           
            managerName.text=@"";
            selectCategory.text = @"";
            noManagerView.hidden = NO;
            selectManagerView.hidden = YES;
        }
        [self.previewCollectionView reloadData];
         reloadDataChecker = YES;
    } failure:^(NSError *error) {
        [self.previewCollectionView reloadData];
         reloadDataChecker = YES;
    }] ;
    
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
