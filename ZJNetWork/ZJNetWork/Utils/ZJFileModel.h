//
//  ZJFileModel.h
//  iTotemFramework
//
//  Created by Sword Zhou on 8/8/13.
//  Copyright (c) 2013 iTotemStudio. All rights reserved.
//


#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>
@interface ZJFileModel : NSObject

@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic, strong) NSData *data;

@end
