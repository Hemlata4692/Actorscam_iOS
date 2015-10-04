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
    UIImagePickerController *imgPicker;
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
    imgPicker = [[UIImagePickerController alloc] init];
    
    // Do any additional setup after loading the view.
    [myDelegate ShowIndicator];
    [self performSelector:@selector(getprofile) withObject:nil afterDelay:.5];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = navTitle;
    NSLog(@"%f , %f",self.view.frame.origin.y,self.view.frame.size.height);
    [[self navigationController] setNavigationBarHidden:NO animated:YES];

}

-(void)setLocalizedString{
    
    [name changeTextLanguage:@"Name"];
    [takePhoto changeTextLanguage:takePhoto];
    [choosePhoto changeTextLanguage:choosePhoto];
    [cancel changeTextLanguage:cancel];
    [save changeTextLanguage:@"SUBMIT"];
    [navTitle changeTextLanguage:@"Edit Profile"];
    
}

-(void)addTextFieldPadding
{
    [name setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [emailId setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
}
#pragma mark - end

#pragma mark - Call getProfile web-service
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
            weakRef.contentMode = UIViewContentModeScaleAspectFit;
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
#pragma mark - end

#pragma mark - Edit profile
- (IBAction)SaveButtonAction:(id)sender
{
    [self.view endEditing:YES];
    if([self performValidationsForEditProfile])
        {
    [myDelegate ShowIndicator];
    [self performSelector:@selector(changeProfile) withObject:nil afterDelay:.1];
     }
}

-(void)changeProfile
{
    [[WebService sharedManager] updateprofile:name.text image:profileImageView.image success:^(id responseObject) {
        
        [myDelegate StopIndicator];
        NSDictionary *dict = (NSDictionary *)responseObject;
        [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"image"] forKey:@"profileImageUrl"];
        [[NSUserDefaults standardUserDefaults] setObject:name.text forKey:@"actorName"];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:[dict objectForKey:@"message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        
    } failure:^(NSError *error) {
        
    }] ;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DashboardViewController *dashboardView =[storyboard instantiateViewControllerWithIdentifier:@"DashboardView"];
    
    [self.navigationController pushViewController:dashboardView animated:YES];
}
#pragma mark - end

#pragma mark - Image Picker Action
- (IBAction)imagePickerAction:(id)sender
{
    UIActionSheet * share=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:cancel destructiveButtonTitle:nil otherButtonTitles:takePhoto,choosePhoto, nil];
    
    if ([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
        
        [share showFromRect:CGRectMake(profileImageView.frame.origin.x, profileImageView.frame.origin.y+154, 320, 120) inView:self.view animated:YES];
    }
    else{
        // In this case the device is an iPhone/iPod Touch.
        [share showInView:[UIApplication sharedApplication].keyWindow];
    }
}
#pragma mark - end

#pragma mark - imagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)info
{
    profileImageView.image = image;
    [imgPicker dismissViewControllerAnimated:YES completion:NULL];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
}

#pragma mark - end

#pragma mark - Actionsheet delegate
//Action sheet for setting image from camera or gallery
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==0)
    {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                  message:@"Device has no camera."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil];
            
            [myAlertView show];
            
        }
        else
        {
            //Setting image from camera
            [imgPicker setAllowsEditing:YES];
            imgPicker = [[UIImagePickerController alloc] init];
            imgPicker.delegate = self;
            imgPicker.allowsEditing = YES;
            imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
            [self presentViewController:imgPicker animated:YES completion:NULL];
        }
    }
    else if(buttonIndex==1)
    {
        //Setting image from gallery
        imgPicker.delegate = self;
        imgPicker.allowsEditing = YES;
        imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imgPicker.navigationBar.tintColor = [UIColor whiteColor];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            self.popover = [[UIPopoverController alloc] initWithContentViewController:imgPicker];
            self.popover.delegate = self;
            
            [self.popover presentPopoverFromRect:CGRectMake(600, 400, 311, 350) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
            [self.popover setPopoverContentSize:CGSizeMake(330, 515)];
            
        }
        else
        {
            [self presentViewController:imgPicker animated:YES completion:NULL];
        }
        
    }
    
}
#pragma mark - end

#pragma mark - Textfield Validation
- (BOOL)performValidationsForEditProfile
{
    UIAlertView *alert;
    UIImage* placeholderImage = [UIImage imageNamed:@"sideBarPlaceholder"];
    NSData *placeholderImageData = UIImagePNGRepresentation(placeholderImage);
    NSData *profileImageData = UIImagePNGRepresentation(profileImageView.image);
    
    if ([profileImageData isEqualToData:placeholderImageData])
    {
        
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please upload an image." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }

    else if ([name isEmpty])
    {
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Name cannot be blank." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
     else{
        return YES;
     }
    
}
#pragma mark - end

#pragma mark - Textfield Delegates
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
    if (textField.text.length >= MAX_LENGTH && range.length == 0)
    {
        return NO; // return NO to not change text
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
