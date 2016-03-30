//
//  UIViewController+Advert.m
//  FCXAdvert
//
//  Created by 冯 传祥 on 16/1/23.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import "UIViewController+Advert.h"
#import <objc/runtime.h>

@implementation UIViewController (Advert)

@dynamic gdtRequestManager;


#pragma mark - 广点通

- (GDTRequestManager *)gdtRequestManager {
    GDTRequestManager *gdtRequestManager = objc_getAssociatedObject(self, _cmd);
    if (!gdtRequestManager) {
        gdtRequestManager = [[GDTRequestManager alloc] initWithController:self];
        self.gdtRequestManager = gdtRequestManager;
    }
    return gdtRequestManager;
}

- (void)setGdtRequestManager:(GDTRequestManager *)gdtRequestManager {
    objc_setAssociatedObject(self, @selector(gdtRequestManager), gdtRequestManager, OBJC_ASSOCIATION_RETAIN);
}


#pragma mark - Admob

- (void)showAdmobBanner:(CGRect)frame adUnitID:(NSString *)adUnitID {
    [self showAdmobBanner:frame adUnitID:adUnitID superView:self.view];
}

- (void)showAdmobBanner:(CGRect)frame
               adUnitID:(NSString *)adUnitID
              superView:(UIView *)superView {
    
    self.mobbannerView.frame = frame;
    self.mobbannerView.delegate = self;
    self.mobbannerView.adUnitID = adUnitID;
    self.mobbannerView.rootViewController = self;
    GADRequest *request = [GADRequest request];
#ifdef DEBUG
    request.testDevices = @[
                            @"kGADSimulatorID",
                            @"f8231c85289a86089a541f6318fe5e5f",  // iphone4s
                            @"f8b4c976eaaf84ec7ca039fdf5aa5a1e"
                            ];
#endif
    
    [self.mobbannerView loadRequest:request];
    [superView addSubview:self.mobbannerView];
}


- (GADBannerView *)mobbannerView {
    GADBannerView *mobBannerView = objc_getAssociatedObject(self, _cmd);
    if (!mobBannerView) {
        mobBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
        self.mobbannerView = mobBannerView;
    }
    return mobBannerView;
}

- (void)setMobbannerView:(GADBannerView *)mobbannerView {
    objc_setAssociatedObject(self, @selector(mobbannerView), mobbannerView, OBJC_ASSOCIATION_RETAIN);
}

#pragma mark - GADBannerViewDelegate

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView;
{
    //    NSLog(@"%s", __func__);
}
/// Tells the delegate that an ad request failed. The failure is normally due to network
/// connectivity or ad availablility (i.e., no fill).
- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error; {
    //    NSLog(@"%s info%@", __func__, error.localizedDescription);
}


@end
