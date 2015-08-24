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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  //  addManagerView.hidden=YES;
    [addManagerBtn setCornerRadius:5.0f];
    managerListArray = [[NSMutableArray alloc]initWithObjects:@"test1",@"test2",@"test3",@"test4", nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Add Manager Action
- (IBAction)addManagerButtonAction:(id)sender
{
    AddManagerViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"AddManagerViewController"];
    [self.navigationController pushViewController:controller animated:YES];}

#pragma mark - end

#pragma mark - Table View Data source

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
    cell.managerName.text=[managerListArray objectAtIndex:indexPath.row];
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
        
        NSLog(@"Edit action");
        
    }];
    editAction.backgroundColor = [UIColor grayColor];
    
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
         NSLog(@"delete action");
        
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    
    return @[deleteAction,editAction];
}
#pragma mark - end

@end
