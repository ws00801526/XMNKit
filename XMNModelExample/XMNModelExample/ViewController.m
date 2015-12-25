//
//  ViewController.m
//  XMNModelExample
//
//  Created by ChenMaolei on 15/12/25.
//  Copyright © 2015年 XMFraker. All rights reserved.
//

#import "ViewController.h"

#import "YYWeiboModel.h"

#import "NSObject+XMNModel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    /// get json data
    /// get json data
    NSString *path = [[NSBundle mainBundle] pathForResource:@"weibo" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    /// Benchmark
    int count = 1000;
    NSTimeInterval begin, end;
    begin = CACurrentMediaTime();
    id object;
    for (int i = 0 ; i < 10 ; i ++) {
        object = [YYWeiboStatus xmn_modelWithJSON:json];
    }
    end = CACurrentMediaTime();
    NSLog(@"this is time :%.2f",end - begin);

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
