//
//  ManagersListCell.h
//  ActorsCam
//
//  Created by Hema on 21/08/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ManagersListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *managerName;
@property (weak, nonatomic) IBOutlet UILabel *manageremail;

-(void)displayData :(NSDictionary *)Dict;

@end
