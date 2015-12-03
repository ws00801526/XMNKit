//
//  XMNMemoryCache.h
//  XMNCacheExample
//
//  Created by shscce on 15/12/1.
//  Copyright © 2015年 xmfraker. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  XMNMemoryCache 提供一个内存缓存,可以根据key值缓存数据,设置最大内存消耗,缓存数量,缓存时间等限制,并且每N秒检查下缓存,清理不符合规则的缓存
 *  利用LinkedHashMap实现LRU(least recently used)算法
 */
@interface XMNMemoryCache : NSObject


#pragma mark - Properties

/** 内存缓存名称 */
@property (copy) NSString *name;

/** 总缓存内存消耗 */
@property (assign, readonly) NSUInteger totalCost;

/** 总缓存数量 */
@property (assign, readonly) NSUInteger totalCount;

/** 内存最大存储时间限制 默认DBL_MAX 无限制 */
@property (assign) NSTimeInterval ageLimit;

/** 内存最大数量限制 默认NSUintegerMax 无限制 */
@property (assign) NSUInteger countLimit;

/** 内存最大限制 默认NSUintegerMax 无限制 */
@property (assign) NSUInteger costLimit;

/** 自动检测缓存间隔时间 默认 5.0s */
@property (assign) NSTimeInterval autoTrimInterval;

/** 收到内存警告时,是否自动清除缓存 默认YES */
@property (assign) BOOL shouldRemoveAllObjectsWhenMemoryWaring;
/** 进入后台后,是否清除所有缓存 默认YES */
@property (assign) BOOL shouldRemoveAllObjectsWhenEnteringBackground;

/** 当接收到内存警告时执行的block 默认nil */
@property (copy) void(^didReceiveMemoryWarningBlock)(XMNMemoryCache *cache);

/** 进入后台时执行的block 默认nil */
@property (copy) void(^didEnterBackgroundBlock)(XMNMemoryCache *cache);

/** 是否使用线程队列释放缓存,NO的话 则在移除的时候同步释放 默认YES */
@property (assign) BOOL releaseAsync;



#pragma mark - Public Methods

/**
 *  根据key判断缓存是否存在
 *
 *  @param key 缓存的key
 *
 *  @return YES OR NO
 */
- (BOOL)containsObjectForKey:(NSString *)key;

/**
 *  获取缓存的object
 *
 *  @param key 缓存的key
 *
 *  @return nil 或者key值对应的缓存object
 */
- (id)objectForKey:(NSString *)key;

/**
 *  缓存一个object
 *
 *  @param object 需要缓存的object,object为nil时调用removeObjectForKey:
 *  @param key    缓存的key
 */
- (void)setObject:(id)object forKey:(id)key;

/**
 *  缓存一个object
 *
 *  @param object 需要缓存的object,object为nil时调用removeObjectForKey:
 *  @param key    缓存的key
 *  @param cost   object占用内存大小
 */
- (void)setObject:(id)object forKey:(id)key withCost:(NSUInteger)cost;

/**
 *  根据提供的key移除缓存
 *
 *  @param key 缓存的key
 */
- (void)removeObjectForKey:(id)key;

/**
 *  移除所有的缓存
 */
- (void)removeAllObjects;

///=============================================================================
/// @name LRU trim
///=============================================================================

/**
 *  根据提供的最大数量,使用LRU算法,移除不必要的缓存内容
 *
 *  @param count 最大限制数量,0则删除全部缓存
 */
- (void)trimToCount:(NSUInteger)countLimit;

/**
 *  根据提供的最大缓存消耗,使用LRU算法,移除不必要的缓存
 *
 *  @param costLimit 最大缓存消耗,0 则删除全部缓存
 */
- (void)trimToCost:(NSUInteger)costLimit;

/**
 *  根据提供的最大缓存时间限制,使用LRU算法,移除不必要的缓存
 *
 *  @param ageLimit 提供的缓存时间限制,0移除全部
 */
- (void)trimToAge:(NSTimeInterval)ageLimit;


@end
