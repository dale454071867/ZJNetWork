//
//  HHRequestResult.h
//
//  Copyright 2010 Apple Inc. All rights reserved.
//
//#import "ZJBaseModelObject.h"

@interface ZJRequestResult : NSObject

@property (nonatomic,strong) NSNumber *code;
@property(nonatomic,assign)BOOL isNULLData;
@property (nonatomic,strong) NSString *message;
@property(nonatomic,strong)id data;
@property(nonatomic,assign)BOOL isSuccess;
- (id)initWithCode:(NSNumber*)code withMessage:(NSString*)message withHandleredResult:(NSDictionary*)dic;
- (BOOL)isSuccess;

@end
