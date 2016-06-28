//
//  RequestDataHandler.h
//  ZJFramework
//
//  Created by Sword on 13-9-5.
//  Copyright (c) 2013年 ZJStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZJRequestDataHandler : NSObject

- (id)handleResultString:(NSString *)resultString error:(NSError **)error;

@end
