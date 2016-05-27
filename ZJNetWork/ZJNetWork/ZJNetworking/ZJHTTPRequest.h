//
//  ZJHTTPRequest.h
//  iTotemMinFramework
//
//  Created by Tom on 13-11-4.
//
//

#import <Foundation/Foundation.h>
#import "ZJHttpRequestManager.h"
#import "ZJBaseDataRequest.h"

@interface ZJHTTPRequest : NSObject
{
    void (^_onRequestStartBlock)(ZJUrlConnectionOperation *);
    void (^_onRequestFinishBlock)(ZJUrlConnectionOperation *);
    void (^_onRequestCanceled)(ZJUrlConnectionOperation *);
    void (^_onRequestFailedBlock)(ZJUrlConnectionOperation *, NSError *);
    void (^_onRequestProgressChangedBlock)(ZJUrlConnectionOperation *, float);
}

@property (nonatomic, strong) NSString                  *requestURL;
@property (nonatomic, strong) NSMutableDictionary       *requestParameters;
@property (nonatomic, assign) ZJRequestMethod          requestMethod;
@property (nonatomic, assign) NSStringEncoding          requestEncoding;
@property (nonatomic, strong) NSMutableURLRequest       *request;
@property (nonatomic, strong) NSMutableData             *bodyData;
@property (nonatomic, strong) ZJUrlConnectionOperation *urlConnectionOperation;
@property (nonatomic, strong) NSString                  *filePath;
@property (nonatomic, assign) ZJParameterEncoding      parmaterEncoding;

- (ZJHTTPRequest *)initRequestWithParameters:(NSDictionary *)parameters URL:(NSString *)url saveToPath:(NSString *)filePath requestEncoding:(NSStringEncoding)requestEncoding parmaterEncoding:(ZJParameterEncoding)parameterEncoding  requestMethod:(ZJRequestMethod)requestMethod
                               onRequestStart:(void(^)(ZJUrlConnectionOperation *request))onStartBlock
                            onProgressChanged:(void(^)(ZJUrlConnectionOperation *request,float progress))onProgressChangedBlock
                            onRequestFinished:(void(^)(ZJUrlConnectionOperation *request))onFinishedBlock
                            onRequestCanceled:(void(^)(ZJUrlConnectionOperation *request))onCanceledBlock
                              onRequestFailed:(void(^)(ZJUrlConnectionOperation *request ,NSError *error))onFailedBlock;

- (void)setTimeoutInterval:(NSTimeInterval)seconds;
- (void)addPostForm:(NSString *)key value:(NSString *)value;
- (void)addPostData:(NSString *)key data:(NSString *)data;
- (void)setRequestHeaderField:(NSString *)field value:(NSString *)value;
- (void)cancelRequest;
- (void)startRequest;

@end
