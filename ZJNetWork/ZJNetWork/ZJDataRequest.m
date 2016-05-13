//
//  ZJHttpRequest.m
//  iTotemMinFramework
//
//  Created by Tom on 13-10-23.
//
//

#import "ZJDataRequest.h"
#import "ZJHttpRequestManager.h"
#import "ZJNetworkTrafficManager.h"
#import "ZJAFQueryStringPair.h"
//#import "AFHTTPClient.h"
#import "ZJDataEnvironment.h"
#import "ZJRequestJsonDataHandler.h"

@implementation ZJDataRequest

- (void)doRequestWithParams:(NSDictionary*)params
{
    __weak ZJBaseDataRequest *weakSelf = self;
    
    self.httpRequest = [[ZJHTTPRequest alloc] initRequestWithParameters:params URL:[self getRequestUrl] saveToPath:_filePath requestEncoding:[self getResponseEncoding] parmaterEncoding:self.parmaterEncoding requestMethod:[self getRequestMethod] onRequestStart:^(ZJUrlConnectionOperation *request) {
        if (_onRequestStartBlock) {
            _onRequestStartBlock(weakSelf);
        }
    } onProgressChanged:^(ZJUrlConnectionOperation *request, float progress) {
        if (_onRequestProgressChangedBlock) {
            _onRequestProgressChangedBlock(weakSelf,progress);
        }
    } onRequestFinished:^(ZJUrlConnectionOperation *request) {
//        ZJDINFO(@"*** onRequestFinished %@",[[NSString alloc] initWithData:request.responseData encoding:NSUTF8StringEncoding]);
        
        if (_filePath) {
            if (_onRequestFinishBlock) {
                _onRequestFinishBlock(weakSelf);
            }
        }else{
            [weakSelf handleResultString:[[NSString alloc] initWithData:request.responseData encoding:NSUTF8StringEncoding]];
        }
       
        [weakSelf showIndicator:NO];
        [weakSelf doRelease];
    } onRequestCanceled:^(ZJUrlConnectionOperation *request) {
        if (_onRequestCanceled) {
            _onRequestCanceled(weakSelf);
        }
        [weakSelf doRelease];
    } onRequestFailed:^(ZJUrlConnectionOperation *request, NSError *error) {
        [weakSelf notifyDelegateRequestDidErrorWithError:error];
        [weakSelf showIndicator:NO];
        [weakSelf doRelease];
    }];
    
    [self.httpRequest startRequest];
    [self showIndicator:YES];
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

- (void)doRelease
{
    [super doRelease];
    self.httpRequest = nil;
}

- (ZJRequestMethod)getRequestMethod
{
	return ZJRequestMethodGet;
}

- (NSString*)getRequestHost
{
	return @"Host://xxxx";
}

- (void)cancelRequest
{
    [self.httpRequest cancelRequest];
    //to cancel here

    if (_onRequestCanceled) {
        __weak ZJBaseDataRequest *weakSelf = self;
        _onRequestCanceled(weakSelf);
    }
    [self showIndicator:NO];
}

- (void)dealloc
{
}

@end
