//
//  GDTCustomView.h
//  Tally
//
//  Created by 冯 传祥 on 2016/10/24.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GDTCustomView : UIButton

@property (nonatomic, copy) void(^loadFinishBlock)(CGFloat height);
@property (nonatomic, copy) NSString *eventId;//!<模块名，统计用到的事件Id


/**
 *  构造方法
 @param frame       frame
 @param appkey      应用id
 @param placementId 广告位id
 @param controller  开发者需传入用来弹出目标页的ViewController，一般为当前ViewController
 @param controller  显示广告的标题
 @return GDTCustomView
 */
- (instancetype)initWithFrame:(CGRect)frame
                       appkey:(NSString *)appkey
                  placementId:(NSString *)placementId
                   controller:(UIViewController *)controller
                       adName:(NSString *)adName;

/**
 打开或关闭定时器，在viewWillAppear里面打开，viewWillDisappear关闭
 */
- (void)startTimer;
- (void)stopTimer;

@end
