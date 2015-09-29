//
//  UITextField+Padding.h
//  Sure
//
//  Created by Hema on 25/03/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (Padding)

-(void)addTextFieldPaddingWithoutImages: (UITextField *)textfield;
-(void)addTextFieldPadding: (UITextField *)textfield color:(UIColor *)color;
@end
