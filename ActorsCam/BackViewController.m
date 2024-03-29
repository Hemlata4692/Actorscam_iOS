//
//  BackViewController.m
//  ActorsCam
//
//  Created by Hema on 20/08/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "BackViewController.h"
#import "SWRevealViewController.h"
@interface BackViewController ()<SWRevealViewControllerDelegate>
{
    UIBarButtonItem *barButton;
}

@end

@implementation BackViewController

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"back.png"]];
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Add back button add global side bar button
- (void)addLeftBarButtonWithImage:(UIImage *)buttonImage  {
  
   CGRect framing = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    UIButton *button = [[UIButton alloc] initWithFrame:framing];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    barButton =[[UIBarButtonItem alloc] initWithCustomView:button];
    [button addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = barButton;
    
}
//back button action
-(void)backButtonAction :(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - end

@end
