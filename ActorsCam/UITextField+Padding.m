//
//  UITextField+Padding.m
//  Sure
//
//  Created by Hema on 25/03/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import "UITextField+Padding.h"

@implementation UITextField (Padding)

-(void)addTextFieldPadding: (UITextField *)textfield color:(UIColor *)color
{
    UIView *leftPadding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
    textfield.leftView = leftPadding;
    textfield.leftViewMode = UITextFieldViewModeAlways;
    [textfield setValue:color forKeyPath:@"_placeholderLabel.textColor"];

}

-(void)addTextFieldPaddingWithoutImages: (UITextField *)textfield
{
    UIView *leftPadding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    textfield.leftView = leftPadding;
    textfield.leftViewMode = UITextFieldViewModeAlways;    
}

@end
