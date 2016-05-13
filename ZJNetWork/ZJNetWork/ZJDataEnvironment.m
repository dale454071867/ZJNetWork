//
//  DataEnvironment.m
//  
//
//  Copyright 2010 itotem. All rights reserved.
//


#import "ZJDataEnvironment.h"
#import "ZJDataCacheManager.h"
#import "ZJNetworkTrafficManager.h"
#import "ZJObjectSingleton.h"
@interface ZJDataEnvironment()
- (void)restore;
- (void)registerMemoryWarningNotification;
@end
@implementation ZJDataEnvironment

ZJOBJECT_SINGLETON_BOILERPLATE(ZJDataEnvironment, sharedDataEnvironment)

#pragma mark - lifecycle methods


- (id)init
{
    self = [super init];
	if ( self) {
		[self restore];
        [self registerMemoryWarningNotification];
	}
	return self;
}

-(void)clearNetworkData
{
    [[ZJDataCacheManager sharedManager] clearAllCache];
}

#pragma mark - public methods

- (void)clearCacheData
{
    //clear cache data if needed
}

#pragma mark - private methods

- (void)restore
{
    _urlRequestHost = @"host://xxxx";
}

- (void)registerMemoryWarningNotification
{
#if TARGET_OS_IPHONE
    // Subscribe to app events
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearCacheData)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];    
#ifdef __IPHONE_4_0
    UIDevice *device = [UIDevice currentDevice];
    if ([device respondsToSelector:@selector(isMultitaskingSupported)] && device.multitaskingSupported){
        // When in background, clean memory in order to have less chance to be killed
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearCacheData)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
#endif
#endif        
}

@end