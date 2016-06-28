//
//  ZJUrlConnectionOperation.m
//  ZJMinFramework
//
//  Created by Tom on 13-10-14.
//
//

#import "ZJUrlConnectionOperation.h"

@interface ZJUrlConnectionOperation()<NSURLConnectionDelegate,NSURLConnectionDataDelegate>
{
    
}

#if !OS_OBJECT_USE_OBJC
@property (nonatomic, assign) dispatch_queue_t saveDataDispatchQueue;
@property (nonatomic, assign) dispatch_group_t saveDataDispatchGroup;
#else
@property (nonatomic, strong) dispatch_queue_t saveDataDispatchQueue;
@property (nonatomic, strong) dispatch_group_t saveDataDispatchGroup;
#endif


@end

@implementation ZJUrlConnectionOperation

@synthesize state = _state;

static NSInteger ZJHTTPRequestTaskCount = 0;

- (void)dealloc
{
    self.operationSavePath = nil;
    self.operationRequest = nil;
    self.operationURLResponse = nil;
    self.operationFileHandle = nil;
    self.operationData = nil;
    self.responseData = nil;
    
#if !OS_OBJECT_USE_OBJC
    dispatch_release(_saveDataDispatchGroup);
    dispatch_release(_saveDataDispatchQueue);
#endif
}

- (ZJUrlConnectionOperation *)initWithURLRequest:(NSMutableURLRequest *)urlRequest saveToPath:(NSString*)savePath progress:(void (^)(float progress))progressBlock onRequestStart:(void(^)(ZJUrlConnectionOperation *urlConnectionOperation))onStartBlock completion:(ZJHTTPRequestCompletionHandler)completionBlock;
{
    self = [super init];
    self.operationCompletionBlock = completionBlock;
    self.operationProgressBlock = progressBlock;
    self.operationRequest = urlRequest;
    self.operationSavePath = savePath;
    self.saveDataDispatchGroup = dispatch_group_create();
    self.saveDataDispatchQueue = dispatch_queue_create("com.ISS.ZJHTTPRequest", DISPATCH_QUEUE_SERIAL);
    
    if (onStartBlock) {
        _onRequestStartBlock = [onStartBlock copy];
    }
    return self;
}

- (void)cancel
{
    if(![self isFinished]){
        return;
    }
    [super cancel];
    [self finish];
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isFinished
{
    return self.state == ZJHTTPRequestStateFinished;
}

- (BOOL)isExecuting
{
    return self.state == ZJHTTPRequestStateExecuting;
}

- (ZJHTTPRequestState)state
{
    @synchronized(self) {
        return _state;
    }
}

- (void)setState:(ZJHTTPRequestState)newState
{
    @synchronized(self) {
        [self willChangeValueForKey:@"state"];
        _state = newState;
        [self didChangeValueForKey:@"state"];
    }
}

- (void)finish
{
    [self.operationConnection cancel];
    self.operationConnection = nil;
    [self decreaseSVHTTPRequestTaskCount];
    
#if TARGET_OS_IPHONE
    if(self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
        self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    }
#endif
    
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    self.state = ZJHTTPRequestStateFinished;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (void)increaseSVHTTPRequestTaskCount
{
    ZJHTTPRequestTaskCount++;
    [self toggleNetworkActivityIndicator];
}

- (void)decreaseSVHTTPRequestTaskCount
{
    ZJHTTPRequestTaskCount = MAX(0, ZJHTTPRequestTaskCount-1);
    [self toggleNetworkActivityIndicator];
}

- (void)toggleNetworkActivityIndicator
{
#if TARGET_OS_IPHONE
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:(ZJHTTPRequestTaskCount > 0)];
    });
#endif
}

- (void)main
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self increaseSVHTTPRequestTaskCount];
    });
    
    [self willChangeValueForKey:@"isExecuting"];
    self.state = ZJHTTPRequestStateExecuting;
    [self didChangeValueForKey:@"isExecuting"];
    
#if TARGET_OS_IPHONE
    // all requests should complete and run completion block unless we explicitely cancel them.
    self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        if(self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
            self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        }
    }];
#endif
    if(self.operationSavePath) {
        [[NSFileManager defaultManager] createFileAtPath:self.operationSavePath contents:nil attributes:nil];
        self.operationFileHandle = [NSFileHandle fileHandleForWritingAtPath:self.operationSavePath];
    }

    self.operationConnection = [[NSURLConnection alloc] initWithRequest:self.operationRequest delegate:self startImmediately:NO];
    NSOperationQueue *currentQueue = [NSOperationQueue currentQueue];
    BOOL inBackgroundAndInOperationQueue = (currentQueue != nil && currentQueue != [NSOperationQueue mainQueue]);
    NSRunLoop *targetRunLoop = (inBackgroundAndInOperationQueue) ? [NSRunLoop currentRunLoop] : [NSRunLoop mainRunLoop];
    [self.operationConnection scheduleInRunLoop:targetRunLoop forMode:NSDefaultRunLoopMode];
    [self.operationConnection start];
    
    if(inBackgroundAndInOperationQueue) {
        self.operationRunLoop = CFRunLoopGetCurrent();
        CFRunLoopRun();
    }
    if (_onRequestStartBlock) {
        __weak __typeof(&*self)weakSelf = self;
        _onRequestStartBlock(weakSelf);
    }
}

#pragma mark - NSURLConnectionDelegate

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.expectedContentLength = response.expectedContentLength;
    self.receivedContentLength = 0;
    self.operationURLResponse = (NSHTTPURLResponse *)response;
    self.operationData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    dispatch_group_async(self.saveDataDispatchGroup, self.saveDataDispatchQueue, ^{
        if(self.operationSavePath) {
            @try {
                [self.operationFileHandle writeData:data];
            }@catch (NSException *exception) {
                [self.operationConnection cancel];
                NSError *writeError = [NSError errorWithDomain:@"ZJHTTPRequestWriteError" code:0 userInfo:exception.userInfo];
                [self callCompletionBlockWithResponse:nil requestSuccess:NO error:writeError];
            }
        } else {
            [self.operationData appendData:data];
        }
    });
    
    if(self.operationProgressBlock) {
        //If its -1 that means the header does not have the content size value
        if(self.expectedContentLength != -1) {
            self.receivedContentLength += data.length;
            self.operationProgressBlock(self.receivedContentLength/self.expectedContentLength);
        } else {
            //we dont know the full size so always return -1 as the progress
            self.operationProgressBlock(-1);
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSData *response = [NSData dataWithData:self.operationData];
    [self callCompletionBlockWithResponse:response requestSuccess:YES error:nil];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self callCompletionBlockWithResponse:nil requestSuccess:NO error:error];
}

-(void)callCompletionBlockWithResponse:(NSData *)response requestSuccess:(BOOL)requestSuccess error:(NSError *)error
{
    self.responseData = response;
    if(self.operationRunLoop){
        CFRunLoopStop(self.operationRunLoop);
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *serverError = error;
        if(!serverError) {
            serverError = [NSError errorWithDomain:NSURLErrorDomain
                                              code:NSURLErrorBadServerResponse
                                          userInfo:nil];
        }
        __weak __typeof(&*self)weakSelf = self;
        if(self.operationCompletionBlock && !self.isCancelled){
            self.operationCompletionBlock(weakSelf,requestSuccess, serverError);
        }
        [self finish];
    });
}

@end
