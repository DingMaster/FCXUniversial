//
//  FCXOnlineConfig+Implementation.m
//  FCXUniversial
//
//  Created by 冯 传祥 on 16/4/9.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import "FCXOnlineConfig+Implementation.h"
#import "UMOnlineConfig.h"
#import <objc/runtime.h>


@implementation FCXOnlineConfig (Implementation)


+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SwizzleClassMethod([self class], @selector(fcxGetConfigParams:defaultValue:), @selector(fcxImplementationGetConfigParams:defaultValue:));
    });
}

+ (NSString *)fcxImplementationGetConfigParams:(NSString *)key defaultValue:(NSString *)defaultValue {
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

void SwizzleClassMethod(Class c, SEL orig, SEL new) {
    
    Method origMethod = class_getClassMethod(c, orig);
    Method newMethod = class_getClassMethod(c, new);
    
    c = object_getClass((id)c);
    
    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
}

@end
