//
//  XMNCacheExampleTests.m
//  XMNCacheExampleTests
//
//  Created by shscce on 15/12/1.
//  Copyright © 2015年 xmfraker. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "XMNCache.h"

@interface XMNCacheExampleTests : XCTestCase

@end

@implementation XMNCacheExampleTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.

//    [self testDiskCacheWithSmallFile];
//    [self testDiskCacheReadSmallData:NO];
//    [self testDiskCacheReadSmallData:YES];
    
    
    [self testDiskCacheWithLargeFile];
    [self testDiskCacheReadLargeFile:NO];
    [self testDiskCacheReadLargeFile:YES];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}




+ (void)memoryCacheBenchmark {
    //    1.27  1.09
    //    2.86  5.57

    XMNMemoryCache *memoryCache = [[XMNMemoryCache alloc] init];
    
    NSMutableArray *keys = [NSMutableArray new];
    NSMutableArray *values = [NSMutableArray new];
    int count = 200000;
    for (int i = 0; i < count; i++) {
        NSObject *key;
        key = @(i); // avoid string compare
        //key = @(i).description; // it will slow down NSCache...
        //key = [NSUUID UUID].UUIDString;
        NSData *value = [NSData dataWithBytes:&i length:sizeof(int)];
        [keys addObject:key];
        [values addObject:value];
    }
    
    NSTimeInterval begin, end, time;
    
    
    printf("\n===========================\n");
    printf("Memory cache set 200000 key-value pairs\n");
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [memoryCache setObject:values[i] forKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("XMNMemoryCache:   %8.2f\n", time * 1000);
    
    
    printf("\n===========================\n");
    printf("Memory cache get 200000 key-value pairs\n");
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [memoryCache objectForKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("XMNMemoryCache:   %8.2f\n", time * 1000);
    
    
    printf("\n===========================\n");
    printf("Memory cache get 100000 key-value pairs randomly\n");
    
    for (NSUInteger i = keys.count; i > 1; i--) {
        [keys exchangeObjectAtIndex:(i - 1) withObjectAtIndex:arc4random_uniform((u_int32_t)i)];
    }
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [memoryCache objectForKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("XMNMemoryCache:   %8.2f\n", time * 1000);

    
    printf("\n===========================\n");
    printf("Memory cache get 200000 key-value pairs none exist\n");
    for (int i = 0; i < count; i++) {
        NSObject *key;
        key = @(i + count); // avoid string compare
        [keys addObject:key];
    }
    
    for (NSUInteger i = keys.count; i > 1; i--) {
        [keys exchangeObjectAtIndex:(i - 1) withObjectAtIndex:arc4random_uniform((u_int32_t)i)];
    }
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [memoryCache objectForKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("XMNMemoryCache:   %8.2f\n", time * 1000);
    
}


- (void)testDiskCacheWithSmallFile {
    NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) firstObject];
    basePath = [basePath stringByAppendingPathComponent:@"FileCacheBenchmarkSmall"];
    
    XMNDiskCache *diskCache = [[XMNDiskCache alloc] initWithPath:basePath];
    
    int count = 1000;
    NSMutableArray *keys = [NSMutableArray new];
    NSMutableArray *values = [NSMutableArray new];
    for (int i = 0; i < count; i++) {
        NSString *key = @(i).description;
        NSNumber *value = @(i);
        [keys addObject:key];
        [values addObject:value];
    }
    
    NSTimeInterval begin, end, time;
    
    printf("\n===========================\n");
    printf("Disk cache set 1000 key-value pairs (value is NSNumber)\n");
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [diskCache setObject:values[i] forKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("XMNDiskCache:     %8.2f\n", time * 1000);
    
}

- (void)testDiskCacheWithLargeFile {
    
    NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) firstObject];
    basePath = [basePath stringByAppendingPathComponent:@"FileCacheBenchmarkLarge"];
    
    XMNDiskCache *diskCache = [[XMNDiskCache alloc] initWithPath:basePath];
    
    int count = 1000;
    NSMutableArray *keys = [NSMutableArray new];
    for (int i = 0; i < count; i++) {
        NSString *key = @(i).description;
        [keys addObject:key];
    }
    NSMutableData *dataValue = [NSMutableData new]; // 32KB
    for (int i = 0; i < 100 * 1024; i++) {
        [dataValue appendBytes:&i length:1];
    }
    
    NSTimeInterval begin, end, time;
    
    
    printf("\n===========================\n");
    printf("Disk cache set 1000 key-value pairs (value is NSData(100KB))\n");
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            [diskCache setObject:dataValue forKey:keys[i]];
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("XMNDiskCache large file:     %8.2f\n", time * 1000);
    
}

- (void)testDiskCacheReadSmallData:(BOOL)random {
    NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) firstObject];
    basePath = [basePath stringByAppendingPathComponent:@"FileCacheBenchmarkSmall"];
    
    XMNDiskCache *diskCache = [[XMNDiskCache alloc] initWithPath:basePath];
    
    int count = 1000;
    NSMutableArray *keys = [NSMutableArray new];
    for (int i = 0; i < count; i++) {
        NSString *key = @(i).description;
        [keys addObject:key];
    }
    if (random) {
        for (NSUInteger i = keys.count; i > 1; i--) {
            [keys exchangeObjectAtIndex:(i - 1) withObjectAtIndex:arc4random_uniform((u_int32_t)i)];
        }
    }
    
    NSTimeInterval begin, end, time;
    
    printf("\n===========================\n");
    printf("Disk cache get 1000 key-value pairs %s(value is NSNumber)\n", (random ? "randomly " : ""));
    
    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            NSNumber *value = (id)[diskCache objectForKey:keys[i]];
            if (!value) printf("error!");
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("XMNDiskCacheReadSmallData-random:%d :     %8.2f\n", random,time * 1000);
}


- (void)testDiskCacheReadLargeFile:(BOOL)randomly {
    NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) firstObject];
    basePath = [basePath stringByAppendingPathComponent:@"FileCacheBenchmarkLarge"];
    
    XMNDiskCache *diskCache = [[XMNDiskCache alloc] initWithPath:basePath];
    
    int count = 1000;
    NSMutableArray *keys = [NSMutableArray new];
    for (int i = 0; i < count; i++) {
        NSString *key = @(i).description;
        [keys addObject:key];
    }
    
    if (randomly) {
        for (NSUInteger i = keys.count; i > 1; i--) {
            [keys exchangeObjectAtIndex:(i - 1) withObjectAtIndex:arc4random_uniform((u_int32_t)i)];
        }
    }
    
    NSTimeInterval begin, end, time;
    
    printf("\n===========================\n");
    printf("Disk cache get 1000 key-value pairs %s(value is NSData(100KB))\n", (randomly ? "randomly " : ""));
    

    begin = CACurrentMediaTime();
    @autoreleasepool {
        for (int i = 0; i < count; i++) {
            NSData *value = (id)[diskCache objectForKey:keys[i]];
            if (!value) printf("error!");
        }
    }
    end = CACurrentMediaTime();
    time = end - begin;
    printf("XMNDiskCache:  %8.2f\n", time * 1000);
    
    
}


@end
