//
//  XMNCache.m
//  XMNCacheExample
//
//  Created by shscce on 15/12/1.
//  Copyright © 2015年 xmfraker. All rights reserved.
//

#import "XMNCache.h"

@implementation XMNCache

#pragma mark - Initializer

- (instancetype)initWithName:(NSString *)name {
    NSAssert(name, @"XMNCache must have a name");
    
    NSString *cacheFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [cacheFolder stringByAppendingPathComponent:name];

    return [self initWithPath:path];
}


- (instancetype)initWithPath:(NSString *)path {
    NSAssert(path, @"XMNCache must have a cachePath");
    
    if ([super init]) {
        _diskCache = [[XMNDiskCache alloc] initWithPath:path];
        _memoryCache = [[XMNMemoryCache alloc] init];
        
        _name = [path lastPathComponent];
    }
    
    return self;
}

#pragma mark - Public Methods

- (BOOL)containsObjectForKey:(NSString *)key {
    return [_memoryCache containsObjectForKey:key] || [_diskCache containsObjectForKey:key];
}

- (void)containsObjectForKey:(NSString *)key withBlock:(void (^)(NSString *key, BOOL contains))block {
    if (!block) return;
    
    if ([_memoryCache containsObjectForKey:key]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            block(key, YES);
        });
    } else  {
        [_diskCache containsObjectForKey:key withBlock:block];
    }
}

- (id<NSCoding>)objectForKey:(NSString *)key {
    id<NSCoding> object = [_memoryCache objectForKey:key];
    if (!object) {
        object = [_diskCache objectForKey:key];
        if (object) {
            [_memoryCache setObject:object forKey:key];
        }
    }
    return object;
}

- (void)objectForKey:(NSString *)key withBlock:(void (^)(NSString *key, id<NSCoding> object))block {
    if (!block) return;
    id<NSCoding> object = [_memoryCache objectForKey:key];
    if (object) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            block(key, object);
        });
    } else {
        [_diskCache objectForKey:key withBlock:block];
    }
}

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key {
    [_memoryCache setObject:object forKey:key];
    [_diskCache setObject:object forKey:key];
}

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key withBlock:(void (^)())block {
    [_memoryCache setObject:object forKey:key];
    [_diskCache setObject:object forKey:key withBlock:block];
}

- (void)removeObjectForKey:(NSString *)key {
    [_memoryCache removeObjectForKey:key];
    [_diskCache removeObjectForKey:key];
}

- (void)removeObjectForKey:(NSString *)key withBlock:(void (^)(NSString *key))block {
    [_memoryCache removeObjectForKey:key];
    [_diskCache removeObjectForKey:key withBlock:block];
}

- (void)removeAllObjects {
    [_memoryCache removeAllObjects];
    [_diskCache removeAllObjects];
}

- (void)removeAllObjectsWithBlock:(void (^)())block {
    [_memoryCache removeAllObjects];
    [_diskCache removeAllObjectsWithBlock:block];
}

- (void)removeAllObjectsWithProgressBlock:(void (^)(NSUInteger removedCount, NSUInteger totalCount))progressBlock
                              finishBlock:(void (^)(BOOL success))finishBlock {
    [_memoryCache removeAllObjects];
    [_diskCache removeAllObjectsWithProgressBlock:progressBlock finishBlock:finishBlock];
}


#pragma mark - Getters
- (NSString *)description {
    if (_name) return [NSString stringWithFormat:@"<%@: %p> (%@)", self.class, self, _name];
    else return [NSString stringWithFormat:@"<%@: %p>", self.class, self];
}


@end
