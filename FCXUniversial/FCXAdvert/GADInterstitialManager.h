//
//  GADInterstitialManager.h
//  Tally
//
//  Created by 冯 传祥 on 2017/3/18.
//  Copyright © 2017年 冯 传祥. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GADInterstitialManager : NSObject

@property (nonatomic, unsafe_unretained) BOOL autoClose;//!<自动关闭广告
@property (nonatomic, copy) dispatch_block_t interstitialEndHandle;
@property (nonatomic, copy) dispatch_block_t closeHandle;//关闭插屏


- (instancetype)initWithController:(UIViewController *)controller interstitialID:(NSString *)interstitialID;

- (void)showInterstitial;

@end
