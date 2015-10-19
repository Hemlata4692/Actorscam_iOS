//
//  LocalizedObject.m
//  ActorsCam
//
//  Created by Ranosys on 08/09/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "LocalizedObject.h"
#import <objc/runtime.h>

@implementation LocalizedObject

+ (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName bundleName:(NSBundle*)bundle{
    return [bundle localizedStringForKey:key value:value table:tableName];
}

@end
