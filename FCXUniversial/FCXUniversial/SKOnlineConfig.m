//
//  SKOnlineConfig.m
//  Tally
//
//  Created by 冯 传祥 on 2017/7/24.
//  Copyright © 2017年 冯 传祥. All rights reserved.
//

#import "SKOnlineConfig.h"
#import "SecurityManager.h"

static NSString *const SKOnlineConfigType = @"SKOnlineConfigType";

@interface SKOnlineConfig ()

@property (nonatomic, unsafe_unretained) BOOL isUseSKSelfConfig;//是否使用自己的参数配置

@end

@implementation SKOnlineConfig
{
    NSDictionary *_configDict;
    NSString *_appKey;
    NSDate *_date;
}

+ (instancetype)sharedOnlineConfig {
    static SKOnlineConfig *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SKOnlineConfig alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _configDict = [NSDictionary dictionaryWithContentsOfFile:[[self documentsPath] stringByAppendingPathComponent:@"SKOnlineConfig.plist"]];
        NSString *configType = [[NSUserDefaults standardUserDefaults] stringForKey:SKOnlineConfigType];
        if (configType) {
            _isUseSKSelfConfig = [configType isEqualToString:@"1"];
        } else {
            _isUseSKSelfConfig = YES;
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    _date = [NSDate date];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if (_date) {
        NSDate *currentDate = [NSDate date];
        double duration = [currentDate timeIntervalSinceDate:_date];
        if (duration >= 12 * 60 * 60) {//超过12小时再次请求
            [SKOnlineConfig startWithAppKey:_appKey];
        }
    }
}

- (void)judgeConfigType:(NSString *)appKey finish:(dispatch_block_t)finish {
    _appKey = appKey;
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSNumber *tms = @([[NSDate date] timeIntervalSince1970]);
    NSString *sign = [NSString stringWithFormat:@"%@%@%@%@shayu-inc-shark", _appKey, @"SKOnlineConfigType", version, tms];
    sign = [SecurityManager md5:sign];
    if (sign.length >= 8) {
        sign = [sign substringWithRange:NSMakeRange(2, 6)];
    }
    NSString *urlString = [@"https://api.shayujizhang.com/" stringByAppendingFormat:@"params/%@/SKOnlineConfigType/%@/?tms=%@&sign=%@", appKey, version, tms, sign];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setTimeoutInterval: 5];
    [request setHTTPShouldHandleCookies:FALSE];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *configType;
        if (data) {
            configType = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (configType.length > 0) {//请求到自己的
                _isUseSKSelfConfig = [configType isEqualToString:@"1"];
                [[NSUserDefaults standardUserDefaults] setObject:configType forKey:SKOnlineConfigType];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }

        if (configType.length < 1) {//未请求到自己的参数
            //先请求腾讯的
            configType = [SKOnlineConfig MTAGetConfigParameters:@"SKOnlineConfigType" defaultValue:nil];
            if (!configType) {//未取到腾讯的，取本地的
                configType = [[NSUserDefaults standardUserDefaults] stringForKey:SKOnlineConfigType];
            }
            if (configType) {//能够拿到参数
                [[NSUserDefaults standardUserDefaults] setObject:configType forKey:SKOnlineConfigType];
                [[NSUserDefaults standardUserDefaults] synchronize];
                _isUseSKSelfConfig = [configType isEqualToString:@"1"];
            } else {//没有缓存，并全未请求到，默认使用自己的
                _isUseSKSelfConfig = YES;
            }
        }
        if (finish) {
            finish();
        }
    }];
    [task resume];
}

+ (void)startWithAppKey:(NSString *)appKey {
    [[SKOnlineConfig sharedOnlineConfig] judgeConfigType:appKey finish:^{
        if ([SKOnlineConfig sharedOnlineConfig].isUseSKSelfConfig) {//请求自己的参数
            NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            NSNumber *tms = @([[NSDate date] timeIntervalSince1970]);
            NSString *sign = [NSString stringWithFormat:@"%@%@%@%@shayu-inc-shark", appKey, version, @"all", tms];
            sign = [SecurityManager md5:sign];
            if (sign.length >= 8) {
                sign = [sign substringWithRange:NSMakeRange(2, 6)];
            }
            NSString *urlString = [@"https://api.shayujizhang.com/" stringByAppendingFormat:@"params/%@/%@/all/?tms=%@&sign=%@", appKey, version, tms, sign];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
            [request setTimeoutInterval: 30];
            [request setHTTPShouldHandleCookies:FALSE];
            [request setHTTPMethod:@"GET"];
            
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (data) {
                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                    if ([dict isKindOfClass:[NSDictionary class]]) {
                        [[SKOnlineConfig sharedOnlineConfig] saveConfig:dict];
                    }
                }
            }];
            [task resume];
        }
    }];
}

- (void)saveConfig:(NSDictionary *)dict {
    _configDict = dict;
    [_configDict writeToFile:[[self documentsPath] stringByAppendingPathComponent:@"SKOnlineConfig.plist"] atomically:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:SKOnlineConfigDidFinishNotification object:nil];
    });
}

- (NSString *)documentsPath {
    return  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

- (NSString *)skGetConfigParams:(NSString *)key defaultValue:(NSString *)defaultValue {
    if (!key) {
        return nil;
    }
    NSString *value = _configDict[key];
    if (!value) {
        value = defaultValue;
    }
    return value;
}

+ (NSString *)getConfigParams:(NSString *)key {
    return [self getConfigParams:key defaultValue:nil];
}

+ (NSString *)getConfigParams:(NSString *)key defaultValue:(NSString *)defaultValue {
    if ([SKOnlineConfig sharedOnlineConfig].isUseSKSelfConfig) {
        return [[SKOnlineConfig sharedOnlineConfig] skGetConfigParams:key defaultValue:defaultValue];
    } else {
        return [SKOnlineConfig MTAGetConfigParameters:key defaultValue:defaultValue];
    }
}

+ (BOOL)getBoolConfigParams:(NSString *)key {
    return [self getBoolConfigParams:key defaultValue:@"0"];
}

+ (BOOL)getBoolConfigParams:(NSString *)key defaultValue:(NSString *)defaultValue {
    return [[self getConfigParams:key defaultValue:defaultValue] boolValue];
}

+ (id)getJSONConfigParams:(NSString *)key {
    NSString *paramsString = [self getConfigParams:key defaultValue:nil];
    if (![paramsString isKindOfClass:[NSString class]]) {
        return nil;
    }
    return [NSJSONSerialization JSONObjectWithData:[paramsString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
}

#pragma mark - MTA
+ (NSString *)MTAGetConfigParameters:(NSString *)key defaultValue:(NSString *)defaultValue {
    Class MTAConfig = NSClassFromString(@"MTAConfig");
    if (!MTAConfig) {
        NSLog(@"请导入腾讯统计库MTA");
        return nil;
    }
    
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    appVersion = [appVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSString *versionParam = [NSString stringWithFormat:@"%@_%@", key, appVersion];
    NSString *result = [[MTAConfig getInstance] getCustomProperty:versionParam default:nil];
    if (result == nil) {
        result = [[MTAConfig getInstance] getCustomProperty:key default:defaultValue];
    }
    return result;
}

+ (instancetype)getInstance {return nil;}
- (NSString *)getCustomProperty:(NSString *)key default:(NSString *)v {return @"";}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
