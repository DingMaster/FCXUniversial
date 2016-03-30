//
//  AppDelegate+GS.h
//  Camera
//
//  Created by 冯 传祥 on 16/3/17.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import "AppDelegate.h"
#import "GDTSplashAd.h"

@interface AppDelegate (GS) <GDTSplashAdDelegate>

@property (nonatomic, strong) GDTSplashAd *splash;
@property (nonatomic, strong) UIImageView *customSplashView;

@end
