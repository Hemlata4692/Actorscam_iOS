//
//  UIImage+deviceSpecificMedia.m
//  JobPortal
//
//  Created by Sumit on 24/12/14.
//  Copyright (c) 2014 Sumit. All rights reserved.
//

#import "UIImage+deviceSpecificMedia.h"

thisDeviceClass currentDeviceClass() {
    
    CGFloat greaterPixelDimension = (CGFloat) fmaxf(((float)[[UIScreen mainScreen]bounds].size.height),
                                                    ((float)[[UIScreen mainScreen]bounds].size.width));
    
    switch ((NSInteger)greaterPixelDimension) {
        case 480:
            return (( [[UIScreen mainScreen]scale] > 1.0) ? thisDeviceClass_iPhoneRetina : thisDeviceClass_iPhone );
            break;
        case 568:
            return thisDeviceClass_iPhone5;
            break;
        case 667:
            return thisDeviceClass_iPhone6;
            break;
        case 736:
            return thisDeviceClass_iPhone6plus;
            break;
        case 1024:
            return (( [[UIScreen mainScreen]scale] > 1.0) ? thisDeviceClass_iPadRetina : thisDeviceClass_iPad );
            break;
        default:
            return thisDeviceClass_unknown;
            break;
    }
}

@implementation UIImage (deviceSpecificMedia)

+ (NSString *)magicSuffixForDevice
{
    switch (currentDeviceClass())
    {
        case thisDeviceClass_iPhone:
            return @"";
            break;
        case thisDeviceClass_iPhoneRetina:
            return @"";
            break;
        case thisDeviceClass_iPhone5:
            return @"-568h@2x";
            break;
        case thisDeviceClass_iPhone6:
            return @"-667h@2x"; //or some other arbitrary string..
            break;
        case thisDeviceClass_iPhone6plus:
            return @"-736h@3x";
            break;
            
        case thisDeviceClass_iPad:
            return @"~ipad";
            break;
        case thisDeviceClass_iPadRetina:
            return @"~ipad@2x";
            break;
            
        case thisDeviceClass_unknown:
        default:
            return @"";
            break;
    }
}

- (NSString * )imageForDeviceWithName:(NSString *)fileName
{
    UIImage *result = nil;
    NSString *nameWithSuffix = [fileName stringByAppendingString:[UIImage magicSuffixForDevice]];
    
    result = [UIImage imageNamed:nameWithSuffix];
    if (!result)
    {
        result = [UIImage imageNamed:fileName];
    }
    return nameWithSuffix;
}
+ (NSString *)magicSuffixForDeviceForOtherImages
{
    switch (currentDeviceClass())
    {
        case thisDeviceClass_iPhone:
            return @"";
            break;
        case thisDeviceClass_iPhoneRetina:
            return @"";
            break;
        case thisDeviceClass_iPhone5:
            return @"";
            break;
        case thisDeviceClass_iPhone6:
            return @"-667h@2x"; //or some other arbitrary string..
            break;
        case thisDeviceClass_iPhone6plus:
            return @"-736h@3x";
            break;
            
        case thisDeviceClass_iPad:
            return @"~ipad";
            break;
        case thisDeviceClass_iPadRetina:
            return @"~ipad@2x";
            break;
            
        case thisDeviceClass_unknown:
        default:
            return @"";
            break;
    }
}

- (NSString * )imageForDeviceWithNameForOtherImages:(NSString *)fileName
{
    UIImage *result = nil;
    NSString *nameWithSuffix = [fileName stringByAppendingString:[UIImage magicSuffixForDeviceForOtherImages]];
    
    result = [UIImage imageNamed:nameWithSuffix];
    if (!result) {
        result = [UIImage imageNamed:fileName];
    }
    return nameWithSuffix;
}

@end
