//
//  ZJHttpRequest.m
//  ZJMinFramework
//
//  Created by Tom on 13-10-14.
//
//

#import "ZJHttpRequestManager.h"
#import "ZJObjectSingleton.h"

@implementation ZJHttpRequestManager

ZJOBJECT_SINGLETON_BOILERPLATE(ZJHttpRequestManager, sharedHttpRequestManager)

- (id)init
{
    self = [super init];
	if (self) {
        self.connectionQueue  = [[NSOperationQueue alloc] init];
        [self.connectionQueue setMaxConcurrentOperationCount:4];
	}
	return self;
}

- (ZJUrlConnectionOperation *)requestWithURLRequest:(NSMutableURLRequest *)request saveToPath:(NSString *)filePath onRequestStart:(void(^)(ZJUrlConnectionOperation *request))onStartBlock
            onProgressChanged:(void(^)(ZJUrlConnectionOperation *request,float progress))onProgressChangedBlock
            onRequestFinished:(void(^)(ZJUrlConnectionOperation *request))onFinishedBlock
            onRequestFailed:(void(^)(ZJUrlConnectionOperation *request ,NSError *error))onFailedBlock

{
    if (onStartBlock) {
        _onRequestStartBlock = [onStartBlock copy];
    }
    if (onFinishedBlock) {
        _onRequestFinishBlock = [onFinishedBlock copy];
    }
    if (onFailedBlock) {
        _onRequestFailedBlock = [onFailedBlock copy];
    }
    if (onProgressChangedBlock) {
        _onRequestProgressChangedBlock = [onProgressChangedBlock copy];
    }
    
    __block ZJUrlConnectionOperation *operation =  [[ZJUrlConnectionOperation alloc] initWithURLRequest:request saveToPath:filePath progress:^(float progress) {
        if (_onRequestProgressChangedBlock) {
            _onRequestProgressChangedBlock(operation,progress);
        }
   } onRequestStart:^(ZJUrlConnectionOperation *urlConnectionOperation) {
       if (_onRequestStartBlock) {
           _onRequestStartBlock(operation);
       }
   } completion:^(ZJUrlConnectionOperation *urlConnectionOperation, BOOL requestSuccess, NSError *error) {
       if (requestSuccess) {
           if (_onRequestFinishBlock) {
               _onRequestFinishBlock(operation);
           }
       }else{
           if (_onRequestFailedBlock) {
               _onRequestFailedBlock(operation,error);
           }
       }
   }];
    [self.connectionQueue addOperation:operation];
    
    return operation;
}

@end
