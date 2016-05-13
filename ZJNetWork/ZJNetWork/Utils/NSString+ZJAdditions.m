//
//  NSString+ZJAdditions.m
//
//  Created by Jack on 11-9-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
//#import "UIFont+ZJAdditions.h"
//#import "GTMBase64.h"
//#import "NSData+AES.h"
@implementation NSString (ZJAdditions)



- (CGFloat)heightWithFont:(UIFont*)font
            withLineWidth:(NSInteger)lineWidth
{
     CGSize size = [self boundingRectWithSize:CGSizeMake(lineWidth, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:font} context:nil].size;

	return size.height;
}



- (NSString *)md5
{
	const char *concat_str = [self UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(concat_str, (CC_LONG)strlen(concat_str), result);
	NSMutableString *hash = [NSMutableString string];
	for (int i = 0; i < 16; i++){
		[hash appendFormat:@"%02X", result[i]];
	}
	return [hash lowercaseString];
    
}
//sha1加密方式
- (NSString *)sha1{
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString* result = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    
    return result;
}
- (NSString*)encodeUrl
{
	NSString *newString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
	if (newString) {
		return newString;
	}
	return @"";
}

- (BOOL)isStartWithString:(NSString*)start
{
    BOOL result = FALSE;
    NSRange found = [self rangeOfString:start options:NSCaseInsensitiveSearch];
    if (found.location == 0)
    {
        result = TRUE;
    }
    return result;
}

- (BOOL)isEndWithString:(NSString*)end
{
    NSInteger endLen = [end length];
    NSInteger len = [self length];
    BOOL result = TRUE;
    if (endLen <= len) {
        NSInteger index = len - 1;
        for (NSInteger i = endLen - 1; i >= 0; i--) {
            if ([end characterAtIndex:i] != [self characterAtIndex:index]) {
                result = FALSE;
                break;
            }
            index--;
        }
    }
    else {
        result = FALSE;
    }
    return result;
}
- (NSString *) phonetic:(NSString*)sourceString {
    NSMutableString *source = [sourceString mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)source, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)source, NULL, kCFStringTransformStripDiacritics, NO);
    return source;
}

+(id)getParameterOfParameterStr:(NSString*)parameterStr
{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    NSArray *parameterArr = [parameterStr componentsSeparatedByString:@"&"];
    for (NSString *parameter in parameterArr) {
        NSRange rang = [parameter rangeOfString:@"="];
        NSString *dicKey = [parameter substringToIndex:rang.location];
        NSString *dicValue = nil;
        if (parameter.length>rang.location) {
            dicValue = [parameter substringFromIndex:rang.location+1];
        }
        if (dic && dicValue) {
            [dic setObject:dicValue forKey:dicKey];
        }else
        {
            return @"非法字符串";
        }
    }
    return dic;
}




@end

