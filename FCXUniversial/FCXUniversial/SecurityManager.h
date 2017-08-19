//
//  SecurityManager.h
//  Credit
//
//  Created by 冯 传祥 on 2016/11/9.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SecurityManager : NSObject

+ (NSString *)md5:(NSString *)str;
+ (NSString *)AES256StringEncrypt:(NSString *)content key:(NSString *)key;
+ (NSString *)AES256StringDecrypt:(NSString *)content key:(NSString *)key;

@end
