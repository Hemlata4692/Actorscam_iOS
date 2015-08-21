//
//  UIView+RoundedCorner.m
//  WheelerButler
//
//  Created by Ashish A. Solanki on 24/01/15.
//
//

#import "UIView+RoundedCorner.h"

@implementation UIView (RoundedCorner)
- (void)setCornerRadius:(CGFloat)radius {
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;

}
@end
