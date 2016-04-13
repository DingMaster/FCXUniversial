//
//  FCXAboutController.m
//  FCXUniversial
//
//  Created by 冯 传祥 on 16/4/13.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import "FCXAboutController.h"
#import "FCXDefine.h"

@interface FCXAboutController ()

@end

@implementation FCXAboutController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = UICOLOR_FROMRGB(0xf5f5f5);
    
    CGFloat statusBarHeight = 20;
    if ([UIApplication sharedApplication].statusBarHidden) {
        statusBarHeight = 0;
    }
    CGFloat top = 78;
    if (SCREEN_HEIGHT == 480) {
        top = 20;
    }else if (SCREEN_HEIGHT == 568) {
        top = 40;
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 130)/2.0, top, 130, 130)];
    imageView.image = [UIImage imageNamed:self.imageName];
    [self.view addSubview:imageView];
    
    NSString *str = [NSString stringWithFormat:@"%@\n%@", self.appName, self.midString];
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:str];
    
    [attributedStr addAttribute:NSFontAttributeName
                          value:[UIFont fontWithName:@"Helvetica-Bold" size:28]
                          range:NSMakeRange(0, self.appName.length)];
    
    [attributedStr addAttribute:NSFontAttributeName
                          value:[UIFont fontWithName:@"HelveticaNeue-Light" size:16]
                          range:NSMakeRange(self.appName.length, str.length - self.appName.length)];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 10;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    [attributedStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, str.length)];
    
    CGFloat height = [attributedStr boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 20, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size.height;
    
    UILabel *midLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, imageView.frame.origin.y + imageView.frame.size.height + 10, SCREEN_WIDTH - 20, height)];
    midLabel.backgroundColor = self.view.backgroundColor;
    midLabel.textColor = UICOLOR_FROMRGB(0x343233);
    midLabel.numberOfLines = 0;
    midLabel.attributedText = attributedStr;
    [self.view addSubview:midLabel];
    
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, midLabel.frame.origin.y + midLabel.frame.size.height + 20, SCREEN_WIDTH, 15)];
    versionLabel.textColor = midLabel.textColor;
    versionLabel.textAlignment = NSTextAlignmentCenter;
    versionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    versionLabel.text = [NSString stringWithFormat:@"V %@", APP_VERSION];
    [self.view addSubview:versionLabel];
    
    if (self.showBottom) {
        attributedStr = [[NSMutableAttributedString alloc] initWithString:self.bottomLeftString];
        paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 6;
        paragraphStyle.alignment = NSTextAlignmentRight;
        [attributedStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.bottomLeftString.length)];
        
        UILabel *bottomLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 180 - statusBarHeight, SCREEN_WIDTH/2.0, 140)];
        bottomLeftLabel.textColor = UICOLOR_FROMRGB(0x343233);
        bottomLeftLabel.textAlignment = NSTextAlignmentRight;
        bottomLeftLabel.numberOfLines = 0;
        bottomLeftLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
        bottomLeftLabel.attributedText = attributedStr;
        [self.view addSubview:bottomLeftLabel];
        
        attributedStr = [[NSMutableAttributedString alloc] initWithString:self.bottomRightString];
        paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 6;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        [attributedStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.bottomRightString.length)];
        UILabel *bottomRightLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2.0, bottomLeftLabel.frame.origin.y, bottomLeftLabel.frame.size.width, bottomLeftLabel.frame.size.height)];
        bottomRightLabel.textColor = UICOLOR_FROMRGB(0x343233);
        bottomRightLabel.textAlignment = NSTextAlignmentLeft;
        bottomRightLabel.numberOfLines = 0;
        bottomRightLabel.font = bottomLeftLabel.font;
        bottomRightLabel.attributedText = attributedStr;
        [self.view addSubview:bottomRightLabel];
    }
}

- (NSString *)appName {
    if (!_appName) {
        _appName = APP_DISPLAYNAME;
    }
    return _appName;
}
- (NSString *)bottomLeftString {
    if (!_bottomLeftString) {
        _bottomLeftString = @"产品：\n设计：\n工程师：";
    }
    return _bottomLeftString;
}

@end
