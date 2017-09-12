//
//  NSDictionary+SafeValue.h
//  HBTourClient
//
//  Created by 冯 传祥 on 16/6/7.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (SafeValue)

- (nullable NSString *)stringForKey:(nonnull id)aKey;
- (nonnull NSString *)nonullStringForKey:(nonnull id)aKey;
- (NSInteger)integerForKey:(nonnull id)aKey;
- (int)intForKey:(nonnull id)aKey;
- (float)floatForKey:(nonnull id)aKey;
- (double)doubleForKey:(nonnull id)aKey;
- (BOOL)boolForKey:(nonnull id)aKey;
- (nullable NSDictionary *)dictionaryForKey:(nonnull id)aKey;
- (nullable NSArray *)arrayForKey:(nonnull id)aKey;
- (nonnull NSNumber *)integerNumberForKey:(nonnull id)aKey;
- (nonnull NSNumber *)doubleNumberForKey:(nonnull id)aKey;

@end
