//
//  NSDictionary+SafeValue.m
//  HBTourClient
//
//  Created by 冯 传祥 on 16/6/7.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import "NSDictionary+SafeValue.h"

@implementation NSDictionary (SafeValue)

- (nullable NSString *)stringForKey:(nonnull id)aKey {
    NSString *value = [self objectForKey:aKey];
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    }
    
    if([value isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"%@", value];
    }
    
    if ([value isKindOfClass:[NSNull class]]) {
        return nil;
    }
    
    if ([value isEqualToString:@"<null>"]) {
        return nil;
    }
    
    if ([value isEqualToString:@"(null)"]) {
        return nil;
    }
    
    if ([value isEqualToString:@"null"]) {
        return nil;
    }

    return nil;
}

- (nonnull NSString *)nonullStringForKey:(nonnull id)aKey {
    NSString *value = [self objectForKey:aKey];
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    }
    
    if([value isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"%@", value];
    }
    
    if ([value isKindOfClass:[NSNull class]]) {
        return @"";
    }

    if ([value isEqualToString:@"<null>"]) {
        return @"";
    }
    
    if ([value isEqualToString:@"(null)"]) {
        return @"";
    }
    
    if ([value isEqualToString:@"null"]) {
        return @"";
    }
    
    return @"";
}

- (NSInteger)integerForKey:(nonnull id)aKey {
    NSString *value = [self objectForKey:aKey];
    if ([value respondsToSelector:@selector(integerValue)]) {
        return [value integerValue];
    }
    return 0;
}

- (int)intForKey:(nonnull id)aKey {
    NSString *value = [self objectForKey:aKey];
    if ([value respondsToSelector:@selector(intValue)]) {
        return [value intValue];
    }
    return 0;
}

- (float)floatForKey:(nonnull id)aKey {
    NSString *value = [self objectForKey:aKey];
    if ([value respondsToSelector:@selector(floatValue)]) {
        return [value floatValue];
    }
    return 0.0;
}

- (double)doubleForKey:(nonnull id)aKey {
    NSString *value = [self objectForKey:aKey];
    if ([value respondsToSelector:@selector(doubleValue)]) {
        return [value doubleValue];
    }
    return 0.0;
}

- (BOOL)boolForKey:(nonnull id)aKey {
    NSString *value = [self objectForKey:aKey];
    if ([value respondsToSelector:@selector(boolValue)]) {
        return [value boolValue];
    }
    return NO;
}

- (NSDictionary *)dictionaryForKey:(id)aKey {
    NSDictionary *dict = [self objectForKey:aKey];
    if ([dict isKindOfClass:[NSDictionary class]]) {
        return dict;
    }
    return nil;
}

- (NSArray *)arrayForKey:(id)aKey {
    NSArray *array = [self objectForKey:aKey];
    if ([array isKindOfClass:[NSArray class]]) {
        return array;
    }
    return nil;
}

- (NSNumber *)integerNumberForKey:(id)aKey {
    NSNumber *value = [self objectForKey:aKey];
    if([value isKindOfClass:[NSNumber class]]) {
        return (NSNumber *)value;
    }
    
    if ([value isKindOfClass:[NSString class]]) {
        return [NSNumber numberWithInteger:value.integerValue];
    }
    return @0;
}

- (NSNumber *)doubleNumberForKey:(id)aKey {
    NSNumber *value = [self objectForKey:aKey];
    if([value isKindOfClass:[NSNumber class]]) {
        return (NSNumber *)value;
    }
    
    if ([value isKindOfClass:[NSString class]]) {
        return [NSNumber numberWithDouble:value.doubleValue];
    }
    return @0;
}


@end
