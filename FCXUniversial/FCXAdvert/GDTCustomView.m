//
//  GDTCustomView.m
//  Tally
//
//  Created by 冯 传祥 on 2016/10/24.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import "GDTCustomView.h"
#import "GDTNativeAd.h"
#import "UIImageView+WebCache.h"
#import "FCXWeakTimer.h"
#import "UMMobClick/MobClick.h"
#import "FCXDefine.h"
#import "UIView+Frame.h"
#import "SKA.h"

@interface GDTCustomView () <GDTNativeAdDelegate>
{
    GDTNativeAd *_nativeAd;
    NSString *_adName;
    UILabel *_titleLabel;
    UIImageView *_imageView;
    UIImageView *_logoImageView;
}

@property (nonatomic, strong) GDTNativeAdData *adData;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation GDTCustomView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [_timer invalidate];
    _timer = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
                       appkey:(NSString *)appkey
                  placementId:(NSString *)placementId
                   controller:(UIViewController *)controller
                       adName:(NSString *)adName {
    if (self = [super initWithFrame:frame]) {
        _adName = adName;
        
        _nativeAd = [[GDTNativeAd alloc] initWithAppkey:appkey placementId:placementId];
        //            _nativeAd = [[GDTNativeAd alloc] initWithAppkey:@"appkey" placementId:@"6050404087998717"];
        
        _nativeAd.controller = controller;
        _nativeAd.delegate = self;
        [_nativeAd loadAd:1];
        [self addTarget:self action:@selector(adClickAction) forControlEvents:UIControlEventTouchUpInside];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startTimer) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopTimer) name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

- (void)startTimer {
    if (!_timer) {
        _timer = [FCXWeakTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(refreshData) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    } else {
        [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:30]];
    }
    [self refreshData];
}

- (void)stopTimer {
    [_timer setFireDate:[NSDate distantFuture]];
}

- (void)refreshData {
    [_nativeAd loadAd:1];
}

//广告点击事件
- (void)adClickAction {
    if (self.adData) {
        [_nativeAd clickAd:self.adData];

        if (self.eventId) {
            [SKA event:self.eventId label:@"点击广点通广告"];
        }
    }
}

- (void)setup:(NSString *)title imgURL:(NSString *)imgURL {
    CGFloat space = 16;

    if (!_titleLabel) {
        //推广
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(space, space, 30, 16)];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11];
        label.textColor = [UIColor blackColor];
        label.backgroundColor = [UIColor clearColor];
        label.layer.cornerRadius = 3;
        label.clipsToBounds = YES;
        label.layer.borderColor = UICOLOR_FROMRGB(0x888888).CGColor;
        label.layer.borderWidth = .5;
        label.text = _adName;
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];

        //标题
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(label.right + 5, space, self.width - label.right - space * 2 - 12, 16)];
        _titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
        _titleLabel.textColor = UICOLOR_FROMRGB(0x343233);
        [self addSubview:_titleLabel];

        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.width - 12 - space, _titleLabel.top, 12, 16)];
        arrowImageView.image = [UIImage imageNamed:@"ad_arrow"];
        [self addSubview:arrowImageView];

        _imageView = [[UIImageView alloc] init];
        _imageView.layer.shouldRasterize = YES;
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_imageView];
        
        _logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        _logoImageView.image = [UIImage imageNamed:@"gdt_logo"];
        [_imageView addSubview:_logoImageView];
    }
    
    _titleLabel.text = title;

    __weak typeof(self) weakSelf = self;
    CGFloat top = _titleLabel.bottom + 5;
    
    __weak UIImageView *weakImageView = _imageView;
    __weak UIImageView *weakLogoImageView = _logoImageView;
    [_imageView sd_setImageWithURL:[NSURL URLWithString:imgURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error && !image) {
            return ;
        }
        CGFloat height = image.size.height * ((weakSelf.frame.size.width - space * 2)/image.size.width);
        
        weakImageView.frame = CGRectMake(space, top, weakSelf.frame.size.width - space * 2, height);
        weakLogoImageView.frame = CGRectMake(5, weakImageView.frame.size.height - weakLogoImageView.frame.size.height - 5, _logoImageView.frame.size.width, weakLogoImageView.frame.size.height);
        
        weakSelf.height = top + height + space;
        if (weakSelf.loadFinishBlock) {
            weakSelf.loadFinishBlock(weakSelf.height);
        }
    }];
}

#pragma mark - GDTNativeAdDelegate
/**
 *  原生广告加载广告数据成功回调，返回为GDTNativeAdData对象的数组
 */
-(void)nativeAdSuccessToLoad:(NSArray *)nativeAdDataArray {
    self.adData = nativeAdDataArray[0];
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{

        [self setup:[weakSelf.adData.properties objectForKey:GDTNativeAdDataKeyTitle] imgURL:[weakSelf.adData.properties objectForKey:GDTNativeAdDataKeyImgUrl]];
        
        /*
         * 广告数据渲染完毕，即将展示时需调用AttachAd方法。
         */
        [_nativeAd attachAd:weakSelf.adData toView:self];
    });
}

/**
 *  原生广告加载广告数据失败回调
 */
-(void)nativeAdFailToLoad:(NSError *)error {

}

- (void)nativeAdWillPresentScreen;
{
    NSLog(@"%s", __func__);
}

/**
 *  原生广告点击之后应用进入后台时回调
 */
- (void)nativeAdApplicationWillEnterBackground;
{
    NSLog(@"%s", __func__);
}

/**
 * 原生广告点击以后，内置AppStore或是内置浏览器被关闭时回调
 */
- (void)nativeAdClosed;
{
    NSLog(@"%s", __func__);
}

@end
