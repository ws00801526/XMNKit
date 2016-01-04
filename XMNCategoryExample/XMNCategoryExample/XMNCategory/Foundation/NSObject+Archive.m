//
//  NSObject+Archive.m
//  iYunBao
//
//  Created by XMFraker on 16/1/4.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "NSObject+Archive.h"

static NSString *kXMNFileCahceDirectory;
static dispatch_once_t onceToken;

@implementation NSObject (Archive)

+ (BOOL)saveObject:(id)object toFile:(NSString *)fileName {
    dispatch_once(&onceToken, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        kXMNFileCahceDirectory = [[paths firstObject] stringByAppendingFormat:@"fileCache"];
    });
    NSString *dataPath = [kXMNFileCahceDirectory stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath isDirectory:nil]) {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:dataPath error:&error];
        return error ? NO : YES;
    }else {
        return [NSKeyedArchiver archiveRootObject:self toFile:dataPath];
    }
}

+ (instancetype)objectForFile:(NSString *)fileName {
    dispatch_once(&onceToken, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        kXMNFileCahceDirectory = [[paths firstObject] stringByAppendingFormat:@"fileCache"];
    });
    NSString *dataPath = [kXMNFileCahceDirectory stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath isDirectory:nil]) {
        return [NSKeyedUnarchiver unarchiveObjectWithFile:dataPath];
    }else {
        return nil;
    }
}

@end
