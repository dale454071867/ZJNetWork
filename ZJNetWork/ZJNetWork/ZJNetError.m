//
//  ZJNetError.m
//  anyi
//
//  Created by 周杰 on 16/4/6.
//  Copyright © 2016年 周杰. All rights reserved.
//

#import "ZJNetError.h"

@implementation ZJNetError
+(NSString*)netErrorLocalizedDescription:(NSInteger)code
{
    switch (code) {
        case NSURLErrorNotConnectedToInternet:
            return @"似乎已断开与互联网的链接";
            break;
            
        default:
            return nil;
            break;
    }
}
@end
