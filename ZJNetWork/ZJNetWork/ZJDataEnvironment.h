//
//  DataEnvironment.h
//
//  Copyright 2010 ZJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface ZJDataEnvironment : NSObject {
    NSString *_urlRequestHost;
}


@property (nonatomic,strong) NSString *urlRequestHost;


+ (ZJDataEnvironment *)sharedDataEnvironment;

- (void)clearNetworkData;
- (void)clearCacheData;

@end
