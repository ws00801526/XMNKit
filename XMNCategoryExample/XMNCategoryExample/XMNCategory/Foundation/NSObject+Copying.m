//
//  NSObject+ZACopying.m
//  iYunBao
//
//  Created by XMFraker on 16/1/4.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "NSObject+Copying.h"

#import <objc/runtime.h>

@implementation NSObject (Copying)

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *key = [NSString stringWithFormat:@"%s",property_getName(property)];
        id value = [self valueForKey:key];
        [aCoder encodeObject:value forKey:[NSString stringWithFormat:@"%@",key]];
    }
    free (properties);
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ([self init]) {
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList([self class], &outCount);
        for (i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            NSString *key = [NSString stringWithFormat:@"%s",property_getName(property)];
            id value = [aDecoder decodeObjectForKey:key];
            [self setValue:value forKey:key];
        }
        free (properties);
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    id copyObject = [[[self class] allocWithZone:zone] init];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *key = [NSString stringWithFormat:@"%s",property_getName(property)];
        id value = [self valueForKey:key];
        [copyObject setValue:value forKey:key];
    }
    free (properties);
    return copyObject;
}

@end
