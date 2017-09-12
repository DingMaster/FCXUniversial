//
//  UIDevice+Extension.m
//  HBTourClient
//
//  Created by 冯 传祥 on 2016/10/14.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import "UIDevice+Extension.h"
#import <sys/types.h>
#import <sys/sysctl.h>

#import "sys/utsname.h"  

@implementation UIDevice (Extension)

+ (NSString *)clientVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)clientName {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
}

+ (NSString *)uuid {
    return [UIDevice currentDevice].identifierForVendor.UUIDString;
}

+ (NSString *)deviceType {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char * machine = (char *)malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString * type = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    /*
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString * deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
*/
    return type;
}

@end
