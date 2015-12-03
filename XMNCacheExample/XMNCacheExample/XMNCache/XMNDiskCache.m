//
//  XMNDiskCache.m
//  XMNCacheExample
//
//  Created by shscce on 15/12/1.
//  Copyright © 2015年 xmfraker. All rights reserved.
//

#import "XMNDiskCache.h"
#import <CommonCrypto/CommonCrypto.h>
#import <objc/runtime.h>
#import <time.h>

#define XMNLock() dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER)
#define XMNUnlock() dispatch_semaphore_signal(_lock)

static const int extended_data_key;


/**
 *  计算app剩余硬盘空间
 *
 *  @return 剩余硬盘空间大小
 */
static int64_t XMNDiskSpaceFree() {
    NSError *error = nil;
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error) return -1;
    int64_t space =  [[attrs objectForKey:NSFileSystemFreeSize] longLongValue];
    if (space < 0) space = -1;
    return space;
}


/**
 *  计算字符串MD5加密
 *
 *  @param string 需要加密的字符串
 *
 *  @return MD5加密后的字符串
 */
static NSString *XMNStringMD5(NSString *string) {
    if (!string) return nil;
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0],  result[1],  result[2],  result[3],
            result[4],  result[5],  result[6],  result[7],
            result[8],  result[9],  result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}


@implementation XMNDiskCache
{
    XMNStorage *_storage;
    dispatch_semaphore_t _lock;
    dispatch_queue_t _queue;
}

#pragma mark - Life Cycle

- (instancetype)initWithPath:(NSString *)path {
    return [self initWithPath:path inlineThreshold:1024 * 20]; // 20KB
}

- (instancetype)initWithPath:(NSString *)path
             inlineThreshold:(NSUInteger)threshold {
    if (self = [super init]) {
        XMNStorageType type;
        if (threshold == 0) {
            type = XMNStorageTypeFile;
        }else if (threshold == NSUIntegerMax) {
            type = XMNStorageTypeSQLite;
        }else {
            type = XMNStorageTypeMixed;
        }
        
        _storage = [[XMNStorage alloc] initWithPath:path type:type];
        NSAssert(_storage, @"storage init error");
        
        _path = [path copy];
        _lock = dispatch_semaphore_create(1);
        _queue = dispatch_queue_create("com.XMFraker.cache.disk", DISPATCH_QUEUE_CONCURRENT);
        
        _inlineThreshold = threshold;
        _countLimit = NSUIntegerMax;
        _costLimit = NSUIntegerMax;
        _ageLimit = DBL_MAX;
        _autoTrimInterval = 60;
    }

    return self;
}


#pragma mark - Public Methods

- (BOOL)containsObjectForKey:(NSString *)key {
    if (!key) return NO;
    XMNLock();
    BOOL contains = [_storage objectExistsForKey:key];
    XMNUnlock();
    return contains;
}

- (void)containsObjectForKey:(NSString *)key withBlock:(void(^)(NSString *key, BOOL contains))block {
    if (!block) return;
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        BOOL contains = [self containsObjectForKey:key];
        block(key, contains);
    });
}

- (id<NSCoding>)objectForKey:(NSString *)key {
    if (!key) return nil;
    XMNLock();
    XMNStorageObject *item = [_storage getObjectForKey:key];
    XMNUnlock();
    if (!item.value) return nil;
    
    id object = nil;
    if (_customUnarchiveBlock) {
        object = _customUnarchiveBlock(item.value);
    } else {
        @try {
            object = [NSKeyedUnarchiver unarchiveObjectWithData:item.value];
        }
        @catch (NSException *exception) {
            NSLog(@"object for key :%@ keyedUnarchiver error :%@",key,exception);
        }
    }
    if (object && item.extendedData) {
        [XMNDiskCache setExtendedData:item.extendedData toObject:object];
    }
    return object;
}

- (void)objectForKey:(NSString *)key withBlock:(void(^)(NSString *key, id<NSCoding> object))block {
    if (!block) return;
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        id<NSCoding> object = [self objectForKey:key];
        block(key, object);
    });
}

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key {
    if (!key) return;
    if (!object) {
        [self removeObjectForKey:key];
        return;
    }
    
    NSData *extendedData = [XMNDiskCache getExtendedDataFromObject:object];
    NSData *value = nil;
    if (_customArchiveBlock) {
        value = _customArchiveBlock(object);
    } else {
        @try {
            value = [NSKeyedArchiver archivedDataWithRootObject:object];
        }
        @catch (NSException *exception) {
            NSLog(@"object for key :%@ keyedArchiver error :%@",key,exception);
        }
    }
    if (!value) return;
    NSString *filename = nil;
    if (_storage.type != XMNStorageTypeSQLite) {
        if (value.length > _inlineThreshold) {
            filename = [self _filenameForKey:key];
        }
    }
    
    XMNLock();
    [_storage saveObjectWithKey:key value:value filename:filename extendedData:extendedData];
    XMNUnlock();
}

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key withBlock:(void(^)(void))block {
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        [self setObject:object forKey:key];
        block ? block() : nil;
    });
}

- (void)removeObjectForKey:(NSString *)key {
    if (!key) return;
    XMNLock();
    [_storage removeObjectForKey:key];
    XMNUnlock();
}

- (void)removeObjectForKey:(NSString *)key withBlock:(void(^)(NSString *key))block {
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        [self removeObjectForKey:key];
        block ? block(key) : nil;
    });
}

- (void)removeAllObjects {
    XMNLock();
    [_storage removeAllObjects];
    XMNUnlock();
}

- (void)removeAllObjectsWithBlock:(void(^)(void))block {
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        [self removeAllObjects];
        block ? block() : nil;
    });
}

- (void)removeAllObjectsWithProgressBlock:(void (^)(NSUInteger, NSUInteger))progressBlock
                              finishBlock:(void (^)(BOOL success))finishBlock {
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        if (!self) {
            finishBlock ? finishBlock (YES) : nil;
            return;
        }
        dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER);
        [_storage removeAllObjectsWithProgressBlock:progressBlock finishBlock:finishBlock];
        dispatch_semaphore_signal(self->_lock);
    });
}

- (NSInteger)totalCount {
    XMNLock();
    int count = [_storage getObjectsCount];
    XMNUnlock();
    return count;
}

- (void)totalCountWithBlock:(void(^)(NSInteger totalCount))block {
    if (!block) return;
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        NSInteger totalCount = [self totalCount];
        block(totalCount);
    });
}

- (NSInteger)totalCost {
    XMNLock();
    int count = [_storage getObjectsSize];
    XMNUnlock();
    return count;
}

- (void)totalCostWithBlock:(void(^)(NSInteger totalCost))block {
    if (!block) return;
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        NSInteger totalCost = [self totalCost];
        block(totalCost);
    });
}

- (void)trimToCount:(NSUInteger)count {
    XMNLock();
    [self _trimToCount:count];
    XMNUnlock();
}

- (void)trimToCount:(NSUInteger)count withBlock:(void(^)(void))block {
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        [self trimToCount:count];
        block ? block() : nil;
    });
}

- (void)trimToCost:(NSUInteger)cost {
    XMNLock();
    [self _trimToCost:cost];
    XMNUnlock();
}

- (void)trimToCost:(NSUInteger)cost withBlock:(void(^)(void))block {
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        [self trimToCost:cost];
        block ? block() : nil;
    });
}

- (void)trimToAge:(NSTimeInterval)age {
    XMNLock();
    [self _trimToAge:age];
    XMNUnlock();
}

- (void)trimToAge:(NSTimeInterval)age withBlock:(void(^)(void))block {
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        [self trimToAge:age];
        block ? block() : nil;
    });
}

#pragma mark - Private Methods


- (void)_trimRecursively {
    __weak typeof(self) _self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_autoTrimInterval * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        __strong typeof(_self) self = _self;
        if (!self) return;
        [self _trimInBackground];
        [self _trimRecursively];
    });
}

- (void)_trimInBackground {
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        if (!self) return;
        dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER);
        [self _trimToCost:self.countLimit];
        [self _trimToCount:self.countLimit];
        [self _trimToAge:self.ageLimit];
        dispatch_semaphore_signal(self->_lock);
    });
}

- (void)_trimToCost:(NSUInteger)costLimit {
    if (costLimit >= INT_MAX) return;
    [_storage removeObjectsToFitSize:(int)costLimit];
}

- (void)_trimToCount:(NSUInteger)countLimit {
    if (countLimit >= INT_MAX) return;
    [_storage removeObjectsToFitCount:(int)countLimit];
}

- (void)_trimToAge:(NSTimeInterval)ageLimit {
    if (ageLimit <= 0) {
        [_storage removeAllObjects];
        return;
    }
    long timestamp = time(NULL);
    if (timestamp <= ageLimit) return;
    long age = timestamp - ageLimit;
    if (age >= INT_MAX) return;
    [_storage removeObjectsEarlierThanTime:age];
}


- (NSString *)_filenameForKey:(NSString *)key {
    NSString *filename = nil;
    if (_customFilenameBlock) filename = _customFilenameBlock(key);
    if (!filename) filename = XMNStringMD5(key);
    return filename;
}

#pragma mark - Getters

- (NSString *)description {
    if (_name) return [NSString stringWithFormat:@"<%@: %p> (%@:%@)", self.class, self, _name, _path];
    else return [NSString stringWithFormat:@"<%@: %p> (%@)", self.class, self, _path];
}

#pragma mark - Class Methods

+ (NSData *)getExtendedDataFromObject:(id)object {
    if (!object) return nil;
    return (NSData *)objc_getAssociatedObject(object, &extended_data_key);
}

+ (void)setExtendedData:(NSData *)extendedData toObject:(id)object {
    if (!object) return;
    objc_setAssociatedObject(object, &extended_data_key, extendedData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
