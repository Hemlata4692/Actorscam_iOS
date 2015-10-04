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
//    if([[UIScreen mainScreen] bounds].size.height>490)
//    {
        self.tableView.scrollEnabled=NO;
//    }

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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if([[UIDevice currentDevice] userInterfaceIdiom] ==  UIUserInterfaceIdiomPad){
        return 80.0;
    }
    else{
        return 50.0;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [tableItem objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UILabel *cellLabel = (UILabel *)[cell viewWithTag:2];
    UIImageView *icon = (UIImageView *)[cell viewWithTag:1];

    cell.translatesAutoresizingMaskIntoConstraints = YES;
    cellLabel.translatesAutoresizingMaskIntoConstraints = YES;
    icon.translatesAutoresizingMaskIntoConstraints = YES;
    
    if([[UIDevice currentDevice] userInterfaceIdiom] ==  UIUserInterfaceIdiomPad){
        icon.frame = CGRectMake(15, 23, 54, 54);
        cellLabel.frame = CGRectMake(86, 34, tableView.frame.size.width - 86 - 17, 34);
        [cellLabel.font fontWithSize:20];
    }
    else{
        icon.frame = CGRectMake(15, 15, 34, 34);
        cellLabel.frame = CGRectMake(66, 19, tableView.frame.size.width - 66 - 17, 26);
        [cellLabel.font fontWithSize:17];
    }
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    if([[UIDevice currentDevice] userInterfaceIdiom] ==  UIUserInterfaceIdiomPad){
        float aspectHeight = 448.0/1024.0;
        return ((tableView.bounds.size.height * aspectHeight) - 20);
    }
    else{
        if([[UIScreen mainScreen] bounds].size.height > 570) {
            float aspectHeight = 186.0/480.0;
            return (tableView.bounds.size.height * aspectHeight - 40);
        }
        else{
            return 186;
        }
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Utilities";
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSLog(@"table size %f",tableView.bounds.size.width);
    float aspectHeight, profileViewHeight, welcomeFont,welcomeHeight, nameFont, nameHeight;
    if([[UIDevice currentDevice] userInterfaceIdiom] ==  UIUserInterfaceIdiomPad){
        aspectHeight = 448/1024.0;
        aspectHeight = ((tableView.bounds.size.height * aspectHeight) - 20);
        profileViewHeight = tableView.bounds.size.height * (114.0/480.0);
        welcomeFont = 17.0;
        nameFont = 25.0;
        welcomeHeight = 32;
        nameHeight = 40;
        
    }
    else{
        welcomeFont = 13.0;
        nameFont = 17.0;
        welcomeHeight = 16;
        nameHeight = 23;
        
        aspectHeight = 186.0/480.0;
        profileViewHeight = 114;
        if([[UIScreen mainScreen] bounds].size.height > 570) {
            aspectHeight = (tableView.bounds.size.height * aspectHeight - 40);
        }
        else{
            aspectHeight = 186;
        }
    }
    
    UIView *headerView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, aspectHeight)];
    
    headerView.backgroundColor=[UIColor clearColor];
    UIImageView *headerBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, headerView.bounds.size.width, headerView.frame.size.height)] ;
    headerBg.image = [UIImage imageNamed:@"sideBarBg"];
       // i.e. array element
    
    UIView *profileImageBackView=[[UIView alloc] initWithFrame:CGRectMake((tableView.bounds.size.width/2)-(profileViewHeight/2), 20, profileViewHeight, profileViewHeight)];
    profileImageBackView.backgroundColor = [UIColor clearColor];
    profileImageBackView.layer.borderWidth = 1.0;
    profileImageBackView.layer.borderColor = [UIColor colorWithRed:255.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0].CGColor;

    UIImageView *ProfileImgView = [[UIImageView alloc] initWithFrame:CGRectMake(7, 7, profileViewHeight - 14, profileViewHeight - 14)] ;
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
    
    UILabel * welcomeLabel;
    welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake((tableView.bounds.size.width/2)-50, profileImageBackView.frame.origin.y + profileImageBackView.frame.size.height + (welcomeHeight - 6), 100, welcomeHeight)];
    welcomeLabel.backgroundColor = [UIColor clearColor];
    welcomeLabel.textAlignment=NSTextAlignmentCenter;
    welcomeLabel.textColor=[UIColor whiteColor];
    welcomeLabel.font = [UIFont fontWithName:@"OpenSans" size:welcomeFont];
    //    welcomeLabel.text = [@"Welcome" changeTextLanguage:@"Welcome"] ;// i.e. array element
    [welcomeLabel changeTextLanguage:@"Welcome"];
    
    UILabel *actorName;
    actorName = [[UILabel alloc] initWithFrame:CGRectMake(20, welcomeLabel.frame.origin.y + (nameHeight - 5), tableView.bounds.size.width - 40, nameHeight)];
    actorName.backgroundColor = [UIColor clearColor];
    actorName.textAlignment=NSTextAlignmentCenter;
    actorName.lineBreakMode = NSLineBreakByWordWrapping;
    actorName.numberOfLines = 1;
    actorName.textColor=[UIColor whiteColor];
    actorName.font = [UIFont fontWithName:@"OpenSans-Semibold" size:nameFont];
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"actorName"] isEqualToString:@""]) {
        
        //        actorName.text = @"User" ;
        [actorName changeTextLanguage:@"User"];
    }
    else
    {
        [actorName changeTextLanguage:[[NSUserDefaults standardUserDefaults]objectForKey:@"actorName"]];
        //        actorName.text =[[NSUserDefaults standardUserDefaults]objectForKey:@"actorName"];
    }
    
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
