//
//  FCXOnlineConfig.m
//  FCXUniversial
//
//  Created by 冯 传祥 on 16/3/29.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import "FCXOnlineConfig.h"

@implementation FCXOnlineConfig


+ (NSString *)fcxGetConfigParams:(NSString *)key defaultValue:(NSString *)defaultValue {
    return @"";
}

+ (NSString *)fcxGetConfigParams:(NSString *)key {
    
    return [self fcxGetConfigParams:key defaultValue:nil];
}

+ (id)fcxGetJSONConfigParams:(NSString *)key {
    
    NSString *paramsString = [self fcxGetConfigParams:key defaultValue:@""];
    id jsonConfigParams  = [NSJSONSerialization JSONObjectWithData:[paramsString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    return jsonConfigParams;
}



@end
