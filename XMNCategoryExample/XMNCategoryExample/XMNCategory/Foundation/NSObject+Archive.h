//
//  NSObject+Archive.h
//  iYunBao
//
//  Created by XMFraker on 16/1/4.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Archive)

/**
 *  利用NSKeyedArchive缓存一个NSObject
 *
 *  @param object   需要缓存的Object object为nil时,则删除存在的缓存
 *  @param fileName 缓存后的文件名
 *
 *  @return 是否缓存成功
 */
+ (BOOL)saveObject:(id)object toFile:(NSString *)fileName;

/**
 *  获取一个NSKeyedArchive缓存的NSObject
 *
 *  @param fileName 缓存后的文件名
 *
 *  @return nil 或者 缓存的NSObject实例
 */
+ (instancetype)objectForFile:(NSString *)fileName;

@end
