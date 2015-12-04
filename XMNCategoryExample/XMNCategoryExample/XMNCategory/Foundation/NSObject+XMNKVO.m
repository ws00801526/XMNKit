//
//  NSObject+XMNKVO.m
//  XMNCategoryExample
//
//  Created by shscce on 15/12/4.
//  Copyright © 2015年 xmfraker. All rights reserved.
//

#import "NSObject+XMNKVO.h"

#import <objc/runtime.h>

static int kXMNKVOObserversKey;

/**
 *  带有block属性的Observer,内部类
 */
@interface _XMNObserver : NSObject

@property (nonatomic, copy) void (^block)(__weak id obj, id oldValue, id newValue);

- (instancetype)initWithBlock:(void(^)(__weak id object, id newValue, id oldValue))block;

@end

@implementation _XMNObserver

- (instancetype)initWithBlock:(void (^)(__weak id, id, id))block {
    if ([super init]) {
        self.block = block;
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (!self.block) return;
    
    BOOL isPrior = [[change objectForKey:NSKeyValueChangeNotificationIsPriorKey] boolValue];
    if (isPrior) return;
    
    NSKeyValueChange changeKind = [[change objectForKey:NSKeyValueChangeKindKey] integerValue];
    if (changeKind != NSKeyValueChangeSetting) return;
    
    id oldVal = [change objectForKey:NSKeyValueChangeOldKey];
    if (oldVal == [NSNull null]) oldVal = nil;
    
    id newVal = [change objectForKey:NSKeyValueChangeNewKey];
    if (newVal == [NSNull null]) newVal = nil;
    
    self.block(object, oldVal, newVal);
}

@end

@implementation NSObject (XMNKVO)

- (void)xmn_addObserverForKeyPath:(NSString *)keyPath withBlock:(void(^)(__weak id object, id oldValue, id newValue))block {
    if (!keyPath || !block) {
        return;
    }
    _XMNObserver *observer = [[_XMNObserver alloc] initWithBlock:block];
    NSMutableDictionary *allObserversDict = [self xmn_allObserversDict];
    NSMutableArray *observers = allObserversDict[keyPath];
    if (!observers) {
        observers = [NSMutableArray array];
        allObserversDict[keyPath] = observers;
    }
    [observers addObject:observer];
    [self addObserver:observer forKeyPath:keyPath options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:NULL];

}

- (void)xmn_removeObserverForKeyPath:(NSString *)keyPath {
    
    NSMutableDictionary *allObserversDict = [self xmn_allObserversDict];
    NSArray *observers = allObserversDict[keyPath];
    [observers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeObserver:obj forKeyPath:keyPath];
    }];
    [allObserversDict removeObjectForKey:keyPath];
    
}

- (void)xmn_removeAllObservers {
    
    NSMutableDictionary *allObserversDict = [self xmn_allObserversDict];
    [allObserversDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull keyPath, NSArray  *observers, BOOL * _Nonnull stop) {
        [observers enumerateObjectsUsingBlock:^(id  _Nonnull observer, NSUInteger idx, BOOL * _Nonnull stop) {
            [self removeObserver:observer forKeyPath:keyPath];
        }];
    }];
    
    [allObserversDict removeAllObjects];
}

- (NSMutableDictionary *)xmn_allObserversDict {
    
    NSMutableDictionary *allObserversDict = objc_getAssociatedObject(self, &kXMNKVOObserversKey);
    if (!allObserversDict) {
        allObserversDict = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &kXMNKVOObserversKey, allObserversDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return allObserversDict;
    
}

@end
