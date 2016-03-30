//
//  UIViewController+Advert.h
//  FCXAdvert
//
//  Created by 冯 传祥 on 16/1/23.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GDTRequestManager.h"
@import GoogleMobileAds;


@interface UIViewController (Advert) <GADBannerViewDelegate>

@property (nonatomic, strong) GDTRequestManager *gdtRequestManager;
@property (nonatomic, strong) GADBannerView *mobbannerView;

- (void)showAdmobBanner:(CGRect)frame adUnitID:(NSString *)adUnitID;

- (void)showAdmobBanner:(CGRect)frame
               adUnitID:(NSString *)adUnitID
              superView:(UIView *)superView;

@end
