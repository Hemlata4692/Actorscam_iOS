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
    NSArray *menuItems,*tableItem;
}

@end

@implementation SidebarViewController

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    tableItem = @[@"Home", @"Edit Profile", @"Representative", @"Change Password", @"Logout"];
    
    menuItems = @[[@"Home" changeTextLanguage:@"Home"], [@"Edit Profile" changeTextLanguage:@"Edit Profile"], [@"Representative" changeTextLanguage:@"Representative"], [@"Change Password" changeTextLanguage:@"Change Password"], [@"Logout" changeTextLanguage:@"Logout"]];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, self.view.frame.size.width, 20)];
    statusBarView.backgroundColor = [UIColor colorWithRed:253.0/255.0 green:138.0/255.0 blue:43.0/255.0 alpha:1.0];
    [self.view addSubview:statusBarView];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if([[UIScreen mainScreen] bounds].size.height>490)
    {
        self.tableView.scrollEnabled=NO;
    }

    [self.revealViewController.frontViewController.view setUserInteractionEnabled:NO];
    [self.tableView reloadData];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    [self.revealViewController.frontViewController.view setUserInteractionEnabled:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

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
    NSString *CellIdentifier = [tableItem objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 225.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Utilities";
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSLog(@"table size %f",tableView.bounds.size.width);
    UIView *headerView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 225)];
    
    headerView.backgroundColor=[UIColor clearColor];
    UIImageView *headerBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 225)] ;
    headerBg.image = [UIImage imageNamed:@"sideBarBg"];
    UILabel * welcomeLabel;
    welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake((tableView.bounds.size.width/2)-50, 150, 100, 22)];
    welcomeLabel.backgroundColor = [UIColor clearColor];
    welcomeLabel.textAlignment=NSTextAlignmentCenter;
    welcomeLabel.textColor=[UIColor whiteColor];
    welcomeLabel.font = [UIFont fontWithName:@"OpenSans" size:13];
//    welcomeLabel.text = [@"Welcome" changeTextLanguage:@"Welcome"] ;// i.e. array element
    [welcomeLabel changeTextLanguage:@"Welcome"];
    
    UILabel *actorName;
    actorName = [[UILabel alloc] initWithFrame:CGRectMake(20, welcomeLabel.frame.origin.y + 10, tableView.bounds.size.width - 40, 50)];
    actorName.backgroundColor = [UIColor clearColor];
    actorName.textAlignment=NSTextAlignmentCenter;
    actorName.lineBreakMode = NSLineBreakByWordWrapping;
    actorName.numberOfLines = 2;
    actorName.textColor=[UIColor whiteColor];
    actorName.font = [UIFont fontWithName:@"OpenSans-Semibold" size:17];
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"actorName"] isEqualToString:@""]) {
        
//        actorName.text = @"User" ;
        [actorName changeTextLanguage:@"User"];
    }
    else
    {
        [actorName changeTextLanguage:[[NSUserDefaults standardUserDefaults]objectForKey:@"actorName"]];
//        actorName.text =[[NSUserDefaults standardUserDefaults]objectForKey:@"actorName"];
    }
    // i.e. array element
    
    UIView *profileImageBackView=[[UIView alloc] initWithFrame:CGRectMake((tableView.bounds.size.width/2)-57, 20, 114, 114)];
    profileImageBackView.backgroundColor = [UIColor clearColor];
    profileImageBackView.layer.borderWidth = 1.0;
    profileImageBackView.layer.borderColor = [UIColor colorWithRed:255.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0].CGColor;

    UIImageView *ProfileImgView = [[UIImageView alloc] initWithFrame:CGRectMake(7, 7, 100, 100)] ;
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
    
    [ProfileImgView setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"sideBarPlaceholder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakRef.contentMode = UIViewContentModeScaleAspectFit;
        weakRef.clipsToBounds = YES;
        weakRef.image = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
  //  imgView.image=profileImage;
    ProfileImgView.layer.cornerRadius = ProfileImgView.frame.size.width / 2;
    ProfileImgView.layer.masksToBounds = YES;
    profileImageBackView.layer.cornerRadius = profileImageBackView.frame.size.width / 2;
    profileImageBackView.layer.masksToBounds = YES;
    [profileImageBackView addSubview:ProfileImgView];
    
    [headerView addSubview:headerBg];
    [headerView addSubview:welcomeLabel];
    [headerView addSubview:actorName];
    [headerView addSubview:profileImageBackView];
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
        [defaults removeObjectForKey:@"EmailId"];
        [defaults synchronize];
        
    }
}
#pragma mark - end

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    // Set the title of navigation bar by using the menu items
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;
    destViewController.title = [[menuItems objectAtIndex:indexPath.row] capitalizedString];
    
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
