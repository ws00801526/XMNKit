//
//  XMNDiskCache.h
//  XMNCacheExample
//
//  Created by shscce on 15/12/1.
//  Copyright © 2015年 xmfraker. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XMNStorage.h"

@interface XMNDiskCache : NSObject


#pragma mark - 属性

/** 缓存名称 默认缓存路径最后个文件夹名称 只读 */
@property (copy  , readonly) NSString *name;

/** 缓存路径 用作缓存路径 只读 */
@property (copy  , readonly) NSString *path;

/** 文件大小临界值,大于此值,缓存以文件方式缓存,否则以数据库方式缓存 默认 20 * 1024 */
@property (readonly) NSUInteger inlineThreshold;

/** 自定义的归档block,将object转化为NSData,适用于将一些未实现NSCoding协议的object转化为NSData 默认使用NSKeyedArchiver归档*/
@property (copy) NSData *(^customArchiveBlock)(id object);

/** 自定义解档工具block,将NSData转化为自定义的Object,默认使用NSKeyedUnarchiver*/
@property (copy) id (^customUnarchiveBlock)(NSData *data);

/** 自定义文件名命名block,默认使用key的MD5加密作为文件名 */
@property (copy) NSString *(^customFilenameBlock)(NSString *key);

/** 内存最大存储时间限制 默认DBL_MAX 无限制 */
@property (assign) NSTimeInterval ageLimit;

/** 内存最大数量限制 默认NSUintegerMax 无限制 */
@property (assign) NSUInteger countLimit;

/** 内存最大限制 默认NSUintegerMax 无限制 */
@property (assign) NSUInteger costLimit;

/** 自动检测缓存间隔时间 默认 60.0s */
@property (assign) NSTimeInterval autoTrimInterval;

#pragma mark - Initializer

- (instancetype)initWithPath:(NSString *)path;

- (instancetype)initWithPath:(NSString *)path
             inlineThreshold:(NSUInteger)inlineThreshold;

#pragma mark - Public Methods

/**
 *  同步根据提供的key值判断缓存是否存在,返回一个BOOL值
 *
 *  @param key 缓存对应的key,如果key为nil 直接返回NO
 *
 */
- (BOOL)containsObjectForKey:(NSString *)key;

/**
 *  异步根据提供的key值判断缓存是否存在,返回一个BOOL值
 *
 *  @param key   缓存对应的key
 *  @param block 回调block,当在后台查询完毕后回调
 */
- (void)containsObjectForKey:(NSString *)key withBlock:(void(^)(NSString *key, BOOL contains))block;

/**
 *  同步根据提供的key值查询缓存
 *
 *  @param key 缓存对应的key,key为nil直接返回nil
 *
 *  @return nil 或者key对应的缓存object
 */
- (id<NSCoding>)objectForKey:(NSString *)key;

/**
 *  异步根据提供的key值查询缓存
 *
 *  @param key 缓存对应的key,key为nil直接返回nil
 *  @param block 回调block,查询完毕后在线程队列中调用block
 */
- (void)objectForKey:(NSString *)key withBlock:(void(^)(NSString *key, id<NSCoding> object))block;

/**
 *  同步缓存一个object到key值内,object传入nil则调用removeObjectForKey
 *
 *  @param object 需要缓存的object
 *  @param key    缓存的object对应的key
 */
- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key;

/**
 *  异步缓存一个object到对应的key,传入object为nil则调用removeObjectForKey
 *
 *  @param object 需要缓存的object
 *  @param key    缓存对应的key
 *  @param block  回调block,缓存完毕后回调
 */
- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key withBlock:(void(^)(void))block;

/**
 *  同步根据key值移除缓存
 *
 *  @param key 缓存对应的key值
 */
- (void)removeObjectForKey:(NSString *)key;

/**
 *  异步根据key值移除缓存
 *
 *  @param key   缓存对应的key
 *  @param block 删除缓存后回调block
 */
- (void)removeObjectForKey:(NSString *)key withBlock:(void(^)(NSString *key))block;

/**
 *  同步清理所有缓存
 */
- (void)removeAllObjects;

/**
 *  异步清理所有缓存
 *
 *  @param block 清理完所有缓存后回调
 */
- (void)removeAllObjectsWithBlock:(void(^)(void))block;

/**
 *  异步清理所有缓存
 *
 *  @param progress 清理过程的进度block
 *  @param end      清理完成后回调block
 */
- (void)removeAllObjectsWithProgressBlock:(void(^)(NSUInteger removedCount, NSUInteger totalCount))progressBlock
                              finishBlock:(void(^)(BOOL success))finishBlock;

/**
 *  同步获取所有缓存数量
 *
 *  @return 所有缓存的数量
 */
- (NSInteger)totalCount;

/**
 *  异步获取所有缓存数量
 *
 *  @param block 获取完数量的回调
 */
- (void)totalCountWithBlock:(void(^)(NSInteger totalCount))block;

/**
 *  同步获取所有缓存占用内存大小
 *
 *  @return 缓存占用的内存大小
 */
- (NSInteger)totalCost;

/**
 *  异步获取所有缓存占用的内存大小
 *
 *  @param block 回调block
 */
- (void)totalCostWithBlock:(void(^)(NSInteger totalCost))block;


#pragma mark - Trim
///=============================================================================
/// @name Trim 检查方法
///=============================================================================

/**
 *  同步 根据提供的最大数量限制,移除不必要的缓存内容,0则移除全部
 *
 *  @param count 删除缓存后剩余的最大缓存数量
 */
- (void)trimToCount:(NSUInteger)count;

/**
 *  异步 根据提供的最大数量限制,移除不必要的缓存内容,0则移除全部
 *
 *  @param count 删除缓存后剩余的最大缓存数量
 *  @param block 删除缓存后的回调
 */
- (void)trimToCount:(NSUInteger)count withBlock:(void(^)(void))block;

/**
 Removes objects from the cache use LRU, until the `totalCost` is below the specified value.
 This method may blocks the calling thread until operation finished.
 
 @param cost The total cost allowed to remain after the cache has been trimmed.
 */

/**
 *  同步 根据提供的最大的内存消耗限制,移除不必要的缓存内容,0则移除全部
 *
 *  @param cost 删除缓存后,剩余的最大内存消耗限制
 */
- (void)trimToCost:(NSUInteger)cost;


/**
 *  异步 根据提供的最大的内存消耗限制,移除不必要的缓存内容,0则移除全部
 *
 *  @param cost     删除缓存后,剩余的最大内存消耗限制
 *  @param block    完缓存后回调block
 */
- (void)trimToCost:(NSUInteger)cost withBlock:(void(^)(void))block;

/**
 *  同步 根据提供的时间限制,删除不符合的缓存
 *
 *  @param age 缓存到期时间
 */
- (void)trimToAge:(NSTimeInterval)age;

/**
 *  异步 根据提供的时间限制,删除不符合的缓存
 *
 *  @param age      缓存到期时间
 *  @param block    完缓存后回调block
 */
- (void)trimToAge:(NSTimeInterval)age withBlock:(void(^)(void))block;


#pragma mark - Extended Data
///=============================================================================
/// @name Extended Data
///=============================================================================

/**
 *  从对应的Object获取extendedData
 *
 *  @param object 对应的Object
 *
 *  @return nil 或者 对应的extendedData
 */
+ (NSData *)getExtendedDataFromObject:(id)object;

/**
 *  设置一个拓展data到对应Object,使用runtime实现,设置的extendedData同样会被保存至数据库
 *
 *  @param extendedData 拓展的extendedData
 *  @param object       对应的Object
 */
+ (void)setExtendedData:(NSData *)extendedData toObject:(id)object;


@end
