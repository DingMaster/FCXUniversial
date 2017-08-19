//
//  SKAlertView.h
//  Tally
//
//  Created by 冯 传祥 on 2017/7/31.
//  Copyright © 2017年 冯 传祥. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKAlertView : UIAlertView

typedef void(^HandleActionBlock)(SKAlertView *alertView, NSInteger buttonIndex);

@property(nonatomic, copy) HandleActionBlock handleAction;
@property(nonatomic, unsafe_unretained)BOOL dismiss;

@end
