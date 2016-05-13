//
//  ZJAFNBaseDataRequest.m
//  iTotemFramework
//
//  Created by Sword Zhou on 7/18/13.
//  Copyright (c) 2013 iTotemStudio. All rights reserved.
//

#import "ZJAFNBaseDataRequest.h"
#import "ZJNetworkTrafficManager.h"
#import "AFHTTPRequestOperation.h"
#import "ZJAFQueryStringPair.h"
#import "ZJDataRequestManager.h"
#import "AFURLRequestSerialization.h"
//#import "AFHTTPClient.h"
#import "ZJFileModel.h"
#import "AFHTTPRequestOperationManager.h"
#import "ErrorsInfoModel.h"
#import "DDLogger.h"
#define outTime 20.f
#import "Reachability.h"
#import "ZJNetError.h"
@interface ZJAFNBaseDataRequest()
{
    AFHTTPRequestOperation  *_requestOperation;
}
@property(nonatomic,strong)NSDate *willStartDate;
@end

@implementation ZJAFNBaseDataRequest
- (NSString *)contentType
{
    NSString *charset = @"utf-8";// (NSString*)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    NSString *contentType = [NSString stringWithFormat:@"application/json; charset=%@", charset];
    return contentType;
}
-(CGFloat)timeOut
{
    return 15;
}


+ (void)showNetworkActivityIndicator
{
#if TARGET_OS_IPHONE
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
#endif
}

+ (void)hideNetworkActivityIndicator
{
#if TARGET_OS_IPHONE
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
#endif
}

- (void)networkingOperationDidStart:(NSNotification *)notification
{
//    ZJDINFO(@"- (void)networkingOperationDidStart:(NSNotification *)notification");
    //    AFURLConnectionOperation *connectionOperation = [notification object];
    //    if (connectionOperation.request.URL) {
    [[self class] showNetworkActivityIndicator];
    [self showIndicator:TRUE];
    //    }
}

- (void)networkingOperationDidFinish:(NSNotification *)notification
{
//    ZJDINFO(@"- (void)networkingOperationDidFinish:(NSNotification *)notification");
    //    AFURLConnectionOperation *connectionOperation = [notification object];
    //    if (connectionOperation.request.URL) {
    [[self class] hideNetworkActivityIndicator];
    [self showIndicator:FALSE];
    //    }
}

- (void)notifyDelegateDownloadProgress
{
    //using block
    if (_onRequestProgressChangedBlock) {
        _onRequestProgressChangedBlock(self, self.currentProgress);
    }
}
- (void)notifyDelegateUpdateProgress
{
    if (_onRequestProgressUpdateBlock) {
        _onRequestProgressUpdateBlock(self,self.updateProgress);
    }
}

//报文头子类可重写已改变报文头信息
-(NSDictionary*)setHeadDataDic
{
    NSMutableDictionary *headParams = [NSMutableDictionary dictionary];
    return headParams;
}


- (void)generateRequestWithUrl:(NSString*)url withParameters:(NSDictionary*)params
{
    // process params
    self.willStartDate = [NSDate date];
    NSMutableDictionary *allParams = [NSMutableDictionary dictionaryWithCapacity:10];
    [allParams addEntriesFromDictionary: params];
    NSDictionary *staticParams = [self getStaticParams];
    if (staticParams != nil) {
        [allParams addEntriesFromDictionary:staticParams];
    }
    __weak __block typeof(self) wSelf = self;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //开始请求
    [self networkingOperationDidStart:nil];
    if (ZJRequestMethodGet == [self getRequestMethod]){
        manager.requestSerializer=[AFHTTPRequestSerializer serializer];
        manager.requestSerializer.timeoutInterval = self.timeoutInterval?[self.timeoutInterval floatValue]:outTime;
        [self setHeadWithAFManager:manager];
        _requestOperation = [manager GET:url parameters:allParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [wSelf requestSuccess:operation responseObject:responseObject];
            [wSelf networkingOperationDidFinish:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [wSelf requestFailure:operation error:error];
            [wSelf networkingOperationDidFinish:nil];
        }];
        [self progressBlock:_requestOperation];
    }else if(ZJRequestMethodPost == [self getRequestMethod])
    {
        switch (self.parmaterEncoding) {
            case ZJURLParameterEncoding:
            {
                manager.requestSerializer=[AFHTTPRequestSerializer serializer];
                manager.requestSerializer.timeoutInterval = self.timeoutInterval?[self.timeoutInterval floatValue]:outTime;
                [self setHeadWithAFManager:manager];
                _requestOperation = [manager POST:url parameters:allParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [wSelf requestSuccess:operation responseObject:responseObject];
                    [wSelf networkingOperationDidFinish:nil];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [wSelf requestFailure:operation error:error];
                    [wSelf networkingOperationDidFinish:nil];
                }];
                [self progressBlock:_requestOperation];
                
            }
                break;
            case ZJJSONParameterEncoding:
            {
                manager.requestSerializer=[AFJSONRequestSerializer serializer];
                manager.requestSerializer.timeoutInterval = self.timeoutInterval?[self.timeoutInterval floatValue]:outTime;
                [self setHeadWithAFManager:manager];
                _requestOperation = [manager POST:url parameters:allParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [wSelf requestSuccess:operation responseObject:responseObject];
                    [wSelf networkingOperationDidFinish:nil];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [wSelf networkingOperationDidFinish:nil];
                    [wSelf requestFailure:operation error:error];
                }];
                [self progressBlock:_requestOperation];
            }
                break;
            case ZJPropertyListParameterEncoding:
            {
                manager.requestSerializer=[AFPropertyListRequestSerializer serializer];
                manager.requestSerializer.timeoutInterval = self.timeoutInterval?[self.timeoutInterval floatValue]:outTime;
                [self setHeadWithAFManager:manager];
                _requestOperation = [manager POST:url parameters:allParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [wSelf requestSuccess:operation responseObject:responseObject];
                    [wSelf networkingOperationDidFinish:nil];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [wSelf requestFailure:operation error:error];
                    [wSelf networkingOperationDidFinish:nil];
                }];
                [self progressBlock:_requestOperation];
            }
                break;
                
            default:
                break;
        }
    }else if(ZJRequestMethodMultipartPost == [self getRequestMethod])
    {
        
        switch (self.parmaterEncoding) {
                //上传
            case ZJURLParameterEncoding:
            {
                manager.requestSerializer = [AFHTTPRequestSerializer serializer];
                manager.responseSerializer = [AFHTTPResponseSerializer serializer];
             
                manager.requestSerializer.timeoutInterval = self.timeoutInterval?[self.timeoutInterval floatValue]:outTime;
                [self setHeadWithAFManager:manager];
                _requestOperation =   [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                    
                    if (wSelf.upLoadDataType == ZJUpLoadData) {
                        [formData appendPartWithFileData:self.updata name:@"data" fileName:@"user_item.jpg" mimeType:@"image/jpeg"];
                    }else if(wSelf.upLoadDataType == ZJUpLoadDataPath)
                    {
                        NSURL *fileURL = [NSURL URLWithString:[wSelf updata]];
                        [formData appendPartWithFileURL:fileURL name:@"data" fileName:@"user_item.jpg" mimeType:@"image/jpeg" error:nil];
                    }
                    
                } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    DDLogDebug(@"OK");
                    [wSelf requestSuccess:operation responseObject:responseObject];
                    [wSelf networkingOperationDidFinish:nil];
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    DDLogDebug(@"error");
                    //                        error.code == NSURLErrorCancelled;
                    //                        时是取消
                    [wSelf requestFailure:operation error:error];
                    [wSelf networkingOperationDidFinish:nil];
                }];
                [self progressBlock:_requestOperation];
            }
                
                break;
            case ZJDownParameterEncoding:
            {
                //下载
                
                NSURL *URL = [NSURL URLWithString:url];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
                [self setHeadWithAFManager:request];
                _requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                _requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
                __weak __block typeof(self) wself = self;
                
                
                
                _requestOperation.outputStream = [NSOutputStream outputStreamToFileAtPath:[self downPath] append:NO];
                
                
                [_requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    [wself networkingOperationDidFinish:nil];
                    wself.handleredResult = responseObject;
                    wself.isSuccess = YES;
                    if (wself.onRequestFinishBlock) {
                        wself.onRequestFinishBlock(wself);
                    }
                    
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                    DDLogDebug(@"Image error: %@", error);
                    wself.isSuccess = NO;
                    if (wself.onRequestFailedBlock) {
                        wself.onRequestFailedBlock(wself,error);
                    }
                    [wself networkingOperationDidFinish:nil];
                }];
                [self progressBlock:_requestOperation];
                
            }
            default:
                break;
        }
    }
    
}


-(void)progressBlock:(AFHTTPRequestOperation*)requstOperation
{
      __weak __block typeof(self) wSelf = self;
    [requstOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        //        weakSelf.currentProgress = 1.0*totalBytesRead/totalBytesExpectedToRead;
        //如果需要统计进度在这里添加进度block
        _currentProgress = 1.0*totalBytesRead/totalBytesExpectedToRead;
        [wSelf notifyDelegateDownloadProgress];
    }];
  
    [requstOperation setUploadProgressBlock:^(NSUInteger bytesWrZJen, long long totalBytesWrZJen, long long totalBytesExpectedToWrite) {
        wSelf.updateProgress = 1.0*totalBytesWrZJen/totalBytesExpectedToWrite;
        [wSelf notifyDelegateUpdateProgress];
    }];
    
}

-(void)requestSuccess:(AFHTTPRequestOperation *)operation responseObject:(id)responseObject
{
    [self handleResultString:operation.responseString];
    if (!self.isSuccess) {
        [self recordLog:operation handleMessage:operation.responseString withError:nil];
    }
    //         [self unregisterRequestNotification];
    [self doRelease];
}
-(void)requestFailure:(AFHTTPRequestOperation *)operation error:(NSError*) error
{
    [self requestFailure:operation handleError:error];
    [self notifyDelegateRequestDidErrorWithError:error];
    //         [self unregisterRequestNotification];
    [self doRelease];
}
-(void)setHeadWithAFManager:(id)manager
{
    NSDictionary *headDic = [self setHeadDataDic];
    if ([manager isKindOfClass:[AFHTTPRequestOperationManager class]]) {
        for (NSString *key in headDic) {
            [((AFHTTPRequestOperationManager*)manager).requestSerializer setValue:[self setHeadDataDic][key] forHTTPHeaderField:key];
        }
    }else if([manager isKindOfClass:[NSMutableURLRequest class]])
    {
        for (NSString *key in headDic) {
            [((NSMutableURLRequest*)manager) setValue:[self setHeadDataDic][key] forHTTPHeaderField:key];
        }
    }
}
- (void)doRequestWithParams:(NSDictionary*)params
{
    [self generateRequestWithUrl:self.requestUrl withParameters:params];
    //    [_requestOperation start];
}

- (void)requestFailure:(AFHTTPRequestOperation *)operation handleError:(NSError*)error
{
    [self recordLog:operation handleMessage:nil withError:error];
    if(operation.response.statusCode == 500)
        {
            DDLogDebug(@"############################################");
            DDLogDebug(@"%@发生了500错误，请报告服务器，参数",self.port);
            for (NSString *key in self.userinfo) {
                DDLogDebug(@"key:%@,value:%@",key,self.userinfo[key]);
            }
            DDLogDebug(@"############################################");
        }else
        {
            if (error) {
                DDLogDebug(@"############################################");
                DDLogDebug(@"%@发生了错误，请报告服务器，参数,错误内容:%@ errorCode %@",self.port,error.localizedDescription,@(error.code));
                for (NSString *key in self.userinfo) {
                    DDLogDebug(@"key:%@,value:%@",key,self.userinfo[key]);
                }
                DDLogDebug(@"############################################");
                //链接取消
                if (error.code == NSURLErrorCancelled) {
                    return;
                }
                if (_useSilentAlert) {
                    NSString *errorString = [ZJNetError netErrorLocalizedDescription:error.code];
                    if (errorString.length) {
                        [self showNetError:errorString];
                    }else
                    {
                        [self showNetError:error.localizedDescription];
                    }
                }
            }
        }
//    }
}



-(void)showNetError:(NSString*)error
{
//    [[WDToast makeText:error withDuration:1.5] show];
//    [AYHUD showText:error];
}

- (void)cancelRequest
{
    DDLogDebug(@"%@ request is cancled", [self class]);
    [_requestOperation cancel];
    //to cancel here
    if (_onRequestCanceled) {
        _onRequestCanceled(self);
    }
    [self showIndicator:FALSE];
    [self doRelease];
}
- (NSString*)getRequestUrl
{
    return [NSString stringWithFormat:@"%@%@",self.getRequestHost,self.port];
}
- (ZJRequestMethod)getRequestMethod
{
    return ZJRequestMethodPost;
    
}
@end
