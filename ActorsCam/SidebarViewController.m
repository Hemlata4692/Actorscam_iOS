//
//  SidebarViewController.m
//  SidebarDemoApp
//
//  Created by Ranosys on 06/02/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import "SidebarViewController.h"
#import "SWRevealViewController.h"
#import "LoginViewController.h"
#import <UIImageView+AFNetworking.h>

@interface SidebarViewController (){
    NSArray *menuItems;
}


@end

@implementation SidebarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    menuItems = @[@"Home", @"Edit Profile", @"Managers", @"Change Password", @"Logout"];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, self.view.frame.size.width, 20)];
    statusBarView.backgroundColor = [UIColor colorWithRed:83.0/255.0 green:24.0/255.0 blue:152.0/255.0 alpha:1.0];
    [self.view addSubview:statusBarView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return menuItems.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 200.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Utilities";
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSLog(@"table size %f",tableView.bounds.size.width);
    UIView *headerView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 200)];
    
    headerView.backgroundColor=[UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    UILabel * welcomeLabel;
    welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake((tableView.bounds.size.width/2)-50, 130, 100, 22)];
    welcomeLabel.backgroundColor = [UIColor whiteColor];
    welcomeLabel.textAlignment=NSTextAlignmentCenter;
    welcomeLabel.textColor=[UIColor colorWithRed:253.0/255.0 green:47.0/255.0 blue:47.0/255.0 alpha:1.0];
    welcomeLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
    welcomeLabel.text = @"Welcome" ;// i.e. array element
   
    UILabel *actorName;
    actorName = [[UILabel alloc] initWithFrame:CGRectMake((tableView.bounds.size.width/2)-65, 160, 130, 35)];
    actorName.backgroundColor = [UIColor clearColor];
    actorName.textAlignment=NSTextAlignmentCenter;
    actorName.lineBreakMode = NSLineBreakByWordWrapping;
    actorName.numberOfLines = 2;
    actorName.textColor=[UIColor colorWithRed:121.0/255.0 green:115.0/255.0 blue:115.0/255.0 alpha:1.0];
    actorName.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"actorName"] isEqualToString:@""]) {
        
        actorName.text = @"User" ;
    }
    else
    {
        actorName.text =[[NSUserDefaults standardUserDefaults]objectForKey:@"actorName"];
    }
    // i.e. array element
    
    UIImageView *ProfileImgView = [[UIImageView alloc] initWithFrame:CGRectMake(75, 20, 100, 100)] ;
    //imgView.contentMode=UIViewContentModeScaleAspectFill;
    ProfileImgView.contentMode = UIViewContentModeScaleAspectFill;
    ProfileImgView.clipsToBounds = YES;
    ProfileImgView.backgroundColor=[UIColor clearColor];
   // profileImageUrl
     __weak UIImageView *weakRef = ProfileImgView;
    NSString *tempImageString = [[NSUserDefaults standardUserDefaults]objectForKey:@"profileImageUrl"];
    
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:tempImageString]
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [ProfileImgView setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"picture"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakRef.contentMode = UIViewContentModeScaleAspectFit;
        weakRef.clipsToBounds = YES;
        weakRef.image = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
  //  imgView.image=profileImage;
    ProfileImgView.layer.cornerRadius = ProfileImgView.frame.size.width / 2;
    [headerView addSubview:welcomeLabel];
    [headerView addSubview:actorName];
    [headerView addSubview:ProfileImgView];
    return headerView;   // return headerLabel;

}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Check Row and Select Next View controller
    if (indexPath.row == 4)
    {
        
        UIViewController* rootController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"LoginViewController"];
        
        UINavigationController* navigation = [[UINavigationController alloc] initWithRootViewController:rootController];
        myDelegate.window.rootViewController = navigation;
     
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"UserId"];
        [defaults removeObjectForKey:@"actorName"];
        [defaults synchronize];
        
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    // Set the title of navigation bar by using the menu items
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;
    destViewController.title = [[menuItems objectAtIndex:indexPath.row] capitalizedString];
    
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
