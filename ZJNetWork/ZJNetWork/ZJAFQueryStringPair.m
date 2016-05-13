//
//  AFQueryStringPair.m
//  iTotemFramework
//
//  Created by Sword Zhou on 7/18/13.
//  Copyright (c) 2013 iTotemStudio. All rights reserved.
//

#import "ZJAFQueryStringPair.h"
#import "NSString+ZJAdditions.h"

@implementation ZJAFQueryStringPair

@synthesize field = _field;
@synthesize value = _value;

- (id)initWithField:(id)field value:(id)value
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.field = field;
    self.value = value;
    return self;
}

- (NSString *)urlEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding
{
    if (!self.value || [self.value isEqual:[NSNull null]]) {
        return [[self.field description] encodeUrl];
    }
    else {
        return [NSString stringWithFormat:@"%@=%@", [[self.field description] encodeUrl], [[self.value description] encodeUrl]];
    }
}

@end

#pragma mark -
NSString * ZJAFQueryStringFromParametersWithEncoding(NSDictionary *parameters, NSStringEncoding stringEncoding)
{
    NSMutableArray *mutablePairs = [NSMutableArray array];
    for (ZJAFQueryStringPair *pair in ZJAFQueryStringPairsFromDictionary(parameters)) {
        [mutablePairs addObject:[pair urlEncodedStringValueWithEncoding:stringEncoding]];
    }
    return [mutablePairs componentsJoinedByString:@"&"];
}

NSArray * ZJAFQueryStringPairsFromDictionary(NSDictionary *dictionary)
{
    return ZJAFQueryStringPairsFromKeyAndValue(nil, dictionary);
}

NSArray * ZJAFQueryStringPairsFromKeyAndValue(NSString *key, id value)
{
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];
    if (value) {
        if ([value isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dictionary = value;
            // Sort dictionary keys to ensure consistent ordering in query string, which is important when deserializing potentially ambiguous sequences, such as an array of dictionaries
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES selector:@selector(caseInsensitiveCompare:)];
            for (id nestedKey in [dictionary.allKeys sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
                id nestedValue = [dictionary objectForKey:nestedKey];
                if (nestedValue) {
                    [mutableQueryStringComponents addObjectsFromArray:ZJAFQueryStringPairsFromKeyAndValue((key ? [NSString stringWithFormat:@"%@[%@]", key, nestedKey] : nestedKey), nestedValue)];
                }
            }
        }
        else if ([value isKindOfClass:[NSArray class]]) {
            NSArray *array = value;
            for (id nestedValue in array) {
                [mutableQueryStringComponents addObjectsFromArray:ZJAFQueryStringPairsFromKeyAndValue([NSString stringWithFormat:@"%@[]", key], nestedValue)];
            }
        }
        else if ([value isKindOfClass:[NSSet class]]) {
            NSSet *set = value;
            for (id obj in set) {
                [mutableQueryStringComponents addObjectsFromArray:ZJAFQueryStringPairsFromKeyAndValue(key, obj)];
            }
        }
        else {
            ZJAFQueryStringPair *pair = [[ZJAFQueryStringPair alloc] initWithField:key value:value];
            [mutableQueryStringComponents addObject:pair];
        }
    }
    return mutableQueryStringComponents;
}
