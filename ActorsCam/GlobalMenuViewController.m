//
//  ActorsCamViewController.m
//  ActorsCam
//
//  Created by Hema on 20/08/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "GlobalMenuViewController.h"
#import "SWRevealViewController.h"

@interface GlobalMenuViewController ()<SWRevealViewControllerDelegate>
{
    UIBarButtonItem *barButton;
    
}
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@end

@implementation GlobalMenuViewController

#pragma mark - View life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
  //  myDelegate.currentNavigationController=self.navigationController;
    
    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"menu.png"]];
    
    SWRevealViewController *revealController = [self revealViewController];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Method to add global side bar button
- (void)addLeftBarButtonWithImage:(UIImage *)buttonImage
{    
    CGRect frameimg = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    UIButton *button = [[UIButton alloc] initWithFrame:frameimg];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    barButton =[[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController)
    {
        [button addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}
#pragma mark - end

@end
