//
//  SKRating.h
//  Tally
//
//  Created by 冯 传祥 on 2017/7/29.
//  Copyright © 2017年 冯 传祥. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKRating : NSObject

/**
 *  调用评价
 *
 *  @param appID 当前应用的appID
 *  @param finish 好评逻辑完成后的回调
 */
+ (void)startRating:(NSString*)appID
            apppKey:(NSString *)appKey
         controller:(UIViewController *)controller
             finish:(void(^)(BOOL success))finish;
+ (void)goAppStore:(NSString*)appID controller:(UIViewController *)controller;//!<下载页
+ (void)goRating:(NSString *)appID;//!<评价页

@end
