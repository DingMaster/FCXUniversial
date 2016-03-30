//
//  GDTNativeView.m
//  Go
//
//  Created by 冯 传祥 on 16/1/23.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import "GDTNativeView.h"


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation GDTNativeView
{
    UIImageView *_imageView;
    UILabel *_titleLabel;
    UILabel *_subTitleLabel;
}



- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 头像图片
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 60, 60)];
        _imageView.layer.shouldRasterize = YES;
        _imageView.layer.cornerRadius = 27;
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_imageView];
        
        //推广
        //标题
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(80, 15 + 5, 30, 15)];
        label.font = [UIFont systemFontOfSize:11];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = UIColorFromRGB(0xdadada);
        label.layer.cornerRadius = 3;
        label.clipsToBounds = YES;
        label.text = @"推广";
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        
        //标题
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80 + 35, 15, [UIScreen mainScreen].bounds.size.width - 80 - 60 - 35, 25)];
        _titleLabel.font = [UIFont systemFontOfSize:16];
//        _titleLabel.textColor = BERGBColor(38.0, 38.0, 38.0);
        [self addSubview:_titleLabel];
        
        //副标题
        _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 40, _titleLabel.frame.size.width, 15)];
        _subTitleLabel.textColor = [UIColor grayColor];
        _subTitleLabel.textAlignment = NSTextAlignmentLeft;
        _subTitleLabel.font = [UIFont systemFontOfSize:11];
        [self addSubview:_subTitleLabel];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        btn.frame = CGRectMake(kScreenWidth - 60, 20, 50, 30);
        //        btn.layer.shouldRasterize = YES;
        btn.layer.cornerRadius = 3;
//        btn.backgroundColor = BellColor;
        [btn setTitle:@"下载" forState:UIControlStateNormal];
//        [btn setTitleColor:MAIN_BLACKCOLOR forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:btn];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)tapAction {
    [self.nativeAd clickAd:_adData];
}

- (void)setAdData:(GDTNativeAdData *)adData {
    if (_adData != adData) {
        _adData = adData;
        
//        [_imageView sd_setImageWithURL:[NSURL URLWithString:[adData.properties objectForKey:GDTNativeAdDataKeyIconUrl]]];
        _titleLabel.text = [NSString stringWithFormat:@"推广 %@", [adData.properties objectForKey:GDTNativeAdDataKeyTitle]];
        _subTitleLabel.text = [adData.properties objectForKey:GDTNativeAdDataKeyDesc];
        /*
         * 广告数据渲染完毕，即将展示时需调用AttachAd方法。
         */
        [self.nativeAd attachAd:adData toView:self];
    }
}

@end
