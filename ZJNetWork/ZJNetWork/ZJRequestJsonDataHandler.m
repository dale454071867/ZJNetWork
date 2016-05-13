//
//  ZJRequestJsonDataHandler.m
//  iTotemFramework
//
//  Created by Sword on 13-9-5.
//  Copyright (c) 2013年 iTotemStudio. All rights reserved.
//

#import "ZJRequestJsonDataHandler.h"
//#import "NSDictionary_JSONExtensions.h"
@implementation ZJRequestJsonDataHandler

- (id)handleResultString:(NSString *)resultString error:(NSError **)error
{
//    NSMutableDictionary *returnDic;
//    resultString = [resultString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    if (![resultString isStartWithString:@"{"]) {
//        resultString = [NSString stringWithFormat:@"{\"data\":%@}", resultString];
//    }
//    NSData *jsonData = [resultString dataUsingEncoding:NSUTF8StringEncoding];
//    NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:error];
//    if(resultDic) {
//        returnDic = [[NSMutableDictionary alloc] initWithDictionary:resultDic];        
//    }
//     ;
//    id dic = [NSDictionary dictionaryWithJSONString:resultString error:error];
    id dic = [NSJSONSerialization JSONObjectWithData:[resultString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:error];
    
    return dic;
}

@end
