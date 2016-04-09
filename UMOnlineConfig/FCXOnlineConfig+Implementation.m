//
//  FCXOnlineConfig+Implementation.m
//  FCXUniversial
//
//  Created by 冯 传祥 on 16/4/9.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import "FCXOnlineConfig+Implementation.h"
#import "UMOnlineConfig.h"

@implementation FCXOnlineConfig (Implementation)

+ (NSString *)fcxGetConfigParams:(NSString *)key defaultValue:(NSString *)defaultValue {
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *versionParam = [NSString stringWithFormat:@"%@_%@", key, appVersion];
    
    NSString *result = [UMOnlineConfig getConfigParams:versionParam];
    
    if (result == nil) {
        
        result = [UMOnlineConfig getConfigParams:key];
        if (result == nil && defaultValue != nil) {
            result = defaultValue;
        }
    }
    
    return result;
}

@end
