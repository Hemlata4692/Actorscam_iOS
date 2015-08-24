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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}


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
    //    if (tab_Icon.count >0 && Utility_Icon_Array.count > 0 ) {
    //        if (section == 0) {
    //            return @"   Essential";
    //        }
    //        else
    //        {
    //            return @"   Utilities";
    //        }
    //    }
    //    else if (tab_Icon.count > 0)
    //    {
    //        return @"   Essential";
    //    }
    //    return @"   Utilities";
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSLog(@"table size %f",tableView.bounds.size.width);
    UIView *headerView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 200)];
    
    headerView.backgroundColor=[UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    UILabel * label1;
    label1 = [[UILabel alloc] initWithFrame:CGRectMake(75, 130, 100, 22)];
    label1.backgroundColor = [UIColor whiteColor];
    label1.textAlignment=NSTextAlignmentCenter;
    label1.textColor=[UIColor colorWithRed:253.0/255.0 green:47.0/255.0 blue:47.0/255.0 alpha:1.0];
    label1.font = [UIFont fontWithName:@"Helvetica" size:13];
    label1.text = @"Welcome" ;// i.e. array element
   
    UILabel *label2;
    label2 = [[UILabel alloc] initWithFrame:CGRectMake(75, 160, 130, 35)];
    label2.backgroundColor = [UIColor whiteColor];
    label2.textAlignment=NSTextAlignmentCenter;
    label2.lineBreakMode = NSLineBreakByWordWrapping;
    label2.numberOfLines = 2;
    label2.textColor=[UIColor colorWithRed:121.0/255.0 green:115.0/255.0 blue:115.0/255.0 alpha:1.0];
    label2.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"Name"] isEqualToString:@""]) {
        
        label2.text = @"User" ;
    }
    else
    {
        label2.text =[[NSUserDefaults standardUserDefaults]objectForKey:@"Name"];
    }
    // i.e. array element
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(75, 20, 100, 100)] ;
    //imgView.contentMode=UIViewContentModeScaleAspectFill;
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.clipsToBounds = YES;
    imgView.backgroundColor=[UIColor whiteColor];
  //  imgView.image=profileImage;
    imgView.layer.cornerRadius = imgView.frame.size.width / 2;
    [headerView addSubview:label1];
    [headerView addSubview:label2];
    [headerView addSubview:imgView];
    return headerView;   // return headerLabel;

}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Check Row and Select Next View controller
    if (indexPath.row == 4)
    {
//        if (!([FBSession activeSession].state != FBSessionStateOpen &&
//              [FBSession activeSession].state != FBSessionStateOpenTokenExtended))
//        {
//            [[FBSession activeSession] closeAndClearTokenInformation];
//        }
//        
        
        UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        myDelegate.window.rootViewController = myDelegate.navigationController;
        LoginViewController *firstVC=[sb instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [myDelegate.navigationController setViewControllers: [NSArray arrayWithObject: firstVC]
                                                   animated: YES];
        
//        [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"userid"] forKey:@"UserId"];
//        [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"username"] forKey:@"UserName"];
//        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"UserId"];
        [defaults removeObjectForKey:@"UserName"];
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
    
    // Set the photo if it navigates to the PhotoView
    //    if ([segue.identifier isEqualToString:@"showPhoto"]) {
    //        UINavigationController *navController = segue.destinationViewController;
    //        LeaveManagementViewController *photoController = [navController childViewControllers].firstObject;
    //        NSString *photoFilename = [NSString stringWithFormat:@"%@_photo", [menuItems objectAtIndex:indexPath.row]];
    //        //photoController.photoFilename = photoFilename;
    //    }
}


/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
 
 // Configure the cell...
 
 return cell;
 }
 */

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
