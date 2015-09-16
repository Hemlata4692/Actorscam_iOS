//
//  ChooseLanguageCell.h
//  ActorsCam
//
//  Created by Ranosys on 09/09/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseLanguageCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *radioImage;
@property (strong, nonatomic) IBOutlet UILabel *languageLabel;

-(int)changeLanguageCellMethod:(NSArray*)languageArray indexPath:(NSIndexPath*)indexPath selectedIndex:(int)selectedIndex;
-(void)didSelectCellMethod:(NSArray*)languageArray indexPath:(NSIndexPath*)indexPath tableView:(UITableView*)tableView;
@end
