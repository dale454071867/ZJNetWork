//
//  DemoRequest.m
//  ZJNetWork
//
//  Created by 周杰 on 16/5/13.
//  Copyright © 2016年 周杰. All rights reserved.
//

#import "DemoRequest.h"

@implementation DemoRequest
-(NSString*)port
{
//    return @"IMG_1118.jpg";
    return @"ne/item/list_v2.json";
}
-(NSString*)getRequestHost
{
//    return @"http://7xlvl8.com1.z0.glb.clouddn.com/";
    return  @"http://myanyi.com/";
}
- (ZJParameterEncoding)parmaterEncoding
{
    return ZJURLParameterEncoding;
    
}
- (ZJRequestMethod)getRequestMethod
{
    return ZJRequestMethodGet;
    
}
@end
