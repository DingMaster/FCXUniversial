//
//  FCXWebView.m
//  SKWeb
//
//  Created by fcx on 2017/9/12.
//  Copyright © 2017年 冯 传祥. All rights reserved.
//

#import "FCXWebView.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface FCXWebView () <UIWebViewDelegate>
{
    NSMutableDictionary *_messageHandlersDict;
    __weak id _webViewDelegate;
    JSContext *_context;
}

@end

@implementation FCXWebView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    _messageHandlersDict = [[NSMutableDictionary alloc] init];
    self.delegate = self;
    self.scrollView.bounces = NO;//防止弹框出现后，滑动弹框界面也会跟着滑动
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

- (void)setWebViewDelegate:(id<UIWebViewDelegate>)webViewDelegate {
    _webViewDelegate = webViewDelegate;
}

- (void)registerHandler:(NSString *)handlerName handler:(id)handler {
    if (!handlerName || !handler) {
        return;
    }
    [_messageHandlersDict setObject:[handler copy] forKey:handlerName];
}

- (void)registerHandler:(NSString *)handlerName JSONHandler:(void (^)(id))JSONHandler {
    [self registerHandler:handlerName handler:JSONHandler];
}

- (void)callHandler:(NSString *)handlerName data:(id)data {
    if (!handlerName) {
        return;
    }
    JSValue *func = [_context evaluateScript:handlerName];
    if (data) {
        [func callWithArguments:@[data]];
    } else {
        [func callWithArguments:@[]];
    }
}

- (void)loadRequest:(NSURLRequest *)request {
    [self clearCache];
    [super loadRequest:request];
}

- (void)loadURL:(NSURL *)url {
    if (!url || ![url isKindOfClass:[NSURL class]]) {
        return;
    }
    [self loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)loadURLString:(NSString *)urlString {
    if (!urlString || ![urlString isKindOfClass:[NSString class]]) {
        return;
    }
    self.urlString = urlString;
    [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //禁止复制、粘贴
    [webView stringByEvaluatingJavaScriptFromString:@"document.body.style.webkitUserSelect='none';"];
    [webView stringByEvaluatingJavaScriptFromString:@"document.body.style.webkitTouchCallout='none';"];
    
    _context = [webView  valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    for (NSString *key in _messageHandlersDict.allKeys) {
        _context[key] = _messageHandlersDict[key];
    }
    
    // 异常的回调处理
    _context.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        NSLog(@"异常信息：%@", exceptionValue);
    };
    
    if (_webViewDelegate && [_webViewDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [_webViewDelegate webViewDidFinishLoad:webView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (_webViewDelegate && [_webViewDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [_webViewDelegate webView:webView didFailLoadWithError:error];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {    
    if (_webViewDelegate && [_webViewDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        return [_webViewDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (_webViewDelegate && [_webViewDelegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [_webViewDelegate webViewDidStartLoad:webView];
    }
}

// 清除缓存
- (void)clearCache {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)dealloc {
    self.delegate = nil;
    [self stopLoading];
}

@end
