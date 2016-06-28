//
//  ZJHTTPRequest.m
//  ZJMinFramework
//
//  Created by Tom on 13-11-4.
//
//

#import "ZJHTTPRequest.h"
#import "ZJAFQueryStringPair.h"
#import "ZJHttpRequestManager.h"
#import "ZJNetworkTrafficManager.h"
#import "MJExtension.h"
@interface ZJHTTPRequest()
{
    BOOL  _isUploadFile;
}

@end

@implementation ZJHTTPRequest

static NSString *boundary = @"ZJHTTPRequestBoundary";

- (void)dealloc
{
    self.requestURL = nil;
    self.request = nil;
    self.bodyData = nil;
    self.requestParameters = nil;
    self.urlConnectionOperation = nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        _isUploadFile = NO;
        self.requestURL = nil;
        self.requestParameters = nil;
        self.request = nil;
    }
    return self; 
}

- (void)setRequestHeaderField:(NSString *)field value:(NSString *)value
{
    [self.request setValue:value forHTTPHeaderField:field];
}

- (void)setTimeoutInterval:(NSTimeInterval)seconds
{
    [self.request setTimeoutInterval:seconds];
}

- (void)addPostForm:(NSString *)key value:(NSString *)value
{
    [self.requestParameters setObject:value forKey:key];
}

- (void)addPostData:(NSString *)key data:(NSString *)data
{
    [self.requestParameters setObject:data forKey:key];
}

- (ZJHTTPRequest *)initRequestWithParameters:(NSDictionary *)parameters URL:(NSString *)url  saveToPath:(NSString *)filePath requestEncoding:(NSStringEncoding)requestEncoding  parmaterEncoding:(ZJParameterEncoding)parameterEncoding requestMethod:(ZJRequestMethod)requestMethod onRequestStart:(void(^)(ZJUrlConnectionOperation *request))onStartBlock
                        onProgressChanged:(void(^)(ZJUrlConnectionOperation *request,float progress))onProgressChangedBlock
                        onRequestFinished:(void(^)(ZJUrlConnectionOperation *request))onFinishedBlock
                        onRequestCanceled:(void(^)(ZJUrlConnectionOperation *request))onCanceledBlock
                          onRequestFailed:(void(^)(ZJUrlConnectionOperation *request ,NSError *error))onFailedBlock
{
    self = [self init];
    if (self) {
        _isUploadFile = NO;
        self.requestURL = url;
        self.requestEncoding = requestEncoding;
        self.parmaterEncoding = parameterEncoding;
        self.requestMethod = requestMethod;
        self.filePath = filePath;
        if (parameters) {
            self.requestParameters = [[NSMutableDictionary alloc] initWithDictionary:parameters];
        }else{
            self.requestParameters = [[NSMutableDictionary alloc] init];
        }
        self.bodyData = [[NSMutableData alloc] init];
        self.request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.requestURL ]];
        [self.request setTimeoutInterval:60];
        
        if (onStartBlock) {
            _onRequestStartBlock = [onStartBlock copy];
        }
        if (onProgressChangedBlock) {
            _onRequestProgressChangedBlock = [onProgressChangedBlock copy];
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
    }
    return  self;
}

- (void)addBodyData:(NSString *)key value:(id)value
{
    if(![value isKindOfClass:[NSData class]] && ![value isKindOfClass:[UIImage class]]) {
        [self.bodyData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:self.requestEncoding]];
        [self.bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:self.requestEncoding]];
        [self.bodyData appendData:[[NSString stringWithFormat:@"%@", value] dataUsingEncoding:self.requestEncoding]];
        [self.bodyData appendData:[@"\r\n" dataUsingEncoding:self.requestEncoding]];
    } else {
        NSString *fileName = nil;
        NSData *data = nil;
        if ([value isKindOfClass:[UIImage class]]) {
            fileName = [NSString stringWithFormat:@"uploadfile_%@.png",key];
            data = UIImageJPEGRepresentation(value, 0.5f);
        } else {
            fileName = [NSString stringWithFormat:@"uploadfile_%@",key];
            data = value;
        }
        
        [self.bodyData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:self.requestEncoding]];
        [self.bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: attachment; name=\"%@\"; filename=\"%@\"\r\n", key, fileName] dataUsingEncoding:self.requestEncoding]];
        if ([value isKindOfClass:[UIImage class]]) {
            [self.bodyData appendData:[[NSString stringWithFormat:@"Content-Type: image/png\r\n\r\n"] dataUsingEncoding:self.requestEncoding]];
        } else {
            [self.bodyData appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:self.requestEncoding]];
        }
        [self.bodyData appendData:data];
        [self.bodyData appendData:[@"\r\n" dataUsingEncoding:self.requestEncoding]];
    }
}

- (void)parseRequestParameters
{
    __weak ZJHTTPRequest *weakSelf = self;
    
    __block BOOL hasData = NO;
    NSDictionary *paramsDict = (NSDictionary*)self.requestParameters;
    [paramsDict.allValues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if([obj isKindOfClass:[NSData class]] || [obj isKindOfClass:[UIImage class]]){
            hasData = YES;
        }
    }];
    if(!hasData) {
        _isUploadFile = NO;
        NSString *paramString = ZJAFQueryStringFromParametersWithEncoding(self.requestParameters,self.requestEncoding);
        NSData *postData = [paramString dataUsingEncoding:weakSelf.requestEncoding allowLossyConversion:YES];
        [weakSelf.bodyData appendData:postData];
    } else {
        _isUploadFile = YES;
        [paramsDict enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
            [weakSelf addBodyData:key value:value];
        }];
    }
}

- (NSMutableURLRequest *)generatePOSTRequest
{
    [self parseRequestParameters];
    [self.bodyData appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:self.requestEncoding]];
    long long postBodySize =  [self.bodyData length];
    if (_isUploadFile) {
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [self.request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    }else{
        [self.request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    }
    [self.request setValue:[NSString stringWithFormat:@"%llu",postBodySize] forHTTPHeaderField:@"Content-Length"];
    [self.request setHTTPBody:self.bodyData];
    [self.request setHTTPMethod:@"POST"];
    [[ZJNetworkTrafficManager sharedManager] logTrafficOut:postBodySize];
    return  self.request;
}

- (NSMutableURLRequest *)generateJSONPOSTRequest
{
    NSString *jsonString = [self.requestParameters mj_JSONString];
	NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    [self.bodyData appendData:jsonData];
    [self.bodyData appendData: [@"\r\n" dataUsingEncoding:self.requestEncoding]];

    long long postBodySize =  [self.bodyData length];
    [self.request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self.request setValue:[NSString stringWithFormat:@"%llu",postBodySize] forHTTPHeaderField:@"Content-Length"];
    [self.request setHTTPBody:self.bodyData];
    [self.request setHTTPMethod:@"POST"];
    [[ZJNetworkTrafficManager sharedManager] logTrafficOut:postBodySize];
    return  self.request;
}


- (NSMutableURLRequest *)generateGETRequest
{
    NSString *paramString = ZJAFQueryStringFromParametersWithEncoding(self.requestParameters,self.requestEncoding);
    NSUInteger found = [self.requestURL rangeOfString:@"?"].location;
    self.requestURL = [self.requestURL stringByAppendingFormat: NSNotFound == found ? @"?%@" : @"&%@", paramString];
    [self.request setURL:[NSURL URLWithString:self.requestURL]];
    [self.request setHTTPMethod:@"GET"];
    long long postBodySize = [self.requestURL lengthOfBytesUsingEncoding:self.requestEncoding];
    [[ZJNetworkTrafficManager sharedManager] logTrafficOut:postBodySize];
    return self.request;
}

- (void)startRequest
{
    switch ((NSInteger)self.requestMethod) {
        case ZJRequestMethodGet:{
            [self generateGETRequest];
        }
            break;
            
        case ZJRequestMethodPost:{
            switch ((NSInteger)self.parmaterEncoding) {
                case ZJURLParameterEncoding: {
                    [self generatePOSTRequest];
                }
                    break;
                
                case ZJJSONParameterEncoding: {
                    [self generateJSONPOSTRequest];
                }
                    break;
        
                case ZJPropertyListParameterEncoding: {
                    
                }
                    break;
            }
            break;
        }
        case ZJRequestMethodMultipartPost:{
            [self generatePOSTRequest];
        }
            break;
    }
    
    self.urlConnectionOperation = [[ZJHttpRequestManager sharedHttpRequestManager] requestWithURLRequest:self.request saveToPath:self.filePath
                      onRequestStart:^(ZJUrlConnectionOperation *request) {
                          if (_onRequestStartBlock) {
                              _onRequestStartBlock(request);
                          }
                    } onProgressChanged:^(ZJUrlConnectionOperation *request, float progress) {
                        if (_onRequestProgressChangedBlock) {
                            _onRequestProgressChangedBlock(request,progress);
                        }
                    } onRequestFinished:^(ZJUrlConnectionOperation *request) {
                        if (_onRequestFinishBlock) {
                            _onRequestFinishBlock(request);
                        }
                    } onRequestFailed:^(ZJUrlConnectionOperation *request, NSError *error) {
                        if (_onRequestFailedBlock) {
                            _onRequestFailedBlock(request,error);
                        }
                    }];
}

- (void)cancelRequest
{
    [self.urlConnectionOperation cancel];
    if (_onRequestCanceled) {
        _onRequestCanceled(self.urlConnectionOperation);
    }
}

@end

