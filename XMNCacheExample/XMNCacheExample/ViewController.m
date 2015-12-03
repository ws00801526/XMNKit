//
//  ViewController.m
//  XMNCacheExample
//
//  Created by shscce on 15/12/1.
//  Copyright © 2015年 xmfraker. All rights reserved.
//

#import "ViewController.h"

#import "XMNMemoryCache.h"

#import <objc/runtime.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString *test = @"dsadsad打算买看大门看了的门卡的大苏打门卡什么的克拉斯吗的克拉斯没电了昆明拉克是多么绿卡;吗";
    NSCache *cache = [[NSCache alloc] init];
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.baidu.com"]];
    NSLog(@"length :%ld",data.length);
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSLog(@"1 :%lu",sizeof(dict));
    [dict setObject:@"test" forKey:@"hhehehe"];
    
    NSLog(@"2 :%lu",sizeof(&dict));
    [dict setObject:@"sdasdasdsada" forKey:@"dsadas"];
    NSLog(@"3 :%lu",sizeof(data));

    
//    id testObject = test;
//    NSLog(@"1 :%lu",sizeof(test));
//    NSLog(@"2 :%lu",sizeof(testObject));
//    NSLog(@"3 :%lu",class_getInstanceSize([NSString class]));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
