//
//  XMNCache.h
//  XMNCacheExample
//
//  Created by shscce on 15/12/1.
//  Copyright © 2015年 xmfraker. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XMNMemoryCache.h"
#import "XMNDiskCache.h"

/**
 *  XMNCache 提供基于键值对的缓存方式
 *  提供内存缓存XMNMemoryCache
 *  基于文件,sqlite的XMNDiskCache
 */
@interface XMNCache : NSObject

#pragma mark - 属性

/** 缓存名称,用作缓存路径,只读 .*/
@property (copy  , readonly) NSString *name;

/** 硬盘缓存实例,具体信息查看XMNDiskCache */
@property (strong, readonly) XMNDiskCache *diskCache;

/** 内存缓存实例,具体信息查看XMNMemoryCache */
@property (strong, readonly) XMNMemoryCache *memoryCache;

#pragma mark - 方法

/**
 *  用提供的name生成一个XMNCache实例
 *
 *  @param name 缓存的名称,在app的cacheDictionary内建立name的文件夹,存放缓存 .当生成完毕之后,建议不在有其他内容访问,读写此文件夹
 *
 *  @return XMNCache实例 或者 nil
 */
- (instancetype)initWithName:(NSString *)name;

/**
 *  用提供的path生成一个XMNCache实例
 *
 *  @param path 缓存的路径,在app对应的path内建立对应文件夹
 *
 *  @return XMNCache实例 或者 nil
 */
- (instancetype)initWithPath:(NSString *)path;


/**
 *  根据提供的key判断缓存是否存在
 *
 *  @param key 缓存的key
 *
 *  @return 缓存是否存在YES OR NO
 */
- (BOOL)containsObjectForKey:(NSString *)key;

/**
 *  根据提供的key判断缓存是否存在
 *
 *  @param key   缓存的key
 *  @param block 回调block
 */
- (void)containsObjectForKey:(NSString *)key withBlock:(void(^)(NSString *key, BOOL contains))block;

/**
 *  根据提供的key获取缓存内容
 *
 *  @param key 缓存对应的key
 *
 *  @return nil 或者 具体缓存内容
 */
- (id<NSCoding>)objectForKey:(NSString *)key;

/**
 *  根据提供的key获取缓存内容
 *
 *  @param key   缓存的key
 *  @param block 回调block
 */
- (void)objectForKey:(NSString *)key withBlock:(void(^)(NSString *key ,id<NSCoding> object))block;

/**
 *  以提供的key的保存缓存内容
 *
 *  @param object 需要缓存的内容
 *  @param key    缓存对应的key值
 */
- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key;

/**
 *  以提供的key保存缓存内容
 *
 *  @param object 需要缓存的内容
 *  @param key    缓存对应的key值
 *  @param block  回调block
 */
- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key withBlock:(void(^)())block;

/**
 *  根据提供的key值移除缓存内容
 *
 *  @param key 缓存对应的key
 */
- (void)removeObjectForKey:(NSString *)key;

/**
 *  根据提供的key值移除缓存内容
 *
 *  @param key   缓存对应的key
 *  @param block 回调的block
 */
- (void)removeObjectForKey:(NSString *)key withBlock:(void(^)(NSString *key))block;

/**
 *  移除所有缓存内容
 */
- (void)removeAllObjects;

/**
 *  移除所有缓存内容
 *
 *  @param block 回调block
 */
- (void)removeAllObjectsWithBlock:(void(^)())block;

/**
 *  移除所有缓存内容
 *
 *  @param progressBlock 移除进度block
 *  @param finishBlock   完成block
 */
- (void)removeAllObjectsWithProgressBlock:(void(^)(NSUInteger removedCount, NSUInteger totalCount))progressBlock
                              finishBlock:(void(^)(BOOL success))finishBlock;


@end
