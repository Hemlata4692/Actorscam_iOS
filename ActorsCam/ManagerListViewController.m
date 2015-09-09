//
//  ManagerListViewController.m
//  ActorsCam
//
//  Created by Hema on 21/08/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "ManagerListViewController.h"
#import "ManagersListCell.h"
#import "AddManagerViewController.h"
#import "UIView+RoundedCorner.h"

@interface ManagerListViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *managerListArray;
    int indexpathRow;

}
@property (weak, nonatomic) IBOutlet UILabel *noManagerAddedLbl;
@property (weak, nonatomic) IBOutlet UIView *addManagerView;
@property (weak, nonatomic) IBOutlet UIImageView *addManagerImage;
@property (weak, nonatomic) IBOutlet UITableView *managerListTableView;
@property (weak, nonatomic) IBOutlet UIButton *addManagerBtn;

@end

@implementation ManagerListViewController
@synthesize managerListTableView,noManagerAddedLbl;
@synthesize addManagerBtn,addManagerImage,addManagerView;

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    //Remove swipe gesture for sidebar
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers)
    {
        [self.view removeGestureRecognizer:recognizer];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    indexpathRow = -1;
    // Do any additional setup after loading the view.
    managerListTableView.hidden = YES;
    addManagerView.hidden=YES;
    [addManagerBtn setCornerRadius:5.0f];
    managerListArray = [NSMutableArray new];
    [managerListTableView reloadData];
    
    [myDelegate ShowIndicator];
    [self performSelector:@selector(managerListing) withObject:nil afterDelay:.1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Add Manager Action
- (IBAction)addManagerButtonAction:(id)sender
{
    AddManagerViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"AddManagerViewController"];
    controller.navTitle = @"Add Managers";
    controller.emailId = @"";
    controller.name = @"";
    controller.managerId = @"";
    [self.navigationController pushViewController:controller animated:YES];
}
#pragma mark - end

#pragma mark - Table View Data source/Delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return managerListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *simpleTableIdentifier = @"mangersList";
    
    ManagersListCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
        cell = [[ManagersListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    NSDictionary *data = [managerListArray objectAtIndex:indexPath.row];
    [cell displayData:data];
    return cell;
}

// Used to remove left gap in table separators in iOS8
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //Nothing gets called here if you invoke `tableView:editActionsForRowAtIndexPath:` according to Apple docs so just leave this method blank
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    //Obviously, if this returns no, the edit option won't even populate
    return YES;
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Edit" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        NSDictionary *data = [managerListArray objectAtIndex:indexPath.row];
        
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        AddManagerViewController *addManagerView1 =[storyboard instantiateViewControllerWithIdentifier:@"AddManagerViewController"];
        addManagerView1.navTitle = @"Edit Managers";
        addManagerView1.emailId = [data objectForKey:@"managerEmail"];
        addManagerView1.name = [data objectForKey:@"managerName"];
        addManagerView1.managerId = [data objectForKey:@"managerId"];
        [self.navigationController pushViewController:addManagerView1 animated:YES];
        
    }];
    editAction.backgroundColor = [UIColor grayColor];
    
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        
        indexpathRow = (int)indexPath.row;
         NSLog(@"delete action");
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Do you want to delete this manager?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        [alert show];
        
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    
    return @[deleteAction,editAction];
}
#pragma mark - end

#pragma mark - AlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1)
    {
        [myDelegate ShowIndicator];
        [self performSelector:@selector(deleteManager) withObject:nil afterDelay:.1];
    }
    else{
        indexpathRow = -1;
    }
    
}
#pragma mark - end

#pragma mark - Delete Manager method
-(void)deleteManager
{
    NSDictionary *data = [managerListArray objectAtIndex:indexpathRow];
    [[WebService sharedManager] deleteManager:[data objectForKey:@"managerId"] managerEmail:[data objectForKey:@"managerEmail"] success:^(id responseObject) {
            NSLog(@"response is %@",responseObject);
            [myDelegate StopIndicator];
        [managerListArray removeObjectAtIndex:indexpathRow];
        if (managerListArray.count==0) {
            addManagerView.hidden=NO;
            managerListTableView.hidden = YES;
        }
        else{
            addManagerView.hidden=YES;
            managerListTableView.hidden = NO;
        }
        indexpathRow = -1;
        [managerListTableView reloadData];
        } failure:^(NSError *error) {
            
        }] ;

}
#pragma mark - end

#pragma mark - Manager Listing method
-(void)managerListing
{
    [[WebService sharedManager] managerListing:^(id responseObject) {
        NSLog(@"response is %@",responseObject);
        [myDelegate StopIndicator];
         managerListArray = [responseObject objectForKey:@"managerList"];
        if (managerListArray.count==0) {
            addManagerView.hidden=NO;
            managerListTableView.hidden = YES;
        }
        else{
            addManagerView.hidden=YES;
            managerListTableView.hidden = NO;
        }
        [managerListTableView reloadData];
    } failure:^(NSError *error) {
        
    }] ;
    
}
#pragma mark - end

@end
