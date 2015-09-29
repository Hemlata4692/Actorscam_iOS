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
//    UIView *addStatusBar = [[UIView alloc] init];
//    addStatusBar.frame = CGRectMake(0, 0, 320, 20);
//    addStatusBar.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:97.0/255.0 blue:70.0/255.0 alpha:1.0];
//    [self.view addSubview:addStatusBar];
    
    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"menu"]];
    
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
