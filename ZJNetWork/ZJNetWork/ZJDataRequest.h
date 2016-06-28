//
//  ZJHttpRequest.h
//  ZJMinFramework
//
//  Created by Tom on 13-10-23.
//
//

#import <Foundation/Foundation.h>
#import "ZJBaseDataRequest.h"
#import "ZJHttpRequestManager.h"
#import "ZJHTTPRequest.h"

@interface ZJDataRequest : ZJBaseDataRequest

@property (nonatomic, strong) ZJHTTPRequest *httpRequest;

@end
