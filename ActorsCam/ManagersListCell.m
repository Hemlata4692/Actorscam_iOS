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
//    dict1 = @{@"name" : @"Mark D.",
//              @"managerEmail" : @"markd@gmail.com"};

    self.managerName.text = [dict objectForKey:@"name"];
    self.manageremail.text = [dict objectForKey:@"managerEmail"];
    
}


@end
