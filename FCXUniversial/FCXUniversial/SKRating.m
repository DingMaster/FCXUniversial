//
//  SKRating.m
//  Tally
//
//  Created by 冯 传祥 on 2017/7/29.
//  Copyright © 2017年 冯 传祥. All rights reserved.
//

#import "SKRating.h"
#import "UMFeedback.h"
#import "SKOnlineConfig.h"
#import "SKA.h"
#import <StoreKit/SKStoreProductViewController.h>
#import "SKAlertView.h"
#import "SecurityManager.h"
#import <StoreKit/SKStoreReviewController.h>


#define HASRATING @"SKHasRating"

@interface SKRating () <SKStoreProductViewControllerDelegate>

@end

@implementation SKRating

+ (SKRating *)sharedRating {
    static SKRating *rating;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rating = [[SKRating alloc] init];
    });
    return rating;
}

+ (void)startRating:(NSString*)appID
            apppKey:(NSString *)appKey
         controller:(UIViewController *)controller
             finish:(void(^)(BOOL success))finish {
    if (!appKey) {
        return;
    }
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSNumber *tms = @([[NSDate date] timeIntervalSince1970]);
    NSString *sign = [NSString stringWithFormat:@"%@%@%@shayu-inc-shark", appKey, version, tms];
    sign = [SecurityManager md5:sign];
    if (sign.length >= 8) {
        sign = [sign substringWithRange:NSMakeRange(2, 6)];
    }
    NSString *urlString = [@"https://api.shayujizhang.com/top/" stringByAppendingFormat:@"%@/%@/?tms=%@&sign=%@", appKey, version, tms, sign];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setTimeoutInterval: 5];
    [request setHTTPShouldHandleCookies:FALSE];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                
                if ([dict isKindOfClass:[NSDictionary class]]) {
                    [[SKRating sharedRating] sk_showRating:appID controller:controller dict:dict finish:finish];
                } else {
                    [self onlineConfigShowappID:appID controller:(UIViewController *)controller finish:finish];
                }
            } else {
                [self onlineConfigShowappID:appID controller:(UIViewController *)controller finish:finish];
            }
        });

    }];
    [task resume];
}

+ (void)onlineConfigShowappID:(NSString *)appID controller:(UIViewController *)controller finish:(void(^)(BOOL success))finish {
    BOOL showRating = [[SKOnlineConfig getConfigParams:@"showRating" defaultValue:@"0"] boolValue];
    if (!showRating) {
        if (finish) {
            finish(NO);
        }
        return;
    }

    NSDictionary *paramsDict = [SKOnlineConfig getJSONConfigParams:@"ratingContent"];
    if (![paramsDict isKindOfClass:[NSDictionary class]]) {
        if (finish) {
            finish(NO);
        }
        return;
    }
    [[SKRating sharedRating] sk_showRating:(NSString *)appID controller:controller dict:paramsDict finish:finish];
}

- (void)sk_showRating:(NSString *)appID controller:(UIViewController *)controller dict:(NSDictionary *)paramsDict finish:(void(^)(BOOL success))finish {
    [self checkAppVersion];
    if (self.hasRating) {
        if (finish) {
            finish(NO);
        }
        return;
    }

    NSString *title = [paramsDict objectForKey:@"title"];
    NSString *content = [paramsDict objectForKey:@"content"];
    NSString *lTxt = [paramsDict objectForKey:@"l_txt"];
    NSInteger lAction = [[paramsDict objectForKey:@"l_action"] integerValue];
    NSString *rTxt = [paramsDict objectForKey:@"r_txt"];
    NSInteger rAction = [[paramsDict objectForKey:@"r_action"] integerValue];
    NSString *rURl = [paramsDict objectForKey:@"r_url"];
    NSInteger alertTimes = [[paramsDict objectForKey:@"alert_times"] integerValue];
    
    if ((!title && !content) || !lTxt || !rTxt) {
        if (finish) {
            finish(NO);
        }
        return;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *currentDateString = [self getCurrentDate:@"YYYY-MM-dd" forKey:@"RatingDateFormatter"];
    NSString *alertDateString = [userDefaults objectForKey:@"alertDate"];
    if (alertDateString && [alertDateString isEqualToString:currentDateString]) {//当天弹出过
        if (finish) {
            finish(NO);
        }
        return;
    }
    
    if ([userDefaults integerForKey:@"alertTimes"] >= alertTimes) {//超过弹出次数
        if (finish) {
            finish(NO);
        }
        return;
    }
    
    [SKA event:@"评价弹框" label:@"显示弹框"];
    SKAlertView *alertView = [[SKAlertView alloc] initWithTitle:title message:content delegate:nil cancelButtonTitle:nil otherButtonTitles:lTxt, rTxt, nil];
    alertView.dismiss = YES;
    [alertView show];
    alertView.handleAction = ^(SKAlertView *alertView, NSInteger buttonIndex){
        
        if (buttonIndex == 0) {//左按钮
            [SKA event:@"评价弹框" label:@"点击取消"];

            if (lAction == 1) {//直接关闭
                
            } else if (lAction == 2) {//意见反馈
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
                    [vc presentViewController:[UMFeedback feedbackModalViewController] animated:YES completion:^{
                        
                    }];
                });
            }
        } else if(buttonIndex == 1) {//右按钮
            [SKA event:@"评价弹框" label:@"点击去评价"];

            UIApplication *application = [UIApplication sharedApplication];
            if (rURl.length > 0 && [application canOpenURL:[NSURL URLWithString:rURl]]) {
                [application openURL:[NSURL URLWithString:rURl]];
            } else if (rAction == 1) {
                NSURL *url = [NSURL URLWithString:[NSString  stringWithFormat: @"itms-apps://itunes.apple.com/app/id%@?action=write-review", appID]];
                if ([application canOpenURL:url]) {
                    [application openURL:url];
                } else {
                    [SKRating goRating:appID];
                }

            } else if (rAction == 2) {
                NSURL *url = [NSURL URLWithString:[NSString  stringWithFormat: @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", appID]];
                if ([application canOpenURL:url]) {
                    [application openURL:url];
                } else {
                    [SKRating goRating:appID];
                }

            } else if (rAction == 3) {
                if([SKStoreReviewController respondsToSelector:@selector(requestReview)]){
                    [SKStoreReviewController requestReview];
                } else {
                    [SKRating goRating:appID];
                }
            } else {
                [SKRating goRating:appID];
            }
            
            [SKRating saveRating];
        } else {
            //            [SKRating saveRating];
        }
    };
    
    [self saveAlert];
    if (finish) {
        finish(YES);
    }
}

//保存提醒的日期和次数
- (void)saveAlert {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *currentDateString = [self getCurrentDate:@"YYYY-MM-dd" forKey:@"RatingDateFormatter"];
    NSInteger alertTimes = [userDefaults integerForKey:@"alertTimes"];
    alertTimes++;
    
    [userDefaults setObject:currentDateString forKey:@"alertDate"];
    [userDefaults setObject:[NSNumber numberWithInteger:alertTimes] forKey:@"alertTimes"];
    [userDefaults synchronize];
}

//获取当前时间的字符串
- (NSString *)getCurrentDate:(NSString *)dateFormatter forKey:(NSString *)key {
    
    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary] ;
    NSDateFormatter *_dateFormatter = [threadDictionary objectForKey:key] ;
    if (_dateFormatter == nil)
    {
        _dateFormatter = [[NSDateFormatter alloc] init] ;
        [_dateFormatter setDateFormat:dateFormatter];
        [threadDictionary setObject:_dateFormatter forKey:key] ;
    }
    return [_dateFormatter stringFromDate:[NSDate date]];
}

//检查版本，如果版本不一致，清除之前版本的缓存
- (void)checkAppVersion {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *ratingVersion = [userDefaults objectForKey:@"RatingAppVersion"];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    if (!ratingVersion) {//之前没有存过版本，第一次存
        
        ratingVersion = appVersion;
        [userDefaults setObject:ratingVersion forKey:@"RatingAppVersion"];
    }else if(![ratingVersion isEqualToString:appVersion]) {//版本升级，清空之前缓存
        
        ratingVersion = appVersion;
        [userDefaults setObject:ratingVersion forKey:@"RatingAppVersion"];
        
        //清楚之前版本的缓存
        [userDefaults removeObjectForKey:HASRATING];
        [userDefaults removeObjectForKey:@"alertTimes"];
    }
    [userDefaults synchronize];
}

- (BOOL)hasRating {
    return  [[NSUserDefaults standardUserDefaults] boolForKey:HASRATING];
}

+ (void)saveRating {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:HASRATING];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+ (void)goAppStore:(NSString*)appID controller:(UIViewController *)controller {
    if (![appID isKindOfClass:[NSString class]]) {
        return;
    }
    // 打开应用内购买
    SKStoreProductViewController *vc = [[SKStoreProductViewController alloc] init];
    
    vc.delegate = [SKRating sharedRating];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:appID forKey:SKStoreProductParameterITunesItemIdentifier];
    [vc loadProductWithParameters:dict completionBlock:nil];
    [controller presentViewController:vc animated:YES completion:nil];
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

+ (void)goRating:(NSString *)appID {
    if (![appID isKindOfClass:[NSString class]]) {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString  stringWithFormat: @"itms-apps://itunes.apple.com/app/id%@?action=write-review", appID]];
    
    UIApplication *application = [UIApplication sharedApplication];
    if ([application canOpenURL:url]) {
        [application openURL:url];
        return;
    }
    
    url = [NSURL URLWithString:[NSString  stringWithFormat: @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", appID]];
    if ([application canOpenURL:url]) {
        [application openURL:url];
        return;
    }
    
    url = [NSURL URLWithString:[NSString  stringWithFormat: @"https://itunes.apple.com/app/id%@", appID]];
    if ([application canOpenURL:url]) {
        [application openURL:url];
        return;
    }
}

@end
