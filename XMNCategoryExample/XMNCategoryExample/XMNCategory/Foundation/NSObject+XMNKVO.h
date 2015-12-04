//
//  NSObject+XMNKVO.h
//  XMNCategoryExample
//
//  Created by shscce on 15/12/4.
//  Copyright © 2015年 xmfraker. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  利用runtime实现带有block回调方式的KVO
 *  示例,请参考XMNKVOTests
 */
@interface NSObject (XMNKVO)

/**
 *  注册一个KVO监听对应keyPath
 *  当监听keyPath值变化时回调,初始化时不会回调
 *  @param keyPath 需要监听的keyPath
 *  @param block   监听回调的block
 */
- (void)xmn_addObserverForKeyPath:(NSString *)keyPath withBlock:(void(^)(__weak id object, id oldValue, id newValue))block;

/**
 *  移除一个KVO
 *
 *  @param keyPath 对应的keyPath
 */
- (void)xmn_removeObserverForKeyPath:(NSString *)keyPath;

/**
 *  移除所有KVO
 */
- (void)xmn_removeAllObservers;

@end
