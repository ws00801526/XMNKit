//
//  XMNKVOTests.m
//  XMNCategoryExample
//
//  Created by shscce on 15/12/4.
//  Copyright © 2015年 xmfraker. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NSObject+XMNKVO.h"

@interface Person : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSUInteger age;

@end

@implementation Person

@end

@interface XMNKVOTests : XCTestCase

@property (nonatomic, strong) Person *person;

@end

@implementation XMNKVOTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.person = [[Person alloc] init];
    self.person.name = @"XMFraker";
    self.person.age = 23;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testKVOProperty {
    //开始监听person的name属性
    [self.person xmn_addObserverForKeyPath:@"name" withBlock:^(__weak id object, id oldValue, id newValue) {
        NSLog(@"person.name change from:%@ to:%@",oldValue,newValue);
    }];
    
    //开始改变person.name属性
    self.person.name = @"XMFraker-Changed";
    
}

- (void)testKVOPropertyProperty {
    //开始监听person的name属性
    [self xmn_addObserverForKeyPath:@"person.name" withBlock:^(__weak id object, id oldValue, id newValue) {
        NSLog(@"person.name change from:%@ to:%@",oldValue,newValue);
    }];
    
    //开始改变person.name属性
    self.person.name = @"XMFraker-Changed";
}

- (void)testKVORemoveObserver {
    [self testKVOProperty];
    [self.person xmn_removeObserverForKeyPath:@"name"];
    
    //此时改变,并不会有block回调了,因为observer已经移除
    self.person.name = @"XMFraker-Changed-Again";
}

@end
