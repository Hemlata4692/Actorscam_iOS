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
}
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UIButton *save;
@property (weak, nonatomic) IBOutlet UITextField *emailId;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
//@property (nonatomic, strong) UIPopoverController *popover;

@end

@implementation EditProfileViewController
@synthesize name,profileImageView,emailId;
//@synthesize popover;

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    //Remove swipe gesture for sidebar
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers)
    {
        [self.view removeGestureRecognizer:recognizer];
    }
    [self addTextFieldPadding];
    imgPicker = [[UIImagePickerController alloc] init];
    
    // Do any additional setup after loading the view.
    [myDelegate ShowIndicator];
    [self performSelector:@selector(getprofile) withObject:nil afterDelay:.1];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
  
}

-(void)addTextFieldPadding
{
    [name addTextFieldPadding:name];
    [emailId addTextFieldPadding:emailId];
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
        
        [profileImageView setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"picture"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            weakRef.contentMode = UIViewContentModeScaleAspectFit;
            weakRef.clipsToBounds = YES;
            weakRef.image = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            
        }];

    } failure:^(NSError *error) {

    }] ;

}
#pragma mark - end

#pragma mark - Submit Button Actions and call edit profile web-service
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
//
#pragma mark - Image Picker Action
- (IBAction)imagePickerAction:(id)sender
{
    UIActionSheet * share=[[UIActionSheet alloc]initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo",@"Choose Existing Photo", nil];
    
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

#pragma mark - Actionsheet
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
//        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//        {
//            self.popover = [[UIPopoverController alloc] initWithContentViewController:imgPicker];
//            self.popover.delegate = self;
//            
//            [self.popover presentPopoverFromRect:CGRectMake(600, 400, 311, 350) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
//            [self.popover setPopoverContentSize:CGSizeMake(330, 515)];
//            
//        }
//        else
//        {
            [self presentViewController:imgPicker animated:YES completion:NULL];
//        }
        
    }
    
}
#pragma mark - end

#pragma mark - Textfield Validation Action
- (BOOL)performValidationsForEditProfile
{
    UIAlertView *alert;
    if ([name isEmpty])
    {
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Fields cannot be blank." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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

}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - end
@end
