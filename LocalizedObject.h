//
//  LocalizedObject.h
//  ActorsCam
//
//  Created by Ranosys on 08/09/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalizedObject : NSObject
+ (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName bundleName:(NSBundle*)bundleName;
@end
