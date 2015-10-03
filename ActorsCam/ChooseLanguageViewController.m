//
//  ChooseLanguageViewController.m
//  ActorsCam
//
//  Created by Ranosys on 24/08/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "ChooseLanguageViewController.h"
#import "ChooseLanguageCell.h"

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

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    selectedIndex = -1;
    
    _popUpView.layer.cornerRadius = 10.0;
    _popUpView.layer.masksToBounds = YES;
    
    _cancel.layer.borderWidth = 1;
    _cancel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    _done.layer.borderWidth = 1;
    _done.layer.borderColor = [UIColor lightGrayColor].CGColor;

    languageArray = @[@"ENGLISH", @"FRANCAIS", @"DEUTSCH"];
    [_chooseLanguageTableView reloadData];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

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
    ChooseLanguageCell *cell ;
    NSString *simpleTableIdentifier = @"cell";
    cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        cell = [[ChooseLanguageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    selectedIndex = [cell changeLanguageCellMethod:languageArray indexPath:indexPath selectedIndex:selectedIndex];
   
    return cell;
    
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChooseLanguageCell *cell = (ChooseLanguageCell*)[tableView cellForRowAtIndexPath:indexPath];
    selectedIndex = (int)indexPath.row;
    [cell didSelectCellMethod:languageArray indexPath:indexPath tableView:tableView];
}
#pragma mark - end

#pragma mark - Cancel action
- (IBAction)cancelAction:(id)sender {
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"Language"]);
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    NSLog(@"checker");
}
#pragma mark - end

#pragma mark - Done action
- (IBAction)doneAction:(UIButton *)sender {
    if ([[languageArray objectAtIndex:selectedIndex] isEqualToString:@"ENGLISH"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"en" forKey:@"Language"];
    }
    else if ([[languageArray objectAtIndex:selectedIndex] isEqualToString:@"FRANCAIS"]){
        [[NSUserDefaults standardUserDefaults] setObject:@"fr" forKey:@"Language"];
    }
    else if ([[languageArray objectAtIndex:selectedIndex] isEqualToString:@"DEUTSCH"]){
        [[NSUserDefaults standardUserDefaults] setObject:@"zn" forKey:@"Language"];
    }
    
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    [myVC setLocalizedString];

    
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
