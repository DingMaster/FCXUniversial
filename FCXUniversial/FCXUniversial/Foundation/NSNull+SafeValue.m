//
//  NSNull+SafeValue.m
//  HBTourClient
//
//  Created by 冯 传祥 on 16/8/4.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import "NSNull+SafeValue.h"
#define NSNullObjects @[@"",@0,@{},@[]]

@implementation NSNull (SafeValue)

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature* signature = [super methodSignatureForSelector:selector];
    if (!signature) {
        for (NSObject *object in NSNullObjects) {
            signature = [object methodSignatureForSelector:selector];
            if (signature) {
                break;
            }
        }
    }
    
    if (!signature) {
        signature = [NSMethodSignature signatureWithObjCTypes:"@^v^c"];
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    SEL aSelector = [anInvocation selector];
    
    for (NSObject *object in NSNullObjects) {
        if ([object respondsToSelector:aSelector]) {
            [anInvocation invokeWithTarget:object];
            return;
        }
    }
//    [self doesNotRecognizeSelector:aSelector];
}

/*
- (void)forwardInvocation:(NSInvocation *)invocation
{
    if ([self respondsToSelector:[invocation selector]]) {
        [invocation invokeWithTarget:self];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature *sig = [[NSNull class] instanceMethodSignatureForSelector:selector];
    if(sig == nil) {
        sig = [NSMethodSignature signatureWithObjCTypes:"@^v^c"];
    }
    return sig;
}
*/
@end
