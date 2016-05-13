//
//  ZJCacheDao.m
//  iTotemFramework
//
//  Created by Sword on 13-9-6.
//  Copyright (c) 2013年 iTotemStudio. All rights reserved.
//

#import "ZJCacheDao.h"

#define ZJSHOULDOVERRIDE(basename, subclassname){ NSAssert([basename isEqualToString:subclassname], @"subclass should override the method!");}
@implementation ZJCacheDao

- (BOOL)hasObjectInCacheByKey:(NSString*)key
{
    ZJSHOULDOVERRIDE(@"ZJCacheDao", NSStringFromClass([self class]));
    return TRUE;
}

- (BOOL)hasObjectInMemoryByKey:(NSString*)key
{
    ZJSHOULDOVERRIDE(@"ZJCacheDao", NSStringFromClass([self class]));
    return TRUE;
}

- (id)getCachedObjectByKey:(NSString*)key
{
    ZJSHOULDOVERRIDE(@"ZJCacheDao", NSStringFromClass([self class]));
    return nil;
}

- (void)restore
{
    ZJSHOULDOVERRIDE(@"ZJCacheDao", NSStringFromClass([self class]));
}

- (void)clearAllCache
{
}

- (void)clearAllDiskCache
{
}

- (void)clearMemoryCache
{
    ZJSHOULDOVERRIDE(@"ZJCacheDao", NSStringFromClass([self class]));    
}

- (void)addObject:(NSObject*)obj forKey:(NSString*)key
{
    ZJSHOULDOVERRIDE(@"ZJCacheDao", NSStringFromClass([self class]));    
}

- (void)addObjectToMemory:(NSObject*)obj forKey:(NSString*)key
{
    ZJSHOULDOVERRIDE(@"ZJCacheDao", NSStringFromClass([self class]));    
}

- (void)removeObjectInCacheByKey:(NSString*)key
{
    ZJSHOULDOVERRIDE(@"ZJCacheDao", NSStringFromClass([self class]));    
}

- (void)doSave
{
    ZJSHOULDOVERRIDE(@"ZJCacheDao", NSStringFromClass([self class]));    
}
@end
