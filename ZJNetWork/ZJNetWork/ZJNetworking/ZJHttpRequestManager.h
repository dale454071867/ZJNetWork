//
//  ZJHttpRequest.h
//  iTotemMinFramework
//
//  Created by Tom on 13-10-14.
//
//

#import <Foundation/Foundation.h>
#import "ZJUrlConnectionOperation.h"
@protocol ZJHttpRequestManagerDelegate <NSObject>



@end
@interface ZJHttpRequestManager : NSObject
{
    void (^_onRequestStartBlock)(ZJUrlConnectionOperation *);
    void (^_onRequestFinishBlock)(ZJUrlConnectionOperation *);
    void (^_onRequestCanceled)(ZJUrlConnectionOperation *);
    void (^_onRequestFailedBlock)(ZJUrlConnectionOperation *, NSError *);
    void (^_onRequestProgressChangedBlock)(ZJUrlConnectionOperation *, float);
}

@property (nonatomic,strong) NSOperationQueue *connectionQueue;

+ (ZJHttpRequestManager *)sharedHttpRequestManager;


- (ZJUrlConnectionOperation *)requestWithURLRequest:(NSMutableURLRequest *)request saveToPath:(NSString *)filePath onRequestStart:(void(^)(ZJUrlConnectionOperation *request))onStartBlock
            onProgressChanged:(void(^)(ZJUrlConnectionOperation *request,float progress))onProgressChangedBlock
            onRequestFinished:(void(^)(ZJUrlConnectionOperation *request))onFinishedBlock
              onRequestFailed:(void(^)(ZJUrlConnectionOperation *request ,NSError *error))onFailedBlock;


@end
