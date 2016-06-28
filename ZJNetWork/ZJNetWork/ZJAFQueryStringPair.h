//
//  AFQueryStringPair.h
//  ZJFramework
//
//  Created by Sword Zhou on 7/18/13.
//  Copyright (c) 2013 ZJStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * ZJAFQueryStringFromParametersWithEncoding(NSDictionary *parameters, NSStringEncoding stringEncoding);
extern NSArray * ZJAFQueryStringPairsFromDictionary(NSDictionary *dictionary);
extern NSArray * ZJAFQueryStringPairsFromKeyAndValue(NSString *key, id value);

@interface ZJAFQueryStringPair : NSObject

@property (strong, nonatomic) id field;
@property (strong, nonatomic) id value;

- (id)initWithField:(id)field value:(id)value;

- (NSString *)urlEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding;

@end
