//
//  FCXWebViewController.h
//  Bells
//
//  Created by 冯 传祥 on 16/1/17.
//  Copyright (c) 2016年 冯 传祥. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCXWebView.h"

@interface FCXWebViewController : UIViewController

@property (nonatomic, strong, readonly) FCXWebView *webView;
@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, copy) NSString *admobID;
@property (nonatomic, strong) UIColor *navBackColor;//!<导航条返回按钮颜色（没有默认取导航条的tinColor，再取不
@property (nonatomic, strong) UIImage *backImage;
@property (nonatomic, strong) UIImage *backImageHighlighted;
@property (nonatomic, strong) UIColor *progressColor;
@property (nonatomic, unsafe_unretained) BOOL hideNavRightItem;//!<隐藏导航条右边默认分享按钮

- (void)loadRequest:(NSURLRequest *)request;
- (void)loadURL:(NSURL *)url;
- (void)loadURLString:(NSString *)urlString;

/**
 *  注册JS回调
 *
 *  @param handlerName 事件名
 *  @param handler     相应回调Block
 */
- (void)registerHandler:(NSString*)handlerName handler:(id)handler;

/**
 *  注册JS回调
 *
 *  @param handlerName 事件名
 *  @param JSONHandler     返回JSON格式的回调
 */
- (void)registerHandler:(NSString*)handlerName JSONHandler:(void (^)(id obj))JSONHandler;

/**
 *  Native调用H5
 *
 *  @param handlerName 函数名
 *  @param data        传给H5的数据
 */
- (void)callHandler:(NSString*)handlerName data:(id)data;

@end
