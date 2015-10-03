//
//  DashboardViewController.m
//  ActorsCam
//
//  Created by Hema on 19/08/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "DashboardViewController.h"
#import "SWRevealViewController.h"
#import "ChooseLanguageViewController.h"
#import "AddManagerViewController.h"
#import "ImagePreviewViewController.h"
#import "AudioViewController.h"
#import "CustomCameraViewController.h"
#import "SWRevealViewController.h"
#import "CustomVideoViewController.h"

@interface DashboardViewController ()<SWRevealViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *menuBar;
@property (weak, nonatomic) IBOutlet UIButton *chooseLanguage;
@property (strong, nonatomic) IBOutlet UILabel *takePhoto;
@property (strong, nonatomic) IBOutlet UILabel *recordAudio;
@property (strong, nonatomic) IBOutlet UILabel *addRepresentative;
@property (strong, nonatomic) IBOutlet UILabel *recordVideo;

@end

@implementation DashboardViewController
@synthesize menuBar, chooseLanguage, takePhoto, recordAudio, recordVideo, addRepresentative;
#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    //Remove swipe gesture for sidebar
    SWRevealViewController *revealController = [self revealViewController];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController)
    {
        [menuBar addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }

    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers)
    {
        [self.view removeGestureRecognizer:recognizer];
    }
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    chooseLanguage.layer.cornerRadius = 17.0;
    chooseLanguage.layer.borderColor = [UIColor whiteColor].CGColor;
    chooseLanguage.layer.borderWidth = 2;
    
    [self setLocalizedString];

    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
}

-(void)setLocalizedString{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"Language"] isEqualToString:@"en"]) {
        [chooseLanguage setTitle:@"Eng" forState:UIControlStateNormal];
    }
    else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"Language"] isEqualToString:@"fr"]) {
        [chooseLanguage setTitle:@"Fra" forState:UIControlStateNormal];
    }
    else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"Language"] isEqualToString:@"zn"]) {
        [chooseLanguage setTitle:@"Deu" forState:UIControlStateNormal];
    }
    
    [takePhoto changeTextLanguage:@"TAKE PHOTOS"];
    [recordVideo changeTextLanguage:@"RECORD VIDEO"];
    [recordAudio changeTextLanguage:@"RECORD AUDIO"];
    [addRepresentative changeTextLanguage:@"ADD REPRESENTATIVE"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - choose Language Action
- (IBAction)chooseLanguageAction:(UIButton *)sender {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ChooseLanguageViewController *chooseLangView =[storyboard instantiateViewControllerWithIdentifier:@"ChooseLanguageView"];
    chooseLangView.myVC = (DashboardViewController*)self;
    //    [self.view ]
    [self addChildViewController:chooseLangView];
    [self.view addSubview:chooseLangView.view];
    [chooseLangView didMoveToParentViewController:self];
}
#pragma mark - end

#pragma mark - take Photos Action
- (IBAction)takePhotosAction:(UIButton *)sender {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CustomCameraViewController *previewView =[storyboard instantiateViewControllerWithIdentifier:@"CustomCameraView"];
    [self.navigationController pushViewController:previewView animated:YES];
}
#pragma mark - end

#pragma mark - add Manager Action
- (IBAction)addManagerAction:(UIButton *)sender {
    
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

#pragma mark - add audio Action
- (IBAction)addAudioAction:(UIButton *)sender {
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AudioViewController *audioView =[storyboard instantiateViewControllerWithIdentifier:@"AudioView"];
    [self.navigationController pushViewController:audioView animated:YES];
}
#pragma mark - end

#pragma mark - add video Action
- (IBAction)addVideoAction:(UIButton *)sender {
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CustomVideoViewController *videoView =[storyboard instantiateViewControllerWithIdentifier:@"CustomVideoView"];
    [self.navigationController pushViewController:videoView animated:YES];
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
