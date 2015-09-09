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
#import "CustomCameraViewController.h"

@interface DashboardViewController ()

@property (weak, nonatomic) IBOutlet UIButton *chooseLanguage;

@end

@implementation DashboardViewController

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    //Remove swipe gesture for sidebar
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers)
    {
        [self.view removeGestureRecognizer:recognizer];
    }
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setLocalizedString];

    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
}

-(void)setLocalizedString{
    
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
    addManagerView.navTitle = @"Add Managers";
    addManagerView.emailId = @"";
    addManagerView.name = @"";
    addManagerView.managerId = @"";
    [self.navigationController pushViewController:addManagerView animated:YES];
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
