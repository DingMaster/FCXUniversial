//
//  AppDelegate+BS.m
//  FCXNews
//
//  Created by 冯 传祥 on 16/5/21.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import "AppDelegate+BS.h"
#import <objc/runtime.h>
#import "FCXGuide.h"
#import "FCXOnlineConfig.h"

@implementation AppDelegate (BS)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethodWithClass:[self class] originalSelector:@selector(application:didFinishLaunchingWithOptions:) swizzledMethod:@selector(fcx_application:didFinishLaunchingWithOptions:)];
        
        [self swizzleInstanceMethodWithClass:[self class] originalSelector:@selector(applicationDidEnterBackground:) swizzledMethod:@selector(fcx_applicationDidEnterBackground:)];
        
        [self swizzleInstanceMethodWithClass:[self class] originalSelector:@selector(applicationWillEnterForeground:) swizzledMethod:@selector(fcx_applicationWillEnterForeground:)];
    });
}

- (BOOL)fcx_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupBaiduSplash];
    return [self fcx_application:application didFinishLaunchingWithOptions:launchOptions];
}

//app已经进入后台后
- (void)fcx_applicationDidEnterBackground:(UIApplication *)application {
    self.enterBackgroundDate = [NSDate date];
}

//app将要进入前台
- (void)fcx_applicationWillEnterForeground:(UIApplication *)application {
    if (self.enterBackgroundDate) {
        NSDate *currentDate = [NSDate date];
        double duration = [currentDate timeIntervalSinceDate:self.enterBackgroundDate];
        if (duration >= 30 * 60) {//超过30分钟再次显示开屏
            [self setupBaiduSplash];
        }
    }
}

- (void)setupBaiduSplash {
    
    BOOL showSplash;
    
    if ([FCXOnlineConfig fcxGetConfigParams:@"showSplash"]) {
        showSplash = [[FCXOnlineConfig fcxGetConfigParams:@"showSplash"] boolValue];
    }else {//首次进入应用，请求不到友盟的参数，根据日期判断是否显示
        NSDate *currentDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat: @"yyyy-MM-dd"];
        NSString *currentDateString = [dateFormatter stringFromDate:currentDate];
        
        showSplash = ([currentDateString compare:@"2016-02-29"] == NSOrderedDescending);
    }
    showSplash = YES;
    if (!showSplash) {
        [FCXGuide startGuide];
        return;
    }
    
    BaiduMobAdSplash *splash = [[BaiduMobAdSplash alloc] init];
    splash.delegate = self;
    //把在mssp.baidu.com上创建后获得的代码位id写到这里
    splash.AdUnitTag = [FCXOnlineConfig fcxGetConfigParams:@"BD_AdID" defaultValue:@"2058492"];
    splash.canSplashClick = YES;
    self.splash = splash;
    //    NSLog(@"bouds %@", NSStringFromCGRect(self.window.bounds));
    self.customSplashView = [[UIImageView alloc]initWithFrame:self.window.bounds];
    self.customSplashView.userInteractionEnabled = YES;
    
    CGSize winSize = self.window.frame.size;
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary* dict in imagesDict) {
        if(CGSizeEqualToSize(CGSizeFromString(dict[@"UILaunchImageSize"]),winSize))
        {
            self.customSplashView.image = [UIImage imageNamed:dict[@"UILaunchImageName"]];
            break;
        }
    }
    
    self.customSplashView.backgroundColor = [UIColor whiteColor];
    [self.window.rootViewController.view addSubview:self.customSplashView];
    
    UIView * baiduSplashContainer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, winSize.width, winSize.height-120)];
    [self.customSplashView addSubview:baiduSplashContainer];
    
    [splash loadAndDisplayUsingContainerView:baiduSplashContainer];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 75, 20, 60, 30);
    closeBtn.tag = 100;
    [closeBtn setTitle:@"跳过" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    closeBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:.6];
    closeBtn.layer.cornerRadius = 2;
    [self.customSplashView addSubview:closeBtn];
    closeBtn.hidden = YES;
    [closeBtn addTarget:self action:@selector(clearSplashData) forControlEvents:UIControlEventTouchUpInside];
}

- (NSString *)publisherId
{
    return [FCXOnlineConfig fcxGetConfigParams:@"BD_AppID" defaultValue:@"ccb60059"];
}

/**
 *  广告展示成功
 */
- (void)splashSuccessPresentScreen:(BaiduMobAdSplash *)splash
{
        NSLog(@"splashSuccessPresentScreen");
    UIButton *btn = [self.customSplashView viewWithTag:100];
    btn.hidden = NO;
    [self.customSplashView bringSubviewToFront:btn];
}

/**
 *  广告展示失败
 */
- (void)splashlFailPresentScreen:(BaiduMobAdSplash *)splash withError:(BaiduMobFailReason) reason
{
        NSLog(@"splashlFailPresentScreen withError:%d",reason);
    //自定义开屏移除
    [self clearSplashData];
}

/**
 *  广告展示结束
 */
- (void)splashDidDismissScreen:(BaiduMobAdSplash *)splash
{
        NSLog(@"splashDidDismissScreen");
    //自定义开屏移除
    [self clearSplashData];
}

/**
 *  广告点击
 */
- (void)splashDidClicked:(BaiduMobAdSplash *)splash
{
        NSLog(@"splashDidClicked");
}

- (void)clearSplashData {
    [self.customSplashView removeFromSuperview];
    self.splash.delegate = nil;
    self.splash = nil;
    self.customSplashView = nil;
    
    [FCXGuide startGuide];
}

+ (void)swizzleInstanceMethodWithClass:(Class)class
                      originalSelector:(SEL)originalSelector
                        swizzledMethod:(SEL)swizzledSelector {
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    if (class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
        
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }else {
        
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (BaiduMobAdSplash *)splash {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setSplash:(BaiduMobAdSplash *)splash {
    objc_setAssociatedObject(self, @selector(splash), splash, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImageView *)customSplashView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setCustomSplashView:(UIImageView *)customSplashView {
    
    objc_setAssociatedObject(self, @selector(customSplashView), customSplashView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDate *)enterBackgroundDate {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setEnterBackgroundDate:(NSDate *)enterBackgroundDate {
    objc_setAssociatedObject(self, @selector(enterBackgroundDate), enterBackgroundDate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
