//
//  SKOnlineConfig.h
//  Tally
//
//  Created by 冯 传祥 on 2017/7/24.
//  Copyright © 2017年 冯 传祥. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const SKOnlineConfigDidFinishNotification = @"SKOnlineConfigDidFinishNotification";

@interface SKOnlineConfig : NSObject

+ (void)startWithAppKey:(NSString *)appKey;

+ (NSString *)getConfigParams:(NSString *)key;
+ (NSString *)getConfigParams:(NSString *)key defaultValue:(NSString*)defaultValue;
+ (id)getJSONConfigParams:(NSString *)key;
+ (BOOL)getBoolConfigParams:(NSString *)key;
+ (BOOL)getBoolConfigParams:(NSString *)key defaultValue:(NSString*)defaultValue;

@end
