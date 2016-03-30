//
//  FCXDiscoverViewController.m
//  FCXUniversial
//
//  Created by 冯 传祥 on 16/3/29.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import "FCXDiscoverViewController.h"
#import "UIImageView+WebCache.h"
#import "FCXRating.h"
#import "FCXWebViewController.h"
#import "UIButton+Transform.h"
#import "FCXOnlineConfig.h"
#import "FCXDefine.h"
#import "MobClick.h"
#import "UIViewController+Advert.h"

#define IMAGE_WIDTH 40

@interface MButton : UIButton

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, weak) UIViewController *controller;

@end

@implementation MButton

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - IMAGE_WIDTH)/2.0, (self.frame.size.width - IMAGE_WIDTH)/2.0 - 10, IMAGE_WIDTH,  IMAGE_WIDTH)];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_iconImageView];
        
        [self addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _iconImageView;
}

- (void)setData:(NSDictionary *)data {
    if (_data != data) {
        _data = data;
        [self setTitle:data[@"title"] forState:UIControlStateNormal];
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:data[@"icon"]]];
    }
}

- (void)buttonAction {
    [MobClick event:@"发现" label:self.data[@"title"]];
    NSString *url = self.data[@"url"];
    if (url && url.length > 0) {//h5
        FCXWebViewController *webView = [[FCXWebViewController alloc] init];
        webView.hidesBottomBarWhenPushed = YES;
        webView.urlString = url;
        webView.title = self.data[@"title"];
        [self.controller.navigationController pushViewController:webView animated:YES];
    }else {
        [FCXRating goAppStore:self.data[@"appid"]];
    }
}

@end



@interface FCXDiscoverViewController ()

@end

@implementation FCXDiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"发现";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    NSString *paramsString = [FCXOnlineConfig fcxGetConfigParams:@"discover_native" defaultValue:@""];
    
    CGFloat adHeight = 0;
    if ([[FCXOnlineConfig fcxGetConfigParams:@"showAdmob" defaultValue:@"1"] boolValue]) {
        adHeight = 50;
        [self showAdmobBanner:CGRectMake(0, SCREEN_HEIGHT - 64 - 50, SCREEN_WIDTH, 50) adUnitID:[FCXOnlineConfig fcxGetConfigParams:@"AdmobID" defaultValue:ADMOBID]];
    }
    
    NSArray *array  = [NSJSONSerialization JSONObjectWithData:[paramsString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    if ([array isKindOfClass:[NSArray class]]) {
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - adHeight)];
        [self.view addSubview:scrollView];
        NSInteger row;
        if (array.count %4 == 0) {
            row = array.count/4;
        }else {
            row = array.count/4 + 1;
        }
        CGFloat space = .5;
        CGFloat width = (SCREEN_WIDTH - 3 * 0.5)/4.0;
        
        scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, MAX(row * (width + space) + .5, scrollView.frame.size.height + .5));
        scrollView.userInteractionEnabled = YES;
        scrollView.backgroundColor = UICOLOR_FROMRGB(0xffffff);
        
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            MButton *btn = [MButton buttonWithType:UIButtonTypeCustom];
            btn.controller = self;
            btn.needTransform = YES;
            btn.frame = CGRectMake((idx%4) * (width + space), (idx/4) * (width + space), width, width);
            btn.backgroundColor = [UIColor clearColor];
            [btn setTitleColor:UICOLOR_FROMRGB(0x343233) forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
            btn.titleEdgeInsets = UIEdgeInsetsMake((width - IMAGE_WIDTH)/2 + 20, 0, 0, 0);
            btn.data = obj;
            [scrollView addSubview:btn];
        }];
        //        80 93 103
        for (int i = 0; i < 3; i++) {
            UIView *verLine = [[UIView alloc] initWithFrame:CGRectMake(width + i * (width + space), 0, .5, row * (width + space))];
            verLine.backgroundColor = UICOLOR_FROMRGB(0xd9d9d9);
            [scrollView addSubview:verLine];
        }
        
        for (int i = 0; i <= row; i++) {
            UIView *horLine = [[UIView alloc] initWithFrame:CGRectMake(0, i * (width + space), SCREEN_WIDTH, .5)];
            horLine.backgroundColor = UICOLOR_FROMRGB(0xd9d9d9);
            [scrollView addSubview:horLine];
        }
    }
}



@end
