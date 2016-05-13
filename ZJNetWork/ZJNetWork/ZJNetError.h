//
//  ZJNetError.h
//  anyi
//
//  Created by 周杰 on 16/4/6.
//  Copyright © 2016年 周杰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZJNetError : NSObject
+(NSString*)netErrorLocalizedDescription:(NSInteger)code;
@end
