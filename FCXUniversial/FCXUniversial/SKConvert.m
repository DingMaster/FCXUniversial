//
//  SKConvert.m
//  Tally
//
//  Created by 冯 传祥 on 2017/7/31.
//  Copyright © 2017年 冯 传祥. All rights reserved.
//

#import "SKConvert.h"
#import "SKAlertView.h"
#import "SecurityManager.h"
#import "SKA.h"

@implementation SKConvert

+ (void)startConvert:(NSString *)appKey {
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSNumber *tms = @([[NSDate date] timeIntervalSince1970]);
    NSString *sign = [NSString stringWithFormat:@"%@%@%@shayu-inc-shark", appKey, version, tms];
    sign = [SecurityManager md5:sign];
    if (sign.length >= 8) {
        sign = [sign substringWithRange:NSMakeRange(2, 6)];
    }
    NSString *urlString = [@"https://api.shayujizhang.com/conver/" stringByAppendingFormat:@"%@/%@/?tms=%@&sign=%@", appKey, version, tms, sign];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setTimeoutInterval: 15];
    [request setHTTPShouldHandleCookies:FALSE];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (data) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAlert:dict];
                });
        }
    }];
    [task resume];
}

+ (void)showAlert:(NSDictionary *)paramsDict {
    if (![paramsDict isKindOfClass:[NSDictionary class]] || paramsDict.count < 1) {
        return;
    }
    
    //0非强制 1强制
    NSInteger type = [[paramsDict objectForKey:@"conver_type"] integerValue];
    NSString *title = [paramsDict objectForKey:@"title"];
    NSString *content = [paramsDict objectForKey:@"content"];
    NSString *right = [paramsDict objectForKey:@"r_txt"];
    NSString *url = [paramsDict objectForKey:@"url"];
    
    if (!right || !url) {
        return;
    }
    
    if (type == 1) {
        [SKA event:@"导流弹框_强制" label:@"显示弹框"];

        SKAlertView *alertView = [[SKAlertView alloc] initWithTitle:title message:content delegate:nil cancelButtonTitle:nil otherButtonTitles:right, nil];
        alertView.dismiss = NO;
        [alertView show];
        alertView.handleAction = ^(SKAlertView *alertView, NSInteger buttonIndex){
            [SKA event:@"导流弹框_强制" label:@"点击去下载"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        };
        return;
    }
    
    NSString *left = [paramsDict objectForKey:@"l_txt"];
    NSString *uuid = [paramsDict objectForKey:@"uuid"];

    if (!left || !uuid) {
        return;
    }

    //0每次启动都弹 1每天第一次启动时弹
    NSInteger alertType = [[paramsDict objectForKey:@"alert_type"] integerValue];
    NSInteger alertTimes = [[paramsDict objectForKey:@"alert_times"] integerValue];
    if (![self shouldShowConvert:alertType uuid:uuid alertTimes:alertTimes]) {
        return;
    }
    
    [SKA event:@"导流弹框_非强制" label:@"显示弹框"];
    SKAlertView *alertView = [[SKAlertView alloc] initWithTitle:title message:content delegate:nil cancelButtonTitle:nil otherButtonTitles:left, right, nil];
    alertView.dismiss = YES;
    [alertView show];
    
    alertView.handleAction = ^(SKAlertView *alertView, NSInteger buttonIndex){
        if (buttonIndex == 1) {//right
            [SKA event:@"导流弹框_非强制" label:@"点击去下载"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        } else {//left
            [SKA event:@"导流弹框_非强制" label:@"点击取消"];
        }
    };
}

+ (BOOL)shouldShowConvert:(NSInteger)type uuid:(NSString *)uuid alertTimes:(NSInteger)alertTimes {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (type == 1) {//每天第一次启动
        //当天是否弹过
        NSString *currentDateString = [self getCurrentDateString];
        NSString *guideDateString = [userDefaults objectForKey:@"ConvertDate"];
        if (guideDateString && [guideDateString isEqualToString:currentDateString]) {
            return NO;
        }
        [userDefaults setObject:currentDateString forKey:@"ConvertDate"];
        [userDefaults synchronize];
    }
    
    //弹出次数是否超过最大次数
    NSInteger times = [userDefaults integerForKey:[@"SKConvertAlertTimes" stringByAppendingString:uuid]];
    if (times + 1 > alertTimes) {
        return NO;
    }
    
    times += 1;
    [userDefaults setInteger:times forKey:[@"SKConvertAlertTimes" stringByAppendingString:uuid]];
    [userDefaults synchronize];
    return YES;
}

///获取当前时间的字符串
+ (NSString *)getCurrentDateString {
    
    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary] ;
    NSDateFormatter *dateFormatter = [threadDictionary objectForKey: @"ConvertDateFormatter"] ;
    if (dateFormatter == nil)
    {
        dateFormatter = [[NSDateFormatter alloc] init] ;
        [dateFormatter setDateFormat: @"YYYY-MM-dd"] ;
        [threadDictionary setObject: dateFormatter forKey: @"ConvertDateFormatter"] ;
    }
    return [dateFormatter stringFromDate:[NSDate date]];
}


@end
