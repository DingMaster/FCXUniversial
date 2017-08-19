//
//  SKAlertView.m
//  Tally
//
//  Created by 冯 传祥 on 2017/7/31.
//  Copyright © 2017年 冯 传祥. All rights reserved.
//

#import "SKAlertView.h"

@implementation SKAlertView

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
    if (self.dismiss) {
        [super dismissWithClickedButtonIndex:buttonIndex animated:animated];
    }
    
    if (self.handleAction) {
        self.handleAction(self, buttonIndex);
    }
}

@end
