//
//  ChooseLanguageCell.m
//  ActorsCam
//
//  Created by Ranosys on 09/09/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "ChooseLanguageCell.h"

@implementation ChooseLanguageCell
@synthesize radioImage, languageLabel;
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(int)changeLanguageCellMethod:(NSArray*)languageArray indexPath:(NSIndexPath*)indexPath selectedIndex:(int)selectedIndex{
    languageLabel.text = [languageArray objectAtIndex:indexPath.row];
    
    if ([[languageArray objectAtIndex:indexPath.row] isEqualToString:@"ENGLISH"]) {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"Language"] isEqualToString:@"en"]) {
            radioImage.image = [UIImage imageNamed:@"radio_btn_selected.png"];
            selectedIndex = (int)indexPath.row;
        }
        else{
            radioImage.image = [UIImage imageNamed:@"radio_btn.png"];
        }
    }
    else if ([[languageArray objectAtIndex:indexPath.row] isEqualToString:@"FRANCAIS"]){
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"Language"] isEqualToString:@"fr"]) {
            radioImage.image = [UIImage imageNamed:@"radio_btn_selected.png"];
            selectedIndex = (int)indexPath.row;
        }
        else{
            radioImage.image = [UIImage imageNamed:@"radio_btn.png"];
        }
    }
    else if ([[languageArray objectAtIndex:indexPath.row] isEqualToString:@"DEUTSCH"]){
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"Language"] isEqualToString:@"zn"]) {
            radioImage.image = [UIImage imageNamed:@"radio_btn_selected.png"];
            selectedIndex = (int)indexPath.row;
        }
        else{
            radioImage.image = [UIImage imageNamed:@"radio_btn.png"];
        }
    }
    else{
        radioImage.image = [UIImage imageNamed:@"radio_btn.png"];
    }
    return selectedIndex;
}

-(void)didSelectCellMethod:(NSArray*)languageArray indexPath:(NSIndexPath*)indexPath tableView:(UITableView*)tableView{
    radioImage.image = [UIImage imageNamed:@"radio_btn_selected.png"];
    
    for (int i=0; i<languageArray.count; i++) {
        if (i!=indexPath.row) {
           
            NSIndexPath* cellPath = [NSIndexPath indexPathForRow:i inSection:0];
            ChooseLanguageCell* cell = (ChooseLanguageCell *)[tableView cellForRowAtIndexPath:cellPath];
            cell.radioImage.image = [UIImage imageNamed:@"radio_btn.png"];
            
        }
    }
}

@end
