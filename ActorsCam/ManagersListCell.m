//
//  ManagersListCell.m
//  ActorsCam
//
//  Created by Hema on 21/08/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "ManagersListCell.h"

@implementation ManagersListCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)displayData :(NSDictionary *)dict
{

    self.managerName.text = [dict objectForKey:@"managerName"];
    self.manageremail.text = [dict objectForKey:@"managerEmail"];
    self.managerCategory.text = [[NSString stringWithFormat:@"%@", [dict objectForKey:@"category"]] changeTextLanguage:[NSString stringWithFormat:@"%@", [dict objectForKey:@"category"]]];
    
}

@end
