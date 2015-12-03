//
//  XMNStorage.h
//  XMNCacheExample
//
//  Created by shscce on 15/12/2.
//  Copyright © 2015年 xmfraker. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, XMNStorageType) {
    /** 使用文件方式缓存 */
    XMNStorageTypeFile = 0 ,
    /** 使用sqlite数据库方式缓存 */
    XMNStorageTypeSQLite,
    /** 混合方式缓存,大于阀值的以文件方式缓存,否则以数据库方式缓存 */
    XMNStorageTypeMixed,
};

/**
 *  XMNStorage使用的,以键值对保存一个XMNStorageObject
 */
@interface XMNStorageObject : NSObject

@property (nonatomic, strong) NSString *key;        ///< key
@property (nonatomic, strong) NSData *value;        ///< value
@property (nonatomic, strong) NSString *filename;   ///< filename (nil if inline)
@property (nonatomic, assign) int size;             ///< value's size in bytes
@property (nonatomic, assign) int modTime;          ///< modification unix timestamp
@property (nonatomic, assign) int accessTime;       ///< last access unix timestamp
@property (nonatomic, strong) NSData *extendedData; ///< extended data (nil if no extended data)

@end

@interface XMNStorage : NSObject

#pragma mark - 属性
///=============================================================================
/// @name 属性
///=============================================================================

/** 缓存文件存放主路径 */
@property (nonatomic, readonly) NSString *path;

/** 缓存类型 */
@property (nonatomic, readonly) XMNStorageType type;
/** 错误logs是否输出 默认YES */
@property (nonatomic, assign) BOOL errorLogsEnabled;

#pragma mark - Initializer
///=============================================================================
/// @name 初始化
///=============================================================================

/**
 *  推荐初始化方式
 *
 *  @param path 缓存文件存储主路径,默认一个XMNStorage对应一个path
 *  @param type 缓存类型
 *
 *  @return nil 或者 XMNStorage 实例
 */
- (instancetype)initWithPath:(NSString *)path type:(XMNStorageType)type NS_DESIGNATED_INITIALIZER;


#pragma mark - Public Methods
///=============================================================================
/// @name 保存缓存object
///=============================================================================

/**
 *  保存一个obejct 或者更新object如果key值已经存在
 *  
 *  @discussion 将会保存objet.key,object.value,object.filename,object.extendedData 到文件或者数据库,其他属性将会忽略
 *  如果XMNStorage type 是XMNStorageTypeFile 则object.filename不可为空
 *  如果XMNStorage type 是XMNStorageTypeSQLite 则object.filename会被忽略
 *  如果XMNStorage type 是XMNStorageTypeMixed 如果object.filename不为空,则object.value会被以文件方式存储,否则会被保存到数据库内
 *  @param object 需要保存或者更新的object
 *  @return 是否保存或者更新成功
 */
- (BOOL)saveObject:(XMNStorageObject *)object;

/**
 *  保存或者更新value到对应的key值内
 *
 *  @param key   value对应的key
 *  @param value 需要保存或者更新的key
 *
 *  @return 是否保存或者更新成功
 */
- (BOOL)saveObjectWithKey:(NSString *)key value:(NSData *)value;

/**
 *  保存一个obejct 或者更新object如果key值已经存在
 *
 *  @discussion 将会保存objet.key,object.value,object.filename,object.extendedData 到文件或者数据库,其他属性将会忽略
 *  如果XMNStorage type 是XMNStorageTypeFile 则object.filename不可为空
 *  如果XMNStorage type 是XMNStorageTypeSQLite 则object.filename会被忽略
 *  如果XMNStorage type 是XMNStorageTypeMixed 如果object.filename不为空,则object.value会被以文件方式存储,否则会被保存到数据库内
 *  @param key              不可为空
 *  @param value            不可为空
 *  @param filename         如果是SQLite则此参数被忽略
 *  @param extendedData
 *  @return 是否保存或者更新成功
 */
- (BOOL)saveObjectWithKey:(NSString *)key
                  value:(NSData *)value
               filename:(NSString *)filename
           extendedData:(NSData *)extendedData;


///=============================================================================
/// @name 删除缓存内容
///=============================================================================

/**
 *  根据提供的key 删除一个缓存object
 *
 *  @param key 缓存的key
 *
 *  @return 是否删除成功
 */
- (BOOL)removeObjectForKey:(NSString *)key;

/**
 *  根据提供的keys 数组 删除缓存
 *
 *  @param keys 缓存key数组
 *
 *  @return 是否删除成功
 */
- (BOOL)removeObjectForKeys:(NSArray *)keys;

/**
 *  删除所有value内存大小大于给定的size
 *
 *  @param size 限定size
 *
 *  @return 是否删除成功
 */
- (BOOL)removeObjectsLargerThanSize:(int)size;

/**
 *  删除所有在给定时间之前的缓存
 *
 *  @param time 限定的时间
 *
 *  @return 是否删除成功
 */
- (BOOL)removeObjectsEarlierThanTime:(NSTimeInterval)time;

/**
 *  删除多余的缓存
 *
 *  @param maxCount 限定的缓存数量
 *
 *  @return 是否删除成功
 */
- (BOOL)removeObjectsToFitCount:(int)maxCount;

/**
 *  删除多余缓存
 *
 *  @param maxSize 缓存容量限制
 *
 *  @return 是否删除成功
 */
- (BOOL)removeObjectsToFitSize:(int)maxSize;

/**
 *  删除所有缓存
 *
 *  @return 是否删除成功
 */
- (BOOL)removeAllObjects;


/**
 *  删除所有缓存
 *
 *  @param progressBlock 回调的进度progressBlock
 *  @param finishBlock   回调的finishBlock
 */
- (void)removeAllObjectsWithProgressBlock:(void(^)(NSUInteger removedCount, NSUInteger totalCount))progressBlock
                              finishBlock:(void(^)(BOOL success))finishBlock;


///=============================================================================
/// @name 获取缓存内容
///=============================================================================

/**
 *  根据提供是key获取一个XMNStorageObject
 *
 *  @param key 对应的缓存key
 *
 *  @return nil 或 XMNStorageObject实例
 */
- (XMNStorageObject *)getObjectForKey:(NSString *)key;


/**
 *  根据提供的key获取缓存信息,其中XMNStorageObject.value 会被忽略
 *
 *  @param key 缓存对应的key
 *
 *  @return nil 或者XMNStorageObject实例
 */
- (XMNStorageObject *)getObjectInfoForKey:(NSString *)key;

/**
 *  根据提供的key 获取缓存具体value
 *
 *  @param key 缓存的key
 *
 *  @return 缓存的具体value 或者 nil
 */
- (NSData *)getObjectValueForKey:(NSString *)key;

/**
 *  根据提供的key数组,获取对应的缓存数组
 *
 *  @param keys 缓存key数组
 *
 *  @return XMNStorageObject数组 或者 nil
 */
- (NSArray *)getObjectsForKeys:(NSArray *)keys;

/**
 *  根据提供的key数组,获取对应的缓存数组,其中XMNStorageObject的value会被忽略
 *
 *  @param keys 缓存key数组
 *
 *  @return XMNStorageObject数组 或者 nil
 */
- (NSArray *)getObjectInfosForKeys:(NSArray *)keys;

/**
 *  根据提供的key数组  获取缓存的key-value字典
 *
 *  @param keys 缓存的key数组
 *
 *  @return nil  或者 对应的key-value字典
 */
- (NSDictionary *)getObjectValuesForKeys:(NSArray *)keys;

///=============================================================================
/// @name 获取缓存状态
///=============================================================================

/**
 *  根据提供的key 判断缓存是否存在
 *
 *  @param key 缓存的key
 *
 *  @return 是否存在
 */
- (BOOL)objectExistsForKey:(NSString *)key;


/**
 *  获取所有缓存数量
 *
 *  @return 缓存的数量
 */
- (int)getObjectsCount;

/**
 *  获取所有缓存的大小
 *
 *  @return 缓存大小
 */
- (int)getObjectsSize;



@end
