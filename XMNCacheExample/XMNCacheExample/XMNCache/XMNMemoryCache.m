//
//  XMNMemoryCache.m
//  XMNCacheExample
//
//  Created by shscce on 15/12/1.
//  Copyright © 2015年 xmfraker. All rights reserved.
//

#import "XMNMemoryCache.h"

#import <UIKit/UIKit.h>
#import <libkern/OSAtomic.h>
#import <objc/runtime.h>

static inline dispatch_queue_t XMNMemoryCacheGetReleaseQueue() {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
}


#pragma mark - XMNLinkedHashMapNode

/**
 *  XMNLinkedHashMap使用的链表节点
 */
@interface XMNLinkedHashMapNode : NSObject {
    @package
    /** 指向前一个hashMap节点,有NSDictionary持有其内存*/
    __unsafe_unretained XMNLinkedHashMapNode *_prev;
    /** 指向后一个链表节点,由NSDictionary持有其内存 */
    __unsafe_unretained XMNLinkedHashMapNode *_next;
    /** 缓存的key值 */
    id _key;
    /** 缓存的具体内容 */
    id _value;
    /** 缓存内存消耗 */
    NSUInteger _cost;
    /** 缓存时间 */
    NSTimeInterval _time;
}
@end

@implementation XMNLinkedHashMapNode

@end

#pragma mark - XMNLinkedHashMap

/**
 *  XMNMemoryCache 使用的一个双向LinkedHashMap实现
 *  非线程安全
 */
@interface XMNLinkedHashMap : NSObject {
    @package
    /** 缓存这所有的节点 */
    CFMutableDictionaryRef _dict;
    /** 缓存内存总消耗 */
    NSUInteger _totalCost;
    /** 缓存总数量 */
    NSUInteger _totalCount;
    /** 保存着linkedHashMap的头部节点 */
    XMNLinkedHashMapNode *_head;
    /** 保存着linkedHashMap的尾部节点 */
    XMNLinkedHashMapNode *_tail;
    /** 是否异步释放缓存 默认YES */
    BOOL _releaseAsync;
}

/**
 *  插入新的节点到头部
 *  linkedHashMap当插入新的node时,会被放置在头部
 *  node,node.key不能为nil
 *  @param node 需要被插入的节点
 */
- (void)insertNodeAtHead:(XMNLinkedHashMapNode *)node;

/**
 *  将_dict中已存在的节点移动到头部
 *
 *  @param node 需要移动的节点,node必须在_dict中存在
 */
- (void)bringNodeToHead:(XMNLinkedHashMapNode *)node;

/**
 *  移除一个节点,更新总缓存内存消耗,缓存数量
 *
 *  @param node 需要移除的节点,node必须在_dict中存在
 */
- (void)removeNode:(XMNLinkedHashMapNode *)node;


/**
 *  删除尾部节点
 *
 *  @return 尾部节点
 */
- (XMNLinkedHashMapNode *)removeTailNode;

/**
 *  删除所有节点
 */
- (void)removeAll;

@end

@implementation XMNLinkedHashMap

- (instancetype)init {
    self = [super init];
    _dict = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    _releaseAsync = YES;
    return self;
}

- (void)dealloc {

}

/**
 *  steps
 *  1.使用_dict缓存住node
 *  2.更新totalCos,totalCount
 *  3.如果头部节点存在,更新头部节点,不存在更新头节点,尾节点
 */
- (void)insertNodeAtHead:(XMNLinkedHashMapNode *)node {
    CFDictionarySetValue(_dict, (__bridge const void *)(node->_key), (__bridge const void *)(node));
    _totalCost += node->_cost;
    _totalCount++;
    if (_head) {
        node->_next = _head;
        _head->_prev = node;
        _head = node;
    } else {
        _head = _tail = node;
    }
}

/**
 *  steps
 *  1.如果当前节点就是头部节点,返回 不操作
 *  2.如果当前节点是尾部节点,更新尾部节点,否则更新node前后节点的 next,prev指向
 *  3.更新当前node的next,prev指向
 *  4.更新_head的prev
 *  5.更新_head
 */
- (void)bringNodeToHead:(XMNLinkedHashMapNode *)node {
    if (_head == node) return;
    if (_tail == node) {
        _tail = node->_prev;
        _tail->_next = nil;
    } else {
        node->_next->_prev = node->_prev;
        node->_prev->_next = node->_next;
    }
    node->_next = _head;
    node->_prev = nil;
    _head->_prev = node;
    _head = node;
}

/**
 *  steps
 *  1.从_dict中移除node
 *  2.更新totalCost,totalCount
 *  3.更新node->_next
 *  4.更新nodel->_prev
 *  5.更新_head
 *  6.更新_prev
 */
- (void)removeNode:(XMNLinkedHashMapNode *)node {
    CFDictionaryRemoveValue(_dict, (__bridge const void *)(node->_key));
    _totalCost -= node->_cost;
    _totalCount--;
    if (node->_next) node->_next->_prev = node->_prev;
    if (node->_prev) node->_prev->_next = node->_next;
    if (_head == node) _head = node->_next;
    if (_tail == node) _tail = node->_prev;
}

- (XMNLinkedHashMapNode *)removeTailNode {
    if (!_tail) return nil;
    XMNLinkedHashMapNode *tail = _tail;
    CFDictionaryRemoveValue(_dict, (__bridge const void *)(_tail->_key));
    _totalCost -= _tail->_cost;
    _totalCount--;
    if (_head == _tail) {
        _head = _tail = nil;
    } else {
        _tail = _tail->_prev;
        _tail->_next = nil;
    }
    return tail;
}

- (void)removeAll {
    _totalCost = 0;
    _totalCount = 0;
    _head = nil;
    _tail = nil;
    if (CFDictionaryGetCount(_dict) > 0) {
        _dict = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        CFMutableDictionaryRef holder = _dict;
        if (_releaseAsync) {
            dispatch_queue_t queue = XMNMemoryCacheGetReleaseQueue();
            dispatch_async(queue, ^{
                CFRelease(holder);
            });
        }else {
            CFRelease(holder);
        }
        
    }
}

@end


#pragma mark - XMNMemoryCache

@implementation XMNMemoryCache {
    /** 线程锁,保证_lru线程安全 */
    OSSpinLock _lock;
    /** 缓存linkedHashMap */
    XMNLinkedHashMap *_lru;
    /** 缓存队列,将保存缓存操作放到此线程队列中操作,serial串行队列 */
    dispatch_queue_t _queue;
}


#pragma mark - Life Cycle

- (instancetype)init {
    if ([super init]) {
        _lock = OS_SPINLOCK_INIT;
        _lru = [XMNLinkedHashMap new];
        _queue = dispatch_queue_create("com.ibireme.cache.memory", DISPATCH_QUEUE_SERIAL);
        
        _countLimit = NSUIntegerMax;
        _costLimit = NSUIntegerMax;
        _ageLimit = DBL_MAX;
        _autoTrimInterval = 5.0;
        _shouldRemoveAllObjectsWhenEnteringBackground = YES;
        _shouldRemoveAllObjectsWhenMemoryWaring = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidReceiveMemoryWarningNotification) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        return self;

    }
    return self;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [_lru removeAll];
}


#pragma mark - Public Methods

- (BOOL)containsObjectForKey:(id)key {
    if (!key) return NO;
    OSSpinLockLock(&_lock);
    BOOL contains = CFDictionaryContainsKey(_lru->_dict, (__bridge const void *)(key));
    OSSpinLockUnlock(&_lock);
    return contains;
}

- (id)objectForKey:(id)key {
    if (!key) return nil;
    OSSpinLockLock(&_lock);
    XMNLinkedHashMapNode *node = CFDictionaryGetValue(_lru->_dict, (__bridge const void *)(key));
    if (node) {
        node->_time = CACurrentMediaTime();
        [_lru bringNodeToHead:node];
    }
    OSSpinLockUnlock(&_lock);
    return node ? node->_value : nil;
}

- (void)setObject:(id)object forKey:(id)key {
    [self setObject:object forKey:key withCost:0];
}

- (void)setObject:(id)object forKey:(id)key withCost:(NSUInteger)cost {
    if (!key) return;
    if (!object) {
        [self removeObjectForKey:key];
        return;
    }
    OSSpinLockLock(&_lock);
    XMNLinkedHashMapNode *node = CFDictionaryGetValue(_lru->_dict, (__bridge const void *)(key));
    NSTimeInterval now = CACurrentMediaTime();
    if (node) {
        _lru->_totalCost -= node->_cost;
        _lru->_totalCost += cost;
        node->_cost = cost;
        node->_time = now;
        node->_value = object;
        [_lru bringNodeToHead:node];
    } else {
        node = [XMNLinkedHashMapNode new];
        node->_cost = cost;
        node->_time = now;
        node->_key = key;
        node->_value = object;
        [_lru insertNodeAtHead:node];
    }
    if (_lru->_totalCost > _costLimit) {
        dispatch_async(_queue, ^{
            [self trimToCost:_costLimit];
        });
    }
    if (_lru->_totalCount > _countLimit) {
        XMNLinkedHashMapNode *node = [_lru removeTailNode];
        if (_lru->_releaseAsync) {
            dispatch_queue_t queue = XMNMemoryCacheGetReleaseQueue();
            dispatch_async(queue, ^{
                [node class]; //hold and release in queue
            });
        } else if (_lru->_releaseAsync) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [node class]; //hold and release in queue
            });
        }
    }
    OSSpinLockUnlock(&_lock);
}

- (void)removeObjectForKey:(id)key {
    if (!key) return;
    OSSpinLockLock(&_lock);
    XMNLinkedHashMapNode *node = CFDictionaryGetValue(_lru->_dict, (__bridge const void *)(key));
    if (node) {
        [_lru removeNode:node];
        if (_lru->_releaseAsync) {
            dispatch_queue_t queue = XMNMemoryCacheGetReleaseQueue();
            dispatch_async(queue, ^{
                [node class]; //hold and release in queue
            });
        } else if (_lru->_releaseAsync) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [node class]; //hold and release in queue
            });
        }
    }
    OSSpinLockUnlock(&_lock);
}

- (void)removeAllObjects {
    OSSpinLockLock(&_lock);
    [_lru removeAll];
    OSSpinLockUnlock(&_lock);
}

- (void)trimToCount:(NSUInteger)count {
    if (count == 0) {
        [self removeAllObjects];
        return;
    }
    [self _trimToCount:count];
}

- (void)trimToCost:(NSUInteger)cost {
    [self _trimToCost:cost];
}

- (void)trimToAge:(NSTimeInterval)age {
    [self _trimToAge:age];
}


#pragma mark - Private Methods

- (void)appDidReceiveMemoryWarningNotification {
    
    self.didReceiveMemoryWarningBlock ? self.didReceiveMemoryWarningBlock(self) : nil;
    
    if (self.shouldRemoveAllObjectsWhenMemoryWaring) {
        [self removeAllObjects];
    }
}

- (void)appDidEnterBackgroundNotification {
    
    self.didEnterBackgroundBlock ? self.didEnterBackgroundBlock(self) : nil;
    
    if (self.shouldRemoveAllObjectsWhenEnteringBackground) {
        [self removeAllObjects];
    }
    
}

- (void)trimRecursively {
    __weak typeof(self) _self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_autoTrimInterval * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        __strong typeof(_self) self = _self;
        if (!self) return;
        [self trimInBackground];
        [self trimRecursively];
    });
}

- (void)trimInBackground {
    dispatch_async(_queue, ^{
        [self _trimToCost:self->_costLimit];
        [self _trimToCount:self->_countLimit];
        [self _trimToAge:self->_ageLimit];
    });
}

- (void)_trimToCost:(NSUInteger)costLimit {
    BOOL finish = NO;
    OSSpinLockLock(&_lock);
    if (costLimit == 0) {
        [_lru removeAll];
        finish = YES;
    } else if (_lru->_totalCost <= costLimit) {
        finish = YES;
    }
    OSSpinLockUnlock(&_lock);
    if (finish) return;
    
    NSMutableArray *holder = [NSMutableArray new];
    while (!finish) {
        if (OSSpinLockTry(&_lock)) {
            if (_lru->_totalCost > costLimit) {
                XMNLinkedHashMapNode *node = [_lru removeTailNode];
                if (node) [holder addObject:node];
            } else {
                finish = YES;
            }
            OSSpinLockUnlock(&_lock);
        } else {
            usleep(10 * 1000); //10 ms
        }
    }
    if (holder.count) {
        dispatch_queue_t queue = XMNMemoryCacheGetReleaseQueue();
        dispatch_async(queue, ^{
            [holder count]; // release in queue
        });
    }
}

- (void)_trimToCount:(NSUInteger)countLimit {
    BOOL finish = NO;
    OSSpinLockLock(&_lock);
    if (countLimit == 0) {
        [_lru removeAll];
        finish = YES;
    } else if (_lru->_totalCount <= countLimit) {
        finish = YES;
    }
    OSSpinLockUnlock(&_lock);
    if (finish) return;
    
    NSMutableArray *holder = [NSMutableArray new];
    while (!finish) {
        if (OSSpinLockTry(&_lock)) {
            if (_lru->_totalCount > countLimit) {
                XMNLinkedHashMapNode *node = [_lru removeTailNode];
                if (node) [holder addObject:node];
            } else {
                finish = YES;
            }
            OSSpinLockUnlock(&_lock);
        } else {
            usleep(10 * 1000); //10 ms
        }
    }
    if (holder.count) {
        dispatch_queue_t queue = XMNMemoryCacheGetReleaseQueue();
        dispatch_async(queue, ^{
            [holder count]; // release in queue
        });
    }
}

- (void)_trimToAge:(NSTimeInterval)ageLimit {
    BOOL finish = NO;
    NSTimeInterval now = CACurrentMediaTime();
    OSSpinLockLock(&_lock);
    if (ageLimit <= 0) {
        [_lru removeAll];
        finish = YES;
    } else if (!_lru->_tail || (now - _lru->_tail->_time) <= ageLimit) {
        finish = YES;
    }
    OSSpinLockUnlock(&_lock);
    if (finish) return;
    
    NSMutableArray *holder = [NSMutableArray new];
    while (!finish) {
        if (OSSpinLockTry(&_lock)) {
            if (_lru->_tail && (now - _lru->_tail->_time) > ageLimit) {
                XMNLinkedHashMapNode *node = [_lru removeTailNode];
                if (node) [holder addObject:node];
            } else {
                finish = YES;
            }
            OSSpinLockUnlock(&_lock);
        } else {
            usleep(10 * 1000); //10 ms
        }
    }
    if (holder.count) {
        dispatch_queue_t queue = XMNMemoryCacheGetReleaseQueue();
        dispatch_async(queue, ^{
            [holder count]; // release in queue
        });
    }
}


#pragma mark - Setters

- (void)setReleaseAsync:(BOOL)releaseAsync {
    OSSpinLockLock(&_lock);
    _lru->_releaseAsync = releaseAsync;
    OSSpinLockUnlock(&_lock);
}

#pragma mark - Getters

- (NSUInteger)totalCount {
    OSSpinLockLock(&_lock);
    NSUInteger count = _lru->_totalCount;
    OSSpinLockUnlock(&_lock);
    return count;
}

- (NSUInteger)totalCost {
    OSSpinLockLock(&_lock);
    NSUInteger totalCost = _lru->_totalCost;
    OSSpinLockUnlock(&_lock);
    return totalCost;
}


- (BOOL)releaseAsync {
    OSSpinLockLock(&_lock);
    BOOL releaseAsynchronously = _lru->_releaseAsync;
    OSSpinLockUnlock(&_lock);
    return releaseAsynchronously;
}

- (NSString *)description {
    if (_name) return [NSString stringWithFormat:@"<%@: %p> (%@)", self.class, self, _name];
    else return [NSString stringWithFormat:@"<%@: %p>", self.class, self];
}

@end
