//
//  ViewController.m
//  ZJNetWork
//
//  Created by 周杰 on 16/5/12.
//  Copyright © 2016年 周杰. All rights reserved.
//

#import "ViewController.h"
#import "DemoRequest.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [DemoRequest requestCommentWithParameters:@{@"official":@"true"} onRequestFinished:^(ZJBaseDataRequest *request) {
        
    } onRequestFailed:^(ZJBaseDataRequest *request) {
        
    }];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
