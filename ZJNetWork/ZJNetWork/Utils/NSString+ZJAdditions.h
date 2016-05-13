//
//  NSString+ZJAdditions.h
//
//  Created by Jack on 11-9-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSString (ZJAdditions)

- (BOOL)isStartWithString:(NSString*)start;
- (BOOL)isEndWithString:(NSString*)end;


- (CGFloat)heightWithFont:(UIFont*)font withLineWidth:(NSInteger)lineWidth;

- (NSString*)md5;
- (NSString *)sha1;
- (NSString*)encodeUrl;
/**
 *  aes加密
 *
 *  @return self
 */
-(NSString*)aes;
/**
 *  aes解密
 *
 *  @return self
 */
-(NSString*)daes;
//汉子转拼音
- (NSString *) phonetic:(NSString*)sourceString;
-(NSString*)getDecodeBase64;
+(id)getParameterOfParameterStr:(NSString*)parameterStr;


+ (NSString*)encodeBase64String:(NSString*)input;

+ (NSString*)decodeBase64String:(NSString*)input;

+ (NSString*)encodeBase64Data:(NSData*)data;

+ (NSString*)decodeBase64Data:(NSData*)data;

-(NSURL*)makeUrl;

-(NSString*)removeSpace;


@end

