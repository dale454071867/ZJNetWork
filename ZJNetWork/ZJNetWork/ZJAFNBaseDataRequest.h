//
//  ZJAFNBaseDataRequest.h
//  ZJFramework
//
//  Created by Sword Zhou on 7/18/13.
//  Copyright (c) 2013 ZJStudio. All rights reserved.
//

#import "ZJBaseDataRequest.h"



@interface ZJAFNBaseDataRequest : ZJBaseDataRequest
@property(nonatomic,assign)BOOL isNoToken;
@property(nonatomic,strong)NSString *port;

/**
 *  重写后错误信息
 *
 *  @param error 错误信息
 */
-(void)showNetError:(NSString*)error;
///**
// *  重写请求方式GET/POST/MultipartPost
// *
// *  @return 返回类型
// */
//- (ZJRequestMethod)getRequestMethod;
//
///**
// *  以什么形式请求常用JSON，LIST，FROMAT
// *
// *  @return 返回请求类型
// */
//- (ZJParameterEncoding)parmaterEncoding;

@end
