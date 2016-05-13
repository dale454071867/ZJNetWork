//
//  ZJUrlConnectionOperation.h
//  iTotemMinFramework
//
//  Created by Tom on 13-10-14.
//
//

#import <Foundation/Foundation.h>
@class ZJUrlConnectionOperation;

enum {
    ZJHTTPRequestStateReady = 0,
    ZJHTTPRequestStateExecuting,
    ZJHTTPRequestStateFinished
};
typedef NSUInteger ZJHTTPRequestState;

enum {
	ZJHTTPRequestMethodGET = 0,
    ZJHTTPRequestMethodPOST,
    ZJHTTPRequestMethodPUT,
    ZJHTTPRequestMethodDELETE,
    ZJHTTPRequestMethodHEAD
};
typedef NSUInteger ZJHTTPRequestMethod;

typedef void (^ZJHTTPRequestCompletionHandler)(ZJUrlConnectionOperation *urlConnectionOperation,BOOL requestSuccess, NSError *error);

@protocol ZJUrlConnectionOperationDelegate <NSObject>

@end

@interface ZJUrlConnectionOperation : NSOperation
{
    void (^_onRequestStartBlock)(ZJUrlConnectionOperation *);
}

@property (nonatomic, strong) NSMutableURLRequest           *operationRequest;
@property (nonatomic, strong) NSData                        *responseData;
@property (nonatomic, strong) NSHTTPURLResponse             *operationURLResponse;
@property (nonatomic, readwrite) NSUInteger                 timeoutInterval;
@property (nonatomic, copy) ZJHTTPRequestCompletionHandler operationCompletionBlock;
@property (nonatomic, strong) NSFileHandle                  *operationFileHandle;

@property (nonatomic, strong) NSString                      *operationSavePath;

@property (nonatomic, strong) NSURLConnection               *operationConnection;
@property (nonatomic, strong) NSMutableData                 *operationData;
@property (nonatomic, assign) CFRunLoopRef                  operationRunLoop;
//@property (nonatomic, strong) NSTimer                       *timeoutTimer;
@property (nonatomic, readwrite) UIBackgroundTaskIdentifier backgroundTaskIdentifier;

@property (nonatomic, readwrite) ZJHTTPRequestState        state;
@property (nonatomic, readwrite) float                      expectedContentLength;
@property (nonatomic, readwrite) float                      receivedContentLength;
@property (nonatomic, copy) void (^operationProgressBlock)(float progress);

- (ZJUrlConnectionOperation *)initWithURLRequest:(NSURLRequest *)urlRequest saveToPath:(NSString*)savePath progress:(void (^)(float progress))progressBlock           onRequestStart:(void(^)(ZJUrlConnectionOperation *urlConnectionOperation))onStartBlock
  completion:(ZJHTTPRequestCompletionHandler)completionBlock;

@end
