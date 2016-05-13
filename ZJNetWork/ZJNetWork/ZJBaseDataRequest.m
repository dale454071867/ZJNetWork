//
//  ZJBaseDataRequest.m
//  
//
//  Created by lian jie on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ZJBaseDataRequest.h"
#import "ZJDataCacheManager.h"
#import "ZJDataRequestManager.h"
#import "ZJRequestJsonDataHandler.h"
#import "ZJDataEnvironment.h"
#import "MBProgressHUD.h"
#import "ZJCommonMacros.h"
#import "DDLogger.h"
#define DEFAULT_LOADING_MESSAGE  @"正在加载..."
//
//#if !__has_feature(objc_arc)
//#error AFNetworking must be built with ARC.
//// You can turn on ARC for only AFNetworking files by adding -fobjc-arc to the build phase for each of its files.
//#endif

@interface ZJBaseDataRequest()
{
}

@property (nonatomic, strong) UIView *indicatorView;
@property (nonatomic, strong) NSString *loadingMessage;

@end

@implementation ZJBaseDataRequest
+(NSString*)toString
{
    return NSStringFromClass([self class]);
}
#pragma mark - init methods using delegate

- (id)initWithDelegate:(id<DataRequestDelegate>)delegate
        withParameters:(NSDictionary*)params
     withIndicatorView:(UIView*)indiView
     withCancelSubject:(NSString*)cancelSubject
       withSilentAlert:(BOOL)silent
          withCacheKey:(NSString*)cacheKey
         withCacheType:(DataCacheManagerCacheType)cacheType
          withFilePath:(NSString*)localFilePath
{
    
    return [self initWithDelegate:delegate
                   withRequestUrl:nil
                   withParameters:params
                withIndicatorView:indiView
               withLoadingMessage:nil
                withCancelSubject:cancelSubject
                  withSilentAlert:silent
                     withCacheKey:cacheKey
                    withCacheType:cacheType
                     withFilePath:localFilePath];
}

- (id)initWithDelegate:(id<DataRequestDelegate>)delegate
        withRequestUrl:(NSString*)url
        withParameters:(NSDictionary*)params
     withIndicatorView:(UIView*)indiView
    withLoadingMessage:(NSString*)loadingMessage
     withCancelSubject:(NSString*)cancelSubject
       withSilentAlert:(BOOL)silent
          withCacheKey:(NSString*)cache
         withCacheType:(DataCacheManagerCacheType)cacheType
          withFilePath:(NSString*)localFilePath
{
    self = [super init];
    if(self) {
        _parmaterEncoding = ZJURLParameterEncoding;
        _totalData = NSIntegerMax;
        _downloadedData = 0;
        _currentProgress = 0;
        _requestStartDate = [NSDate date];
        _isLoading = NO;
        _handleredResult = nil;
        _result = nil;
        
        _requestUrl = url;
        if (!_requestUrl) {
            _requestUrl = [self getRequestUrl];
        }
        _indicatorView = indiView;
        _useSilentAlert = silent;
        _cacheKey = cache;
        if (_cacheKey && [_cacheKey length] > 0) {
            _usingCacheData = YES;
        }
        _cacheType = cacheType;
        if (cancelSubject && cancelSubject.length > 0) {
            _cancelSubject = cancelSubject;
        }
        if (_cancelSubject && _cancelSubject) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelRequest) name:_cancelSubject object:nil];
        }
        _userinfo = [[NSDictionary alloc] initWithDictionary:params];
        BOOL useCurrentCache = NO;
        if (localFilePath) {
            _filePath = localFilePath;
        }
        self.loadingMessage = loadingMessage;
        if (!self.loadingMessage) {
            self.loadingMessage = DEFAULT_LOADING_MESSAGE;
        }
        NSObject *cacheData = [[ZJDataCacheManager sharedManager] getCachedObjectByKey:_cacheKey];
        if (cacheData) {
            useCurrentCache = [self onReceivedCacheData:cacheData];
        }
        if (!useCurrentCache) {
            _usingCacheData = NO;
            [self doRequestWithParams:params];
            DDLogDebug(@"request %@ is created", [self class]);
        }
        else {
            _usingCacheData = YES;
            [self performSelector:@selector(doRelease) withObject:nil afterDelay:0.1f];
        }
    }
    return self;
}

#pragma mark - init methods using delegate
+(id)requestCommentWithParameters:(NSDictionary*)params onRequestFinished:(void(^)(ZJBaseDataRequest *request))onFinishedBlock onRequestFailed:(void(^)(ZJBaseDataRequest *request))onFailedBlock
{
    
    ZJBaseDataRequest *request = [[[self class] alloc] initWithParameters:params
                                                            withRequestUrl:nil
                                                               suffixParam:nil
                                                         withIndicatorView:nil
                                                        withLoadingMessage:nil
                                                         withCancelSubject:NSStringFromClass([self class])
                                                           withSilentAlert:YES
                                                              withCacheKey:nil
                                                             withCacheType:DataCacheManagerCacheTypeMemory
                                                              withFilePath:nil
                                                                  withData:nil
                                                                  downPath:nil
                                                            onRequestStart:nil
                                                         onRequestFinished:onFinishedBlock
                                                         onRequestCanceled:nil
                                                           onRequestFailed:onFailedBlock
                                                         onProgressChanged:nil];
    [[ZJDataRequestManager sharedManager] addRequest:request];
    return request;
}
+(id)requestCommentWithParameters:(NSDictionary*)params withIndicatorView:(UIView*)IndicatorView onRequestFinished:(void(^)(ZJBaseDataRequest *request))onFinishedBlock onRequestFailed:(void(^)(ZJBaseDataRequest *request))onFailedBlock
{
    ZJBaseDataRequest *request = [[[self class] alloc] initWithParameters:params
                                                            withRequestUrl:nil
                                                               suffixParam:nil
                                                         withIndicatorView:IndicatorView
                                                        withLoadingMessage:nil
                                                         withCancelSubject:NSStringFromClass([self class])
                                                           withSilentAlert:YES
                                                              withCacheKey:nil
                                                             withCacheType:DataCacheManagerCacheTypeMemory
                                                              withFilePath:nil
                                                                  withData:nil
                                                                  downPath:nil
                                                            onRequestStart:nil
                                                         onRequestFinished:onFinishedBlock
                                                         onRequestCanceled:nil
                                                           onRequestFailed:onFailedBlock
                                                         onProgressChanged:nil];
    [[ZJDataRequestManager sharedManager] addRequest:request];
    return request;
}

+ (id)requestCommentWithParameters:(NSDictionary*)params
          withIndicatorView:(UIView*)indiView
          onRequestFinished:(void(^)(ZJBaseDataRequest *request))onFinishedBlock
{
    ZJBaseDataRequest *request = [[[self class] alloc] initWithParameters:params
                                                           withRequestUrl:nil
                                                              suffixParam:nil
                                                        withIndicatorView:indiView
                                                       withLoadingMessage:nil
                                                        withCancelSubject:NSStringFromClass([self class])
                                                          withSilentAlert:YES
                                                             withCacheKey:nil
                                                            withCacheType:DataCacheManagerCacheTypeMemory
                                                             withFilePath:nil
                                                                 withData:nil
                                                                 downPath:nil
                                                           onRequestStart:nil
                                                        onRequestFinished:onFinishedBlock
                                                        onRequestCanceled:nil
                                                          onRequestFailed:nil
                                                        onProgressChanged:nil];
    [[ZJDataRequestManager sharedManager] addRequest:request];
    return request;
}

+ (id)requestWithParameters:(NSDictionary*)params
          withIndicatorView:(UIView*)indiView
          withCancelSubject:(NSString*)cancelSubject
          onRequestFinished:(void(^)(ZJBaseDataRequest *request))onFinishedBlock
{
    ZJBaseDataRequest *request = [[[self class] alloc] initWithParameters:params
                                                           withRequestUrl:nil
                                                              suffixParam:nil
                                                        withIndicatorView:indiView
                                                       withLoadingMessage:nil
                                                        withCancelSubject:cancelSubject
                                                          withSilentAlert:YES
                                                             withCacheKey:nil
                                                            withCacheType:DataCacheManagerCacheTypeMemory
                                                             withFilePath:nil
                                                                 withData:nil
                                                                 downPath:nil
                                                           onRequestStart:nil
                                                        onRequestFinished:onFinishedBlock
                                                        onRequestCanceled:nil
                                                          onRequestFailed:nil
                                                        onProgressChanged:nil];
    [[ZJDataRequestManager sharedManager] addRequest:request];
    return request;
}

+ (id)requestWithParameters:(NSDictionary*)params
             withRequestUrl:(NSString*)url
          withIndicatorView:(UIView*)indiView
          onRequestFinished:(void(^)(ZJBaseDataRequest *request))onFinishedBlock
{
    ZJBaseDataRequest *request = [[[self class] alloc] initWithParameters:params
                                                           withRequestUrl:url
                                                              suffixParam:nil
                                                        withIndicatorView:indiView
                                                       withLoadingMessage:nil
                                                        withCancelSubject:nil
                                                          withSilentAlert:YES
                                                             withCacheKey:nil
                                                            withCacheType:DataCacheManagerCacheTypeMemory
                                                             withFilePath:nil
                                                                 withData:nil
                                                                 downPath:nil
                                                           onRequestStart:nil
                                                        onRequestFinished:onFinishedBlock
                                                        onRequestCanceled:nil
                                                          onRequestFailed:nil
                                                        onProgressChanged:nil];
    
    [[ZJDataRequestManager sharedManager] addRequest:request];
    return request;
    
}

+ (id)requestWithParameters:(NSDictionary*)params
             withRequestUrl:(NSString*)url
          withIndicatorView:(UIView*)indiView
          withCancelSubject:(NSString*)cancelSubject
          onRequestFinished:(void(^)(ZJBaseDataRequest *request))onFinishedBlock
{
    ZJBaseDataRequest *request = [[[self class] alloc] initWithParameters:params
                                                           withRequestUrl:url
                                                              suffixParam:nil
                                                        withIndicatorView:indiView
                                                       withLoadingMessage:nil
                                                        withCancelSubject:cancelSubject
                                                          withSilentAlert:YES
                                                             withCacheKey:nil
                                                            withCacheType:DataCacheManagerCacheTypeMemory
                                                             withFilePath:nil
                                                                 withData:nil
                                                                 downPath:nil
                                                           onRequestStart:nil
                                                        onRequestFinished:onFinishedBlock
                                                        onRequestCanceled:nil
                                                          onRequestFailed:nil
                                                        onProgressChanged:nil];
    [[ZJDataRequestManager sharedManager] addRequest:request];
    return request;
}

+ (id)requestWithParameters:(NSDictionary*)params
          withIndicatorView:(UIView*)indiView
          withCancelSubject:(NSString*)cancelSubject
             onRequestStart:(void(^)(ZJBaseDataRequest *request))onStartBlock
          onRequestFinished:(void(^)(ZJBaseDataRequest *request))onFinishedBlock
          onRequestCanceled:(void(^)(ZJBaseDataRequest *request))onCanceledBlock
            onRequestFailed:(void(^)(ZJBaseDataRequest *request))onFailedBlock
{
    
    ZJBaseDataRequest *request = [[[self class] alloc] initWithParameters:params
                                                           withRequestUrl:nil
                                                              suffixParam:nil
                                                        withIndicatorView:indiView
                                                       withLoadingMessage:nil
                                                        withCancelSubject:cancelSubject
                                                          withSilentAlert:YES
                                                             withCacheKey:nil
                                                            withCacheType:DataCacheManagerCacheTypeMemory
                                                             withFilePath:nil
                                                                 withData:nil
                                                                 downPath:nil
                                                           onRequestStart:onStartBlock
                                                        onRequestFinished:onFinishedBlock
                                                        onRequestCanceled:onCanceledBlock
                                                          onRequestFailed:onFailedBlock
                                                        onProgressChanged:nil];
    [[ZJDataRequestManager sharedManager] addRequest:request];
    return request;
}

+ (id)requestWithParameters:(NSDictionary*)params
             withRequestUrl:(NSString*)url
          withIndicatorView:(UIView*)indiView
          withCancelSubject:(NSString*)cancelSubject
             onRequestStart:(void(^)(ZJBaseDataRequest *request))onStartBlock
          onRequestFinished:(void(^)(ZJBaseDataRequest *request))onFinishedBlock
          onRequestCanceled:(void(^)(ZJBaseDataRequest *request))onCanceledBlock
            onRequestFailed:(void(^)(ZJBaseDataRequest *request))onFailedBlock
{
    ZJBaseDataRequest *request = [[[self class] alloc] initWithParameters:params
                                                           withRequestUrl:url
                                                              suffixParam:nil
                                                        withIndicatorView:indiView
                                                       withLoadingMessage:nil
                                                        withCancelSubject:cancelSubject
                                                          withSilentAlert:YES
                                                             withCacheKey:nil
                                                            withCacheType:DataCacheManagerCacheTypeMemory
                                                             withFilePath:nil
                                                                 withData:nil
                                                                 downPath:nil
                                                           onRequestStart:onStartBlock
                                                        onRequestFinished:onFinishedBlock
                                                        onRequestCanceled:onCanceledBlock
                                                          onRequestFailed:onFailedBlock
                                                        onProgressChanged:nil];
    [[ZJDataRequestManager sharedManager] addRequest:request];
    return request;
}
+ (id)requestWithParameters:(NSDictionary*)params
          withIndicatorView:(UIView*)indiView
          withCancelSubject:(NSString*)cancelSubject
          onRequestFinished:(void(^)(ZJBaseDataRequest *request))onFinishedBlock
            onRequestFailed:(void(^)(ZJBaseDataRequest *request))onFailedBlock
{
    ZJBaseDataRequest *request = [[[self class] alloc] initWithParameters:params
                                                           withRequestUrl:nil
                                                              suffixParam:nil
                                                        withIndicatorView:indiView
                                                       withLoadingMessage:nil
                                                        withCancelSubject:cancelSubject
                                                          withSilentAlert:YES
                                                             withCacheKey:nil
                                                            withCacheType:DataCacheManagerCacheTypeMemory
                                                             withFilePath:nil
                                                                 withData:nil
                                                                 downPath:nil
                                                           onRequestStart:nil
                                                        onRequestFinished:onFinishedBlock
                                                        onRequestCanceled:nil
                                                          onRequestFailed:onFailedBlock
                                                        onProgressChanged:nil];
    [[ZJDataRequestManager sharedManager] addRequest:request];
    return request;
}
+ (id)requestWithSuffixParam:(NSString*)suffixParam
                  parameters:(NSDictionary*)params
           withIndicatorView:(UIView*)indiView
           withCancelSubject:(NSString*)cancelSubject
           onRequestFinished:(void(^)(ZJBaseDataRequest *request))onFinishedBlock
             onRequestFailed:(void(^)(ZJBaseDataRequest *request))onFailedBlock
{
    ZJBaseDataRequest *request = [[[self class] alloc] initWithParameters:params
                                                           withRequestUrl:nil
                                                              suffixParam:suffixParam
                                                        withIndicatorView:indiView
                                                       withLoadingMessage:nil
                                                        withCancelSubject:cancelSubject
                                                          withSilentAlert:YES
                                                             withCacheKey:nil
                                                            withCacheType:DataCacheManagerCacheTypeMemory
                                                             withFilePath:nil
                                                                 withData:nil
                                                                 downPath:nil
                                                           onRequestStart:nil
                                                        onRequestFinished:onFinishedBlock
                                                        onRequestCanceled:nil
                                                          onRequestFailed:onFailedBlock
                                                        onProgressChanged:nil];
    [[ZJDataRequestManager sharedManager] addRequest:request];
    return request;
}
//上传
+(id)requestWithUpLoadDataPath:(NSString*)dataPath
             withCancelSubject:(NSString*)cancelSubject
                onRequestStart:(void(^)(ZJBaseDataRequest *request))onStartBlock
             onRequestFinished:(void(^)(ZJBaseDataRequest *request))onFinishedBlock
             onRequestCanceled:(void(^)(ZJBaseDataRequest *request))onCanceledBlock
               onRequestFailed:(void(^)(ZJBaseDataRequest *request))onFailedBlock
       onRequestProgressUpdate:(void(^)(ZJBaseDataRequest *request,CGFloat progress))onRequestProgress
{
    ZJBaseDataRequest *request = [[[self class] alloc] initWithParameters:nil
                                                           withRequestUrl:nil
                                                              suffixParam:nil
                                                        withIndicatorView:nil
                                                       withLoadingMessage:nil
                                                        withCancelSubject:cancelSubject
                                                          withSilentAlert:YES
                                                             withCacheKey:nil
                                                            withCacheType:DataCacheManagerCacheTypeMemory
                                                             withFilePath:nil
                                                                 withData:dataPath
                                                                 downPath:nil
                                                           onRequestStart:onStartBlock
                                                        onRequestFinished:onFinishedBlock
                                                        onRequestCanceled:onCanceledBlock
                                                          onRequestFailed:onFailedBlock
                                                        onProgressChanged:nil];
    request.onRequestProgressUpdateBlock = [onRequestProgress copy];
    request.upLoadDataType = ZJUpLoadDataPath;
    request.updata = dataPath;
    [[ZJDataRequestManager sharedManager] addRequest:request];
    return request;
    
}


+(id)requestWithUpLoadData:(NSData*)data
         withCancelSubject:(NSString*)cancelSubject
            onRequestStart:(void(^)(ZJBaseDataRequest *request))onStartBlock
         onRequestFinished:(void(^)(ZJBaseDataRequest *request))onFinishedBlock
         onRequestCanceled:(void(^)(ZJBaseDataRequest *request))onCanceledBlock
           onRequestFailed:(void(^)(ZJBaseDataRequest *request))onFailedBlock
   onRequestProgressUpdate:(void(^)(ZJBaseDataRequest *request,CGFloat progress))onRequestProgress
{
    ZJBaseDataRequest *request = [[[self class] alloc] initWithParameters:nil
                                                           withRequestUrl:nil
                                                              suffixParam:nil
                                                        withIndicatorView:nil
                                                       withLoadingMessage:nil
                                                        withCancelSubject:cancelSubject
                                                          withSilentAlert:YES
                                                             withCacheKey:nil
                                                            withCacheType:DataCacheManagerCacheTypeMemory
                                                             withFilePath:nil
                                                                 withData:data
                                                                 downPath:nil
                                                           onRequestStart:onStartBlock
                                                        onRequestFinished:onFinishedBlock
                                                        onRequestCanceled:onCanceledBlock
                                                          onRequestFailed:onFailedBlock
                                                        onProgressChanged:nil];
    request.onRequestProgressUpdateBlock = [onRequestProgress copy];
    [[ZJDataRequestManager sharedManager] addRequest:request];
    return request;
}

//下载
+(id)requestDownUrlString:(NSString*)url
                 downPath:(NSString*)downPath
            cancelSubject:(NSString*)cancelSubject
           onRequestStart:(void(^)(ZJBaseDataRequest *request))onStartBlock
        onRequestFinished:(void(^)(ZJBaseDataRequest *request))onFinishedBlock
        onRequestCanceled:(void(^)(ZJBaseDataRequest *request))onCanceledBlock
          onRequestFailed:(void(^)(ZJBaseDataRequest *request))onFailedBlock
 onRequestProgressChanged:(void(^)(ZJBaseDataRequest *request,CGFloat progress))onRequestProgress
{
    ZJBaseDataRequest *request = [[[self class] alloc] initWithParameters:nil
                                                           withRequestUrl:url
                                                              suffixParam:nil
                                                        withIndicatorView:nil
                                                       withLoadingMessage:nil
                                                        withCancelSubject:cancelSubject
                                                          withSilentAlert:YES
                                                             withCacheKey:nil
                                                            withCacheType:DataCacheManagerCacheTypeMemory
                                                             withFilePath:nil
                                                                 withData:nil
                                                                 downPath:downPath
                                                           onRequestStart:onStartBlock
                                                        onRequestFinished:onFinishedBlock
                                                        onRequestCanceled:onCanceledBlock
                                                          onRequestFailed:onFailedBlock
                                                        onProgressChanged:nil];
    
    request.onRequestProgressChangedBlock = [onRequestProgress copy];
    [[ZJDataRequestManager sharedManager] addRequest:request];
    return request;
}
- (id)initWithParameters:(NSDictionary*)params
          withRequestUrl:(NSString*)url
             suffixParam:(NSString*)suffixParam
       withIndicatorView:(UIView*)indiView
      withLoadingMessage:(NSString*)loadingMessage
       withCancelSubject:(NSString*)cancelSubject
         withSilentAlert:(BOOL)silent
            withCacheKey:(NSString*)cache
           withCacheType:(DataCacheManagerCacheType)cacheType
            withFilePath:(NSString*)localFilePath
                withData:(id)data
                downPath:(NSString*)downPath
          onRequestStart:(void(^)(ZJBaseDataRequest *request))onStartBlock
       onRequestFinished:(void(^)(ZJBaseDataRequest *request))onFinishedBlock
       onRequestCanceled:(void(^)(ZJBaseDataRequest *request))onCanceledBlock
         onRequestFailed:(void(^)(ZJBaseDataRequest *request))onFailedBlock
       onProgressChanged:(void(^)(ZJBaseDataRequest *request,float))onProgressChangedBlock

{
    self = [super init];
    if(self) {
        if ([data isKindOfClass:[NSString class]]) {
            self.upLoadDataType = ZJUpLoadDataPath;
        }else
        {
            self.upLoadDataType = ZJUpLoadData;
        }
        _downPath = downPath;
        _updata = data;
        _parmaterEncoding = ZJURLParameterEncoding;
        _isLoading = NO;
        _handleredResult = nil;
        _result = nil;
        
        _requestUrl = url;
        if (!_requestUrl) {
            _requestUrl = [self getRequestUrl];
        }
        if (suffixParam) {
            _requestUrl = [_requestUrl stringByAppendingFormat:@"/%@",suffixParam];
        }
        _indicatorView = indiView;
        _useSilentAlert = silent;
        _cacheKey = cache;
        if (_cacheKey && [_cacheKey length] > 0) {
            _usingCacheData = YES;
        }
        _cacheType = cacheType;
        if (cancelSubject && cancelSubject.length > 0) {
            _cancelSubject = cancelSubject;
        }
        
        if (_cancelSubject && _cancelSubject) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelRequest) name:_cancelSubject object:nil];
        }
        if (onStartBlock) {
            _onRequestStartBlock = [onStartBlock copy];
        }
        if (onFinishedBlock) {
            _onRequestFinishBlock = [onFinishedBlock copy];
        }
        if (onCanceledBlock) {
            _onRequestCanceled = [onCanceledBlock copy];
        }
        if (onFailedBlock) {
            _onRequestFailedBlock = [onFailedBlock copy];
        }
        if (onProgressChangedBlock) {
            _onRequestProgressChangedBlock = [onProgressChangedBlock copy];
        }
        if (localFilePath) {
            _filePath = localFilePath;
        }
        self.loadingMessage = loadingMessage;
        if (!self.loadingMessage) {
            self.loadingMessage = DEFAULT_LOADING_MESSAGE;
        }
        _requestStartDate = [NSDate date];
        _userinfo = [[NSDictionary alloc] initWithDictionary:params];
        BOOL useCurrentCache = NO;
        NSObject *cacheData = [[ZJDataCacheManager sharedManager] getCachedObjectByKey:_cacheKey];
        if (cacheData) {
            useCurrentCache = [self onReceivedCacheData:cacheData];
        }
        if (!useCurrentCache) {
            _usingCacheData = NO;
            [self doRequestWithParams:params];
            DDLogDebug(@"request %@ is created", [self class]);
        }else{
            _usingCacheData = YES;
            [self performSelector:@selector(doRelease) withObject:nil afterDelay:0.1f];
        }
    }
    return self;
}

#pragma mark - file download related init methods
+ (id)requestWithDelegate:(id<DataRequestDelegate>)delegate
           withParameters:(NSDictionary*)params
        withIndicatorView:(UIView*)indiView
        withCancelSubject:(NSString*)cancelSubject
             withFilePath:(NSString*)localFilePath
{
    
    ZJBaseDataRequest *request = [[[self class] alloc] initWithDelegate:delegate
                                                         withParameters:params
                                                      withIndicatorView:indiView
                                                      withCancelSubject:cancelSubject
                                                        withSilentAlert:NO
                                                           withCacheKey:nil
                                                          withCacheType:DataCacheManagerCacheTypeMemory
                                                           withFilePath:localFilePath];
    [[ZJDataRequestManager sharedManager] addRequest:request];
    return request;
}

+ (id)requestWithParameters:(NSDictionary*)params
          withIndicatorView:(UIView*)indiView
          withCancelSubject:(NSString*)cancelSubject
               withFilePath:(NSString*)localFilePath
          onRequestFinished:(void(^)(ZJBaseDataRequest *request))onFinishedBlock
          onProgressChanged:(void(^)(ZJBaseDataRequest *request,float))onProgressChangedBlock
{
    
    ZJBaseDataRequest *request = [[[self class] alloc]initWithParameters:params
                                                          withRequestUrl:nil
                                                             suffixParam:nil
                                                       withIndicatorView:indiView
                                                      withLoadingMessage:nil
                                                       withCancelSubject:cancelSubject
                                                         withSilentAlert:YES
                                                            withCacheKey:nil
                                                           withCacheType:DataCacheManagerCacheTypeMemory
                                                            withFilePath:localFilePath
                                                                withData:nil
                                                                downPath:nil
                                                          onRequestStart:nil
                                                       onRequestFinished:onFinishedBlock
                                                       onRequestCanceled:nil
                                                         onRequestFailed:nil
                                                       onProgressChanged:onProgressChangedBlock];
    [[ZJDataRequestManager sharedManager] addRequest:request];
    return request;
}

#pragma mark - lifecycle methods

- (void)doRelease
{
    //remove self from Request Manager to release self;
    [[ZJDataRequestManager sharedManager] removeRequest:self];
}

- (void)dealloc
{
    DDLogDebug(@"request %@ is released, time spend on this request:%f seconds",
            [self class],[[NSDate date] timeIntervalSinceDate:_requestStartDate]);
    if (_indicatorView) {
        //make sure indicator is closed
        [self showIndicator:NO];
    }
    if (_cancelSubject && _cancelSubject) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:_cancelSubject
                                                      object:nil];
    }
}

#pragma mark - util methods

+ (NSDictionary*)getDicFromString:(NSString*)cachedResponse
{
    NSData *jsonData = [cachedResponse dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
}

- (void)generateRequestHandler
{
    _requestDataHandler = [[ZJRequestJsonDataHandler alloc] init];
}

- (BOOL)onReceivedCacheData:(NSObject*)cacheData
{
    // handle cache data in subclass
    // return yes to finish request, return no to continue request from server
    [self notifyDelegateRequestDidSuccess];
    return NO;
}
//可以子类重写
- (void)processResult
{
    NSDictionary *resultDic = (self.handleredResult);
    _result = [[ZJRequestResult alloc] initWithCode:resultDic[@"err_cd"] withMessage:resultDic[@"hint"] withHandleredResult:resultDic];
    if (![_result isSuccess]) {
        DDLogDebug(@"request[%@] failed with message %@",self,_result.code);
    }else {
        DDLogDebug(@"request[%@] :%@" ,self ,@"success");
    }
}

- (BOOL)processDownloadFile
{
    return FALSE;
}

- (NSString*)encodeURL:(NSString *)string
{
    NSString *newString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
    if (newString) {
        return newString;
    }
    return @"";
}

- (void)cancelRequest
{
}

- (void)showNetowrkUnavailableAlertView:(NSString*)message
{
    if (message && [message length]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)showIndicator:(BOOL)bshow
{
    _isLoading = bshow;
    if (bshow && _indicatorView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD showHUDAddedTo:_indicatorView animated:YES];
        });
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD showHUDAddedTo:_indicatorView animated:YES];
        });
    }
}

- (void)cacheResult
{
    if ([self.result isSuccess] && _cacheKey) {
        if (DataCacheManagerCacheTypeMemory == _cacheType) {
            [[ZJDataCacheManager sharedManager] addObjectToMemory:self.handleredResult forKey:_cacheKey];
        }
        else{
            [[ZJDataCacheManager sharedManager] addObject:self.handleredResult forKey:_cacheKey];
        }
    }
}

- (void)notifyDelegateRequestDidSuccess
{
     [self showIndicator:NO];
    if (_onRequestFinishBlock) {
        _onRequestFinishBlock(self);
    }
}

- (void)notifyDelegateRequestDidErrorWithError:(NSError*)error
{
    //using block callback
     [self showIndicator:NO];
    if (_onRequestFailedBlock) {
        _onRequestFailedBlock(self, error);
    }
}

- (BOOL)isDownloadFileRequest
{
    return _filePath && [_filePath length];
}

- (BOOL)handleResultString:(NSString*)resultString
{
    BOOL success = FALSE;
    NSError *error = nil;
    if([self isDownloadFileRequest]) {
        success = [self processDownloadFile];
    }
    else {
        self.rawResultString = resultString;
//        DDLogDebug(@"raw response string:%@", self.rawResultString);
        //add callback here
        if (!self.rawResultString || ![self.rawResultString length]) {
            DDLogDebug(@"!empty response error with request:%@", [self class]);
            [self notifyDelegateRequestDidErrorWithError:nil];
            return NO;
        }
        [self generateRequestHandler];
        self.handleredResult = [self.requestDataHandler handleResultString:self.rawResultString error:&error];
        if(self.handleredResult) {
            success = TRUE;
            [self processResult];
        }
        else {
            success = FALSE;
        }
    }
    if (success) {
        [self cacheResult];
        [self notifyDelegateRequestDidSuccess];
    }
    else {
        DDLogDebug(@"parse error %@", error);
        [self notifyDelegateRequestDidErrorWithError:error];
    }
    return success;
}
-(BOOL)isSuccess
{
    if (self.result) {
        return self.result.isSuccess;
    }else
    {
        return _isSuccess;
    }
}
-(BOOL)isNULLData
{
    if (self.result) {
        return self.result.isNULLData;
    }else
    {
        return _isNULLData;
    }
}
#pragma mark - hook methods
- (void)doRequestWithParams:(NSDictionary*)params
{
    SHOULDOVERRIDE(@"ZJBaseDataRequest", NSStringFromClass([self class]));
    DDLogDebug(@"should implement request logic here!");
}

- (NSStringEncoding)getResponseEncoding
{
    return NSUTF8StringEncoding;
    //return CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
}

- (NSDictionary*)getStaticParams
{
    return nil;
}

- (ZJRequestMethod)getRequestMethod
{
    return ZJRequestMethodGet;
}

- (NSString*)getRequestUrl
{
    if (!_requestUrl||![_requestUrl length]) {
        SHOULDOVERRIDE(@"ZJBaseDataRequest", NSStringFromClass([self class]));
    }
    return @"";
}
-(NSString*)downPath
{
    if (!_downPath) {
        
        return [self dataFilePath];
    }
    return _downPath;
}
//创建默认路径
-(NSString *)dataFilePath {
    NSArray * myPaths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
    NSString * myDocPath = [myPaths objectAtIndex:0];
    NSString *myfileGroup = [myDocPath stringByAppendingString:@"/ZJAFNet"];
    [self createFolder:myfileGroup];
    
    NSString *filename = [myfileGroup stringByAppendingFormat:@"/%@",@"downData"];
    
    return filename;
}
- (void)createFolder:(NSString *)createDir
{
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:createDir isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:createDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
}
- (NSString*)getRequestHost
{
    return DATA_ENV.urlRequestHost;
}
@end
