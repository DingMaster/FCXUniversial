//
//  FCXAboutController.h
//  FCXUniversial
//
//  Created by 冯 传祥 on 16/4/13.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FCXAboutController : UIViewController


/**
 *  图片名(必须填写).
 *  现在固定显示大小是130*130
 */
@property (nonatomic, copy) NSString *imageName;

/**
 *  第一行显示的产品名(可不写).
 *  默认取CFBundleDisplayName的名字.
 */
@property (nonatomic, copy) NSString *appName;

/**
 *  中间显示的一段描述(必须填写).
 */
@property (nonatomic, copy) NSString *midString;

/**
 *  是否显示下面三行.
 *  默认不显示.
 */
@property (nonatomic, unsafe_unretained) BOOL showBottom;

/**
 *  底部左边文案(可不写，注意换行分割).
 *  默认是：@"产品：\n设计：\n工程师："，
 */
@property (nonatomic, copy) NSString *bottomLeftString;

/**
 *  底部右边文案(如果显示下面三行则必须填写，注意换行分割).
 *  根据情况填写，如：@"杨磊\n张丹丹\n冯传祥".
 */
@property (nonatomic, copy) NSString *bottomRightString;


@end
