//
//  ZJDataRequestManager.m
//  ZJFrame
//
//  Created by jack 廉洁 on 3/12/12.
//  Copyright (c) 2012 ZJStudio. All rights reserved.
//

#import "ZJDataRequestManager.h"
#import "ZJObjectSingleton.h"
#import "ZJBaseDataRequest.h"

@interface ZJDataRequestManager()
- (void)restore;
@end

@implementation ZJDataRequestManager

ZJOBJECT_SINGLETON_BOILERPLATE(ZJDataRequestManager, sharedManager)

- (id)init
{
    self = [super init];
    if(self){
        [self restore];
    }
    return self;
}


#pragma mark - private methods
- (void)restore
{
    _requests = [[NSMutableArray alloc] init];
}

#pragma mark - public methods
- (void)addRequest:(ZJBaseDataRequest*)request
{
    [_requests addObject:request];
}

- (void)removeRequest:(ZJBaseDataRequest*)request
{
    [_requests removeObject:request];
}

@end
