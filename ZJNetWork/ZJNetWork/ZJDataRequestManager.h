//
//  ZJDataRequestManager.h
//  iTotemFrame
//  数据请求管理中心
//  Created by jack 廉洁 on 3/12/12.
//  Copyright (c) 2012 iTotemStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZJBaseDataRequest;

@interface ZJDataRequestManager : NSObject
{
    NSMutableArray *_requests;
}

+ (ZJDataRequestManager *)sharedManager;

- (void)addRequest:(ZJBaseDataRequest*)request;
- (void)removeRequest:(ZJBaseDataRequest*)request;

@end
