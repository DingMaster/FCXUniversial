//
//  GDTNativeView.h
//  Go
//
//  Created by 冯 传祥 on 16/1/23.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDTNativeAd.h"

@interface GDTNativeView : UIView


@property (nonatomic, strong) GDTNativeAd *nativeAd;;
@property (nonatomic, strong) GDTNativeAdData *adData;

@end
