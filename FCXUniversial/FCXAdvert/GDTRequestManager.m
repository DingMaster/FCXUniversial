//
//  GDTRequestManager.m
//  Go
//
//  Created by 冯 传祥 on 16/1/23.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import "GDTRequestManager.h"

@implementation GDTRequestManager

- (instancetype)initWithController:(UIViewController *)controller {
    if (self = [super init]) {
        _nativeAd = [[GDTNativeAd alloc] initWithAppkey:@"appkey" placementId:@"6050404087998717"];
        _nativeAd.controller = controller;
        _nativeAd.delegate = self;
        [_nativeAd loadAd:3];
    }
    return self;
}

/**
 *  原生广告加载广告数据成功回调，返回为GDTNativeAdData对象的数组
 */
-(void)nativeAdSuccessToLoad:(NSArray *)nativeAdDataArray {
    [self.dataArray addObjectsFromArray:nativeAdDataArray];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.requestSuccessBlcok) {
            self.requestSuccessBlcok(self.dataArray);
        }
    });
}

/**
 *  原生广告加载广告数据失败回调
 */
-(void)nativeAdFailToLoad:(NSError *)error {

}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

@end
