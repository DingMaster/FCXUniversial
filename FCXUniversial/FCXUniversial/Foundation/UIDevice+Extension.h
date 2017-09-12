//
//  UIDevice+Extension.h
//  HBTourClient
//
//  Created by 冯 传祥 on 2016/10/14.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (Extension)

/**
 *  客户端版本号
 *
 *  @return 客户端版本号
 */
+ (NSString *)clientVersion;


/**
 *  客户端名称
 *
 *  @return 客户端名称
 */
+ (NSString *)clientName;

/**
 *  设备型号
 *
 *  @return 设备型号
 */
+ (NSString*)deviceType;

+ (NSString *)uuid;
@end
