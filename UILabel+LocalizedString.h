//
//  UILabel+LocalizedString.h
//  ActorsCam
//
//  Created by Ranosys on 08/09/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (LocalizedString)
- (UILabel*)changeTextLanguage:(NSString*)text;
@end

@interface UIButton (LocalizedString)
- (UIButton*)changeTextLanguage:(NSString*)text;
@end

@interface UIBarButtonItem (LocalizedString)
- (UIBarButtonItem*)changeTextLanguage:(NSString*)text;
@end

@interface UITextField (LocalizedString)
- (UITextField*)changeTextLanguage:(NSString*)text;
@end

@interface NSString (LocalizedString)
- (NSString*)changeTextLanguage:(NSString*)text;
@end
