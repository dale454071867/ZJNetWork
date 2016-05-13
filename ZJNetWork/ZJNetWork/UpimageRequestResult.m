//
//  UpimageRequestResult.m
//  anyi
//
//  Created by 周杰 on 15/8/3.
//  Copyright (c) 2015年 周杰. All rights reserved.
//

#import "UpimageRequestResult.h"

@implementation UpimageRequestResult
-(BOOL)isSuccess
{
    return (self.code && [self.code intValue] == 200);
}
-(id)initWithCode:(NSNumber*)code withMessage:(NSString*)message withHandleredResult:(NSDictionary*)dic
{
    self = [super init];
    if (self) {
        self.code = @([code integerValue]);
        self.message = message;
        self.data = dic;
    }
    return self;
}
@end
