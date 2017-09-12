//
//  FCXWebView.h
//  SKWeb
//
//  Created by fcx on 2017/9/12.
//  Copyright © 2017年 冯 传祥. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FCXWebView : UIWebView

@property (nonatomic, copy) NSString *urlString;

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
 *  @param JSONHandler   返回JSON格式的回调
 */
- (void)registerHandler:(NSString*)handlerName JSONHandler:(void (^)(id obj))JSONHandler;

/**
 *  Native调用H5
 *
 *  @param handlerName 函数名
 *  @param data        传给H5的数据
 */
- (void)callHandler:(NSString*)handlerName data:(id)data;

/**
 *  设置WebView的代理
 *
 *  @param webViewDelegate 代理
 *
 *  @note 之前的delegate不能使用
 */
- (void)setWebViewDelegate:(id<UIWebViewDelegate>)webViewDelegate;

- (void)loadURL:(NSURL *)url;
- (void)loadURLString:(NSString *)urlString;

@end
