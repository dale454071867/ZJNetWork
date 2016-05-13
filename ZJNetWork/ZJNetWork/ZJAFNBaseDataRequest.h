//
//  ZJAFNBaseDataRequest.h
//  iTotemFramework
//
//  Created by Sword Zhou on 7/18/13.
//  Copyright (c) 2013 iTotemStudio. All rights reserved.
//

#import "ZJBaseDataRequest.h"

typedef enum {
    LOGINTYPE_GOLOGIN,///返回403跳转登录页面
    LOGINTYPE_NOLOGIN,///返回403不会跳转登录页
    LOGINTYPE_NOTOKEN,///不会返回403，即不需要传token
}LOGINTYPE;


@class AFHTTPRequestOperation;
@interface ZJAFNBaseDataRequest : ZJBaseDataRequest
@property(nonatomic,assign)LOGINTYPE loginType;
@property(nonatomic,assign)BOOL isNoToken;
@property(nonatomic,strong)NSString *port;
-(void)showNetError:(NSString*)error;
- (void)notifyDelegateUpdateProgress;
-(void)requestSuccess:(AFHTTPRequestOperation *)operation responseObject:(id)responseObject;
- (void)networkingOperationDidFinish:(NSNotification *)notification;
-(void)requestFailure:(AFHTTPRequestOperation *)operation error:(NSError*) error;
-(void)recordLog:(AFHTTPRequestOperation*)operation handleMessage:(NSString*)msg withError:(NSError*)requestError;
@end
