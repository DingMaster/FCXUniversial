//
//  GDTRequestManager.h
//  Go
//
//  Created by 冯 传祥 on 16/1/23.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDTNativeView.h"

typedef void (^ ADRequestSuccessBlock)(NSMutableArray *adDataArray);

@interface GDTRequestManager : NSObject <GDTNativeAdDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) GDTNativeAd *nativeAd;
@property (nonatomic, copy) ADRequestSuccessBlock requestSuccessBlcok;

- (instancetype)initWithController:(UIViewController *)controller;


@end
