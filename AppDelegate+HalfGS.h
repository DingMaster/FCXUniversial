//
//  AppDelegate+HalfGS.h
//  Finance
//
//  Created by 冯 传祥 on 16/4/24.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import "AppDelegate.h"
#import "GDTSplashAd.h"

@interface AppDelegate (HalfGS) <GDTSplashAdDelegate>

@property (nonatomic, strong) GDTSplashAd *splash;
@property (nonatomic, strong) UIImageView *customSplashView;
@property (nonatomic, strong) UIImageView *windowCoverView;

@end
