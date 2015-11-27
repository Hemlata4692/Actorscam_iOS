//
//  EditProfileViewController.m
//  ActorsCam
//
//  Created by Hema on 19/08/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "EditProfileViewController.h"
#import "UITextField+Padding.h"
#import "UITextField+Validations.h"
#import "BSKeyboardControls.h"
#import "WebService.h"
#import <UIImageView+AFNetworking.h>
#import "DashboardViewController.h"

@interface EditProfileViewController ()<BSKeyboardControlsDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverControllerDelegate>
{
//    NSArray *textFieldArray;
    NSString *takePhoto, *choosePhoto, *cancel, *navTitle;
}
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UIButton *save;
@property (weak, nonatomic) IBOutlet UITextField *emailId;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

//iPad
@property (weak, nonatomic) IBOutlet UITextField *ipad_name;
@property (weak, nonatomic) IBOutlet UIButton *ipad_save;
@property (weak, nonatomic) IBOutlet UITextField *ipad_emailId;
@property (weak, nonatomic) IBOutlet UIImageView *ipad_profileImageView;

@property (nonatomic, strong) UIPopoverController *popover;

@end

@implementation EditProfileViewController
@synthesize name,profileImageView,emailId,save;
@synthesize popover;

@synthesize ipad_name,ipad_profileImageView,ipad_emailId,ipad_save;

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (iPad) {
        
        name = ipad_name;
        save = ipad_save;
        emailId = ipad_emailId;
        ipad_profileImageView.frame = CGRectMake(ipad_profileImageView.frame.origin.x, ipad_profileImageView.frame.origin.y, 200, 200);
        profileImageView = ipad_profileImageView;
        
    }
    
    profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2;
    profileImageView.clipsToBounds = YES;
    
    takePhoto = @"Take Photo";
    choosePhoto = @"Choose Existing Photo";
    cancel = @"Cancel";
    navTitle = @"Edit Profile";
    
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers)
    {
        [self.view removeGestureRecognizer:recognizer];
    }
    [self addTextFieldPadding];
    
    [self setLocalizedString];
    // Do any additional setup after loading the view.
    [myDelegate ShowIndicator];
    [self performSelector:@selector(getprofile) withObject:nil afterDelay:.5];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = navTitle;
    [[self navigationController] setNavigationBarHidden:NO animated:YES];

}

-(void)setLocalizedString{
    
    [name changeTextLanguage:@"Name"];
    [emailId changeTextLanguage:@"Email address"];
    takePhoto = [takePhoto changeTextLanguage:takePhoto];
    choosePhoto = [choosePhoto changeTextLanguage:choosePhoto];
    cancel = [cancel changeTextLanguage:cancel];
    [save changeTextLanguage:@"SUBMIT"];
    navTitle = [navTitle changeTextLanguage:@"Edit Profile"];
    
}

-(void)addTextFieldPadding
{
    [name setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [emailId setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
}
#pragma mark - end

#pragma mark - Web-services
-(void)getprofile
{
    [[WebService sharedManager] getprofile:^(id responseObject) {
        [myDelegate StopIndicator];
        NSDictionary *dict = (NSDictionary *)responseObject;
        
        name.text = [dict objectForKey:@"username"];
        emailId.text = [dict objectForKey:@"email"];
        __weak UIImageView *weakRef = profileImageView;
        NSString *tempImageString = [dict objectForKey:@"profileImageUrl"];
        
        NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:tempImageString]
                                                      cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                  timeoutInterval:60];
        
        [profileImageView setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"sideBarPlaceholder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            weakRef.contentMode = UIViewContentModeScaleAspectFill;
            weakRef.clipsToBounds = YES;
            weakRef.image = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            
        }];

    } failure:^(NSError *error) {

        name.text =[[NSUserDefaults standardUserDefaults]objectForKey:@"actorName"];
        emailId.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"EmailId"];
        [[NSUserDefaults standardUserDefaults] synchronize];

    }] ;

}

-(void)changeProfile
{
    [[WebService sharedManager] updateprofile:name.text image:profileImageView.image success:^(id responseObject) {
        
        [myDelegate StopIndicator];
        NSDictionary *dict = (NSDictionary *)responseObject;
        [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"image"] forKey:@"profileImageUrl"];
        [[NSUserDefaults standardUserDefaults] setObject:name.text forKey:@"actorName"];
        NSString* msg = [dict objectForKey:@"message"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[@"Success" changeTextLanguage:@"Success"] message:[msg changeTextLanguage:@"Your profile is updated successfully."] delegate:self cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"] otherButtonTitles:nil, nil];
        alert.tag = 2;
        [alert show];
        
    } failure:^(NSError *error) {
        
    }] ;
}
#pragma mark - end

#pragma mark - View IB actions
- (IBAction)SaveButtonAction:(id)sender
{
    [self.view endEditing:YES];
    if([self performValidationsForEditProfile])
        {
    [myDelegate ShowIndicator];
    [self performSelector:@selector(changeProfile) withObject:nil afterDelay:.1];
     }
}

- (IBAction)imagePickerAction:(id)sender
{
    UIActionSheet * profileImageAction=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:cancel destructiveButtonTitle:nil otherButtonTitles:takePhoto, choosePhoto, nil];
    
    if ([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
        
        [profileImageAction showFromRect:CGRectMake(profileImageView.frame.origin.x-60, profileImageView.frame.origin.y + 82, 320, 120) inView:self.view animated:YES];
    }
    else{
        // In this case the device is an iPhone/iPod Touch.
        [profileImageAction showInView:[UIApplication sharedApplication].keyWindow];
    }
}
#pragma mark - end

#pragma mark - UIAlertView delegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 2) {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DashboardViewController *dashboardView =[storyboard instantiateViewControllerWithIdentifier:@"DashboardView"];
    
    [self.navigationController pushViewController:dashboardView animated:YES];
    }
}
#pragma mark - end

#pragma mark - ImagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)info
{
    profileImageView.image = image;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
}

#pragma mark - end

#pragma mark - Actionsheet delegate
//Action sheet for setting image from camera or gallery
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != 2) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.navigationBar.tintColor = [UIColor whiteColor];
            [imagePickerController setAllowsEditing:YES];
            if (buttonIndex==1) {
                imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
            else{
                imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            }
            imagePickerController.delegate = (id)self;
            
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
            [self presentViewController:imagePickerController animated:YES completion:nil];
            
        }
        
        else  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            UIImagePickerController *pickerImg = [[UIImagePickerController alloc] init];
            if (buttonIndex==1) {
                pickerImg.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                pickerImg.delegate = (id)self;
                pickerImg.navigationBar.tintColor = [UIColor whiteColor];
                pickerImg.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
                popover = [[UIPopoverController alloc] initWithContentViewController:pickerImg];
                popover.delegate = self;
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    // Place image picker on the screen
                    [self.popover presentPopoverFromRect:CGRectMake(50,-430, 668, 668) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:NO]; [self.popover setPopoverContentSize:CGSizeMake(668,668)];
                }];
                
            }
            else {
                if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])  {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[@"Error" changeTextLanguage:@"Error"] message:[@"Device has no camera." changeTextLanguage:@"Device has no camera."] delegate:self cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"] otherButtonTitles:nil];
                    [alert show];
                }
                else{
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        // Place image picker on the screen
                        pickerImg.delegate = self;
                        pickerImg.sourceType=UIImagePickerControllerSourceTypeCamera;
                        [self presentViewController:pickerImg animated:YES completion:NULL];
                    }];
                    
                }
            }
        }
    }
}
#pragma mark - end

#pragma mark - Email validation
- (BOOL)performValidationsForEditProfile
{
    UIAlertView *alert;
    UIImage* placeholderImage = [UIImage imageNamed:@"sideBarPlaceholder"];
    NSData *placeholderImageData = UIImagePNGRepresentation(placeholderImage);
    NSData *profileImageData = UIImagePNGRepresentation(profileImageView.image);
    
    if ([profileImageData isEqualToData:placeholderImageData])
    {
        
        alert = [[UIAlertView alloc]initWithTitle:[@"Alert" changeTextLanguage:@"Alert"] message:[@"Please upload an image." changeTextLanguage:@"Please upload an image."] delegate:self cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"] otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }

    else if ([name isEmpty])
    {
        alert = [[UIAlertView alloc]initWithTitle:[@"Alert" changeTextLanguage:@"Alert"] message:[@"Name cannot be blank." changeTextLanguage:@"Name cannot be blank."] delegate:self cancelButtonTitle:[@"OK" changeTextLanguage:@"OK"] otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
     else{
        return YES;
     }
    
}
#pragma mark - end

#pragma mark - Textfield delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (!iPad) {
    if([[UIScreen mainScreen] bounds].size.height < 490)
    {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame=CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-38, self.view.frame.size.width, self.view.frame.size.height);
        }];

    }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == name) {
        if (textField.text.length >= MAX_LENGTH && range.length == 0)
        {
            return NO; // return NO to not change text
        }
        else
        {
            return YES;
        }
    }
    else
    {
        return YES;
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (!iPad) {
        if([[UIScreen mainScreen] bounds].size.height < 490)
        {
            [UIView animateWithDuration:0.3 animations:^{
                self.view.frame=CGRectMake(self.view.frame.origin.x, 64, self.view.frame.size.width, self.view.frame.size.height);
            }];
            
        }
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - end
@end
