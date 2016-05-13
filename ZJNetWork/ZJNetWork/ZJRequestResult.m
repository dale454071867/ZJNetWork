//
//  HHRequestResult
//
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ZJRequestResult.h"

@interface ZJRequestResult()<UIAlertViewDelegate>
@property(nonatomic,strong)NSString *upUrl;
@end

@implementation ZJRequestResult
///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

-(id)initWithCode:(NSNumber*)code withMessage:(NSString*)message withHandleredResult:(NSDictionary*)dic
{
    self = [super init];
    if (self) {
        _code = @([code integerValue]);
        _message = message;
        _data = dic[@"data"];
    }
    return self;
}



-(BOOL)isSuccess
{
    return (_code && [_code intValue] == 0);
}
-(BOOL)isNULLData
{
    if([[self.data allValues] count]!=1)
    {
        return NO;
    };
    if (_code && [[self.data allValues][0] isKindOfClass:[NSArray class]] && [[self.data allValues][0] count]==0) {
        return YES;
    }
    return NO;
}


@end