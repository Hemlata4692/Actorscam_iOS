//
//  UILabel+LocalizedString.m
//  ActorsCam
//
//  Created by Ranosys on 08/09/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "UILabel+LocalizedString.h"
#import <objc/runtime.h>
#import "LocalizedObject.h"

static const char kBundleKey = 0;

@implementation UILabel (LocalizedString)

- (UILabel*)changeTextLanguage:(NSString*)text
{
    NSString *language = [[NSUserDefaults standardUserDefaults] objectForKey:@"Language"];
    id value = language ? [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:language ofType:@"lproj"]] : nil;
    objc_setAssociatedObject([NSBundle mainBundle], &kBundleKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.text = [LocalizedObject localizedStringForKey:text value:@"" table:@"Localizable" bundleName:[NSBundle mainBundle]];
    return self;
}
@end

@implementation UIButton (LocalizedString)

- (UIButton*)changeTextLanguage:(NSString*)text
{
    NSString *language = [[NSUserDefaults standardUserDefaults] objectForKey:@"Language"];
    id value = language ? [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:language ofType:@"lproj"]] : nil;
    objc_setAssociatedObject([NSBundle mainBundle], &kBundleKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setTitle:[LocalizedObject localizedStringForKey:text value:@"" table:@"Localizable" bundleName:[NSBundle mainBundle]] forState:UIControlStateNormal];
    return self;
}

@end

@implementation UITextField (LocalizedString)

- (UITextField*)changeTextLanguage:(NSString*)text
{
    NSString *language = [[NSUserDefaults standardUserDefaults] objectForKey:@"Language"];
    id value = language ? [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:language ofType:@"lproj"]] : nil;
    objc_setAssociatedObject([NSBundle mainBundle], &kBundleKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.placeholder = [LocalizedObject localizedStringForKey:text value:@"" table:@"Localizable" bundleName:[NSBundle mainBundle]];
   
    return self;
}
@end

@implementation NSString (LocalizedString)

- (NSString*)changeTextLanguage:(NSString*)text
{
    NSString *language = [[NSUserDefaults standardUserDefaults] objectForKey:@"Language"];
    id value = language ? [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:language ofType:@"lproj"]] : nil;
    objc_setAssociatedObject([NSBundle mainBundle], &kBundleKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    text = [LocalizedObject localizedStringForKey:text value:@"" table:@"Localizable" bundleName:[NSBundle mainBundle]];
    
    return text;
}
@end


