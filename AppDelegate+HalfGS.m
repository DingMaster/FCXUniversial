//
//  AppDelegate+HalfGS.m
//  Finance
//
//  Created by 冯 传祥 on 16/4/24.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import "AppDelegate+HalfGS.h"
#import <objc/runtime.h>
#import "FCXGuide.h"
#import "FCXOnlineConfig.h"

@implementation AppDelegate (HalfGS)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethodWithClass:[self class] originalSelector:@selector(application:didFinishLaunchingWithOptions:) swizzledMethod:@selector(fcx_application:didFinishLaunchingWithOptions:)];
        
        [self swizzleInstanceMethodWithClass:[self class] originalSelector:@selector(applicationDidEnterBackground:) swizzledMethod:@selector(fcx_applicationDidEnterBackground:)];
        
        [self swizzleInstanceMethodWithClass:[self class] originalSelector:@selector(applicationWillEnterForeground:) swizzledMethod:@selector(fcx_applicationWillEnterForeground:)];
    });
}

- (BOOL)fcx_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupS];
    return [self fcx_application:application didFinishLaunchingWithOptions:launchOptions];
}

//app已经进入后台后
- (void)fcx_applicationDidEnterBackground:(UIApplication *)application {
    self.enterBackgroundDate = [NSDate date];
    [self fcx_applicationDidEnterBackground:application];
}

//app将要进入前台
- (void)fcx_applicationWillEnterForeground:(UIApplication *)application {
    if (self.enterBackgroundDate) {
        NSDate *currentDate = [NSDate date];
        double duration = [currentDate timeIntervalSinceDate:self.enterBackgroundDate];
        if (duration >= 30 * 60) {//超过30分钟再次显示开屏
            [self setupS];
        }
    }
    [self fcx_applicationWillEnterForeground:application];
}

- (void)setupS {
    
    BOOL showSplash;
    
    if ([FCXOnlineConfig fcxGetConfigParams:@"showSplash"]) {
        showSplash = [[FCXOnlineConfig fcxGetConfigParams:@"showSplash"] boolValue];
    }else {//首次进入应用，请求不到友盟的参数，根据日期判断是否显示
        NSDate *currentDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat: @"yyyy-MM-dd"];
        NSString *currentDateString = [dateFormatter stringFromDate:currentDate];
        
        showSplash = ([currentDateString compare:@"2016-05-10"] == NSOrderedDescending);
    }

    if (!showSplash) {
        [FCXGuide startGuide];
        return;
    }
    
    NSString *appKey = @"1105280859";
    NSString *placementId = @"1010512077974527";
    
    NSString *paramsString = [FCXOnlineConfig fcxGetConfigParams:@"GDT_SplashInfo" defaultValue:@""];
    NSDictionary *dict  = [NSJSONSerialization JSONObjectWithData:[paramsString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    if([dict isKindOfClass:[NSDictionary class]]){
        appKey = dict[@"appkey"];;
        placementId = dict[@"placementId"];
    }
    
    //开屏广告初始化
    self.splash = [[GDTSplashAd alloc] initWithAppkey:appKey placementId:placementId];
    self.splash.delegate = self;//设置代理
    
    self.customSplashView = [[UIImageView alloc]initWithFrame:self.window.bounds];
    self.customSplashView.userInteractionEnabled = YES;
    
    self.windowCoverView = [[UIImageView alloc] initWithFrame:self.window.bounds];
    self.windowCoverView.userInteractionEnabled = YES;
    
    //针对不同设备尺寸设置不同的默认图片，拉取广告等待时间会展示该默认图片。
    CGSize winSize = self.window.frame.size;
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary* dict in imagesDict) {
        if(CGSizeEqualToSize(CGSizeFromString(dict[@"UILaunchImageSize"]),winSize))
        {
            self.customSplashView.image = [UIImage imageNamed:dict[@"UILaunchImageName"]];
            self.windowCoverView.image = self.customSplashView.image;
            self.splash.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:dict[@"UILaunchImageName"]]];
            break;
        }
    }
    
    [self.window.rootViewController.view addSubview:self.customSplashView];
    [self.window addSubview:self.windowCoverView];
    
    //设置开屏拉取时长限制，若超时则不再展示广告
    self.splash.fetchDelay = 3;
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 120)];
    bottomView.backgroundColor = [UIColor clearColor];
    //拉取并展示
    [self.splash loadAdAndShowInWindow:self.window withBottomView:bottomView];
}


-(void)splashAdSuccessPresentScreen:(GDTSplashAd *)splashAd
{
        DBLOG(@"%s",__FUNCTION__);
}

-(void)splashAdFailToPresent:(GDTSplashAd *)splashAd withError:(NSError *)error
{
        DBLOG(@"%s%@",__FUNCTION__,error);
    [self clearSplashData];
}

-(void)splashAdClicked:(GDTSplashAd *)splashAd
{
        DBLOG(@"%s",__FUNCTION__);
    [self clearSplashData];
}

-(void)splashAdWillPresentFullScreenModal:(GDTSplashAd *)splashAd
{
        DBLOG(@"%s",__FUNCTION__);
}

-(void)splashAdApplicationWillEnterBackground:(GDTSplashAd *)splashAd
{
        DBLOG(@"%s",__FUNCTION__);
}

-(void)splashAdClosed:(GDTSplashAd *)splashAd
{
        DBLOG(@"%s",__FUNCTION__);
    [self clearSplashData];
}

- (void)splashAdDidDismissFullScreenModal:(GDTSplashAd *)splashAd {
        DBLOG(@"%s",__FUNCTION__);
    [self clearSplashData];
}

- (void)clearSplashData {
    [self.customSplashView removeFromSuperview];
    [self.windowCoverView removeFromSuperview];
    self.windowCoverView = nil;
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

- (GDTSplashAd *)splash {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setSplash:(GDTSplashAd *)splash {
    objc_setAssociatedObject(self, @selector(splash), splash, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImageView *)customSplashView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setCustomSplashView:(UIImageView *)customSplashView {
    objc_setAssociatedObject(self, @selector(customSplashView), customSplashView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImageView *)windowCoverView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setWindowCoverView:(UIImageView *)windowCoverView {
    objc_setAssociatedObject(self, @selector(windowCoverView), windowCoverView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDate *)enterBackgroundDate {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setEnterBackgroundDate:(NSDate *)enterBackgroundDate {
    objc_setAssociatedObject(self, @selector(enterBackgroundDate), enterBackgroundDate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
