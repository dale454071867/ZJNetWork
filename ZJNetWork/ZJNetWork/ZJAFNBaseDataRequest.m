//
//  ZJAFNBaseDataRequest.m
//  iTotemFramework
//
//  Created by Sword Zhou on 7/18/13.
//  Copyright (c) 2013 iTotemStudio. All rights reserved.
//

#import "ZJAFNBaseDataRequest.h"
#import "ZJNetworkTrafficManager.h"
#import "AFNetworking.h"
#import "ZJAFQueryStringPair.h"
#import "ZJDataRequestManager.h"
//#import "AFHTTPClient.h"
#import "ZJFileModel.h"
#import "ErrorsInfoModel.h"
#import "DDLogger.h"
#define outTime 20.f
#import "Reachability.h"
#import "ZJNetError.h"
#import "MJExtension.h"
#import "MBProgressHUD.h"
@interface ZJAFNBaseDataRequest()
{
    NSURLSessionDataTask  *_requestOperation;
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
        _onRequestProgressChangedBlock(self, self.downProgress);
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
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //开始请求
    [self networkingOperationDidStart:nil];
    if (ZJRequestMethodGet == [self getRequestMethod]){
        manager.requestSerializer=[AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer.timeoutInterval = self.timeoutInterval?[self.timeoutInterval floatValue]:outTime;
        
        [self setHeadWithAFManager:manager];
        _requestOperation =[manager GET:url parameters:allParams progress:^(NSProgress * _Nonnull downloadProgress) {
             wSelf.downProgress = downloadProgress.totalUnitCount/downloadProgress.completedUnitCount;
            
        }  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            [wSelf requestSuccess:task responseObject:responseObject];
            [wSelf networkingOperationDidFinish:nil];

        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [wSelf requestFailure:task error:error];
            [wSelf networkingOperationDidFinish:nil];
        }];
    }else if(ZJRequestMethodPost == [self getRequestMethod])
    {
        switch (self.parmaterEncoding) {
            case ZJURLParameterEncoding:
            {
                manager.requestSerializer=[AFHTTPRequestSerializer serializer];
                manager.requestSerializer.timeoutInterval = self.timeoutInterval?[self.timeoutInterval floatValue]:outTime;
                [self setHeadWithAFManager:manager];
                _requestOperation = [manager POST:url parameters:allParams progress:nil success:^(NSURLSessionDataTask *operation, id responseObject) {
                    [wSelf requestSuccess:operation responseObject:responseObject];
                    [wSelf networkingOperationDidFinish:nil];
                } failure:^(NSURLSessionDataTask *operation, NSError *error) {
                    [wSelf requestFailure:operation error:error];
                    [wSelf networkingOperationDidFinish:nil];
                }];
            }
                break;
            case ZJJSONParameterEncoding:
            {
                manager.requestSerializer=[AFJSONRequestSerializer serializer];
                manager.requestSerializer.timeoutInterval = self.timeoutInterval?[self.timeoutInterval floatValue]:outTime;
                [self setHeadWithAFManager:manager];
                _requestOperation = [manager POST:url parameters:allParams progress:nil success:^(NSURLSessionDataTask *operation, id responseObject) {
                    [wSelf requestSuccess:operation responseObject:responseObject];
                    [wSelf networkingOperationDidFinish:nil];
                } failure:^(NSURLSessionDataTask *operation, NSError *error) {
                    [wSelf networkingOperationDidFinish:nil];
                    [wSelf requestFailure:operation error:error];
                }];
            }
                break;
            case ZJPropertyListParameterEncoding:
            {
                manager.requestSerializer=[AFPropertyListRequestSerializer serializer];
                manager.requestSerializer.timeoutInterval = self.timeoutInterval?[self.timeoutInterval floatValue]:outTime;
                [self setHeadWithAFManager:manager];
                _requestOperation = [manager POST:url parameters:allParams progress:nil success:^(NSURLSessionDataTask *operation, id responseObject) {
                    [wSelf requestSuccess:operation responseObject:responseObject];
                    [wSelf networkingOperationDidFinish:nil];
                } failure:^(NSURLSessionDataTask *operation, NSError *error) {
                    [wSelf requestFailure:operation error:error];
                    [wSelf networkingOperationDidFinish:nil];
                }];
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
                _requestOperation = [manager POST:url  parameters:allParams constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                    if (wSelf.upLoadDataType == ZJUpLoadData) {
                        [formData appendPartWithFileData:wSelf.updata name:@"data" fileName:@"user_item.jpg" mimeType:@"image/jpeg"];
                    }else if(wSelf.upLoadDataType == ZJUpLoadDataPath)
                    {
                        NSURL *fileURL = [NSURL URLWithString:[wSelf updata]];
                        [formData appendPartWithFileURL:fileURL name:@"data" fileName:@"user_item.jpg" mimeType:@"image/jpeg" error:nil];
                    }
                } progress:^(NSProgress * _Nonnull uploadProgress) {
                    wSelf.updateProgress = uploadProgress.totalUnitCount/uploadProgress.completedUnitCount;
                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    DDLogDebug(@"OK");
                    [wSelf requestSuccess:task responseObject:responseObject];
                    [wSelf networkingOperationDidFinish:nil];
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [wSelf requestFailure:task error:error];
                    [wSelf networkingOperationDidFinish:nil];

                }];
                
            }
                
                break;
            case ZJDownParameterEncoding:
            {
                //下载
                __weak __block typeof(self) wself = self;
              NSURLSessionDownloadTask *task =  [manager downloadTaskWithRequest: [NSURLRequest requestWithURL:[NSURL URLWithString:url]]  progress:^(NSProgress * _Nonnull downloadProgress) {
                  wSelf.downProgress = downloadProgress.totalUnitCount/downloadProgress.completedUnitCount;
                  [wSelf notifyDelegateDownloadProgress];
                } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                    // 指定下载文件保存的路径
                    //        NSLog(@"%@ %@", targetPath, response.suggestedFilename);
                    // 将下载文件保存在缓存路径中
                    NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
                    NSString *path = [[cacheDir stringByAppendingPathComponent:@"zjNetWorkDown"] stringByAppendingPathComponent:response.suggestedFilename];
                    NSError *error = nil;
                    
                    BOOL isDir = NO;
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    BOOL existed = [fileManager fileExistsAtPath:[path stringByDeletingLastPathComponent] isDirectory:&isDir];
                    if ( !(isDir == YES && existed == YES) )
                    {
                        [fileManager createDirectoryAtPath:[path stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&error];
                    }
                    // URLWithString返回的是网络的URL,如果使用本地URL,需要注意
                    NSURL *fileURL = [NSURL fileURLWithPath:path];
                    return fileURL;
                } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {  
                    NSLog(@"%@ %@", filePath, error);
                    
                    if (error == nil) {
                        [wself networkingOperationDidFinish:nil];
                        wself.isSuccess = YES;
                        if (wself.onRequestFinishBlock) {
                            wself.onRequestFinishBlock(wself);
                        }
                    }else
                    {
                        wself.isSuccess = NO;
                        if (wself.onRequestFailedBlock) {
                            wself.onRequestFailedBlock(wself,error);
                        }
                        [wself networkingOperationDidFinish:nil];
                    }
                    
                }];
                [task resume];
            }
            default:
                break;
        }
    }
    
}

-(void)requestSuccess:(NSURLSessionDataTask *)operation responseObject:(id)responseObject
{
    [self handleResultString:[responseObject mj_JSONString]];
    //         [self unregisterRequestNotification];
    [self doRelease];
}
-(void)requestFailure:(NSURLSessionDataTask *)operation error:(NSError*) error
{
    [self notifyDelegateRequestDidErrorWithError:error];
    [self doRelease];
}
-(void)setHeadWithAFManager:(AFHTTPSessionManager*)manager
{
    for (NSString *key in [self setHeadDataDic]) {
        [manager.requestSerializer setValue:[self setHeadDataDic][key] forHTTPHeaderField:key];
    }
    
}
- (void)doRequestWithParams:(NSDictionary*)params
{
    [self generateRequestWithUrl:self.requestUrl withParameters:params];
}



-(void)showNetError:(NSString*)error
{
    [[[UIAlertView alloc] initWithTitle:@"提示" message:error delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
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
