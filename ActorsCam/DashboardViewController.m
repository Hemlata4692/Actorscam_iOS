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

@interface DashboardViewController ()

@property (weak, nonatomic) IBOutlet UIButton *chooseLanguage;

@end

@implementation DashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
//    
    [self setLocalizedString];
//
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
}

-(void)setLocalizedString{
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)chooseLanguageAction:(UIButton *)sender {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ChooseLanguageViewController *chooseLangView =[storyboard instantiateViewControllerWithIdentifier:@"ChooseLanguageView"];
    chooseLangView.myVC = (DashboardViewController*)self;
    //    [self.view ]
    [self addChildViewController:chooseLangView];
    [self.view addSubview:chooseLangView.view];
    [chooseLangView didMoveToParentViewController:self];
}

- (IBAction)takePhotosAction:(UIButton *)sender {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ImagePreviewViewController *previewView =[storyboard instantiateViewControllerWithIdentifier:@"ImagePreviewViewController"];
    [self.navigationController pushViewController:previewView animated:YES];
}

- (IBAction)addManagerAction:(UIButton *)sender {
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AddManagerViewController *addManagerView =[storyboard instantiateViewControllerWithIdentifier:@"AddManagerViewController"];
    addManagerView.navTitle = @"Add Managers";
    addManagerView.emailId = @"";
    addManagerView.name = @"";
    [self.navigationController pushViewController:addManagerView animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
