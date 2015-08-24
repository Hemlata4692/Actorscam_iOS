//
//  ChooseLanguageViewController.m
//  ActorsCam
//
//  Created by Ranosys on 24/08/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "ChooseLanguageViewController.h"

@interface ChooseLanguageViewController (){
    NSArray* languageArray;
    int selectedIndex;
}
//@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *popUpView;
@property (weak, nonatomic) IBOutlet UILabel *chooseLanguagelabel;

@property (weak, nonatomic) IBOutlet UITableView *chooseLanguageTableView;
@property (weak, nonatomic) IBOutlet UIButton *cancel;
@property (weak, nonatomic) IBOutlet UIButton *done;

@end

@implementation ChooseLanguageViewController
@synthesize myVC;

- (void)viewDidLoad {
    [super viewDidLoad];
    languageArray = @[@"ENGLISH", @"FRANCAIS", @"DEUTSCH"];
    [_chooseLanguageTableView reloadData];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return languageArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell ;
    NSString *simpleTableIdentifier = @"cell";
    cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    UIImageView *radioButton = (UIImageView *)[cell viewWithTag:0];
    UILabel *chooseLanguageLabel = (UILabel *)[cell viewWithTag:1];
    
    chooseLanguageLabel.text = [languageArray objectAtIndex:indexPath.row];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"Language"] isEqualToString:[languageArray objectAtIndex:indexPath.row]]) {
        radioButton.image = [UIImage imageNamed:@"radio_btn_selected.png"];
        selectedIndex = indexPath.row;
    }
    else{
        radioButton.image = [UIImage imageNamed:@"radio_btn.png"];
    }
    
    return cell;
    
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *radioButton = (UIImageView *)[cell viewWithTag:0];
    radioButton.image = [UIImage imageNamed:@"radio_btn_selected.png"];
    selectedIndex = indexPath.row;
    for (int i=0; i<languageArray.count; i++) {
        if (i!=indexPath.row) {
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
            UITableViewCell *cell1 = [tableView cellForRowAtIndexPath:newIndexPath];
            UIImageView *radioButton1 = (UIImageView *)[cell1 viewWithTag:0];
            radioButton1.image = [UIImage imageNamed:@"radio_btn.png"];
        }
    }
//    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:oldIndexPath.row inSection:1];
//    oldIndexPath = newIndexPath;
}


#pragma mark - end

- (IBAction)cancelAction:(id)sender {
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    NSLog(@"checker");
}

- (IBAction)doneAction:(UIButton *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:[languageArray objectAtIndex:selectedIndex] forKey:@"Language"];
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
//    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    LoginViewController *chooseLangView =[storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
//    [myVC viewWillAppear:YES];
    [myVC setLocalizedString];
//    NSLog(@"checker");
    
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
