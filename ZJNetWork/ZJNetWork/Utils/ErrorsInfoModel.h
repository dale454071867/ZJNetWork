//
//  ErrorsInfoModel.h
//  anyi
//
//  Created by 周杰 on 16/3/14.
//  Copyright © 2016年 周杰. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HEAD;
@class AYError;

@interface ErrorsInfoModel : NSObject
@property(nonatomic,strong)NSString *url;
@property(nonatomic,strong)NSDictionary *params;
@property(nonatomic,strong)HEAD *head;
@property(nonatomic,strong)AYError *error;
@property(nonatomic,strong)NSString *date;
@end

@interface HEAD : NSObject

@property (nonatomic, copy) NSString *app_version;

@property (nonatomic, copy) NSString *rssi;

@property (nonatomic, copy) NSString *mobile_id;

@property (nonatomic, copy) NSString *mobile_version;

@property (nonatomic, copy) NSString *mobile_model;

@property (nonatomic, copy) NSString *productFlavors;

@property (nonatomic, copy) NSString *net_type;

@property (nonatomic, copy) NSString *ip;

@end

@interface AYError: NSObject


@property (nonatomic, assign) NSInteger http_response_code;

@property (nonatomic, assign) NSInteger app_error_msg;

@property (nonatomic, assign) NSInteger time_out;


@end

@interface UIImageToDataTransformer : NSValueTransformer { }

@end