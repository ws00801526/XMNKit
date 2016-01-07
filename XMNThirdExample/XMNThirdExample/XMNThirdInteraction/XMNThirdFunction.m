//
//  XMNThridFunction.m
//  XMNThirdExample
//
//  Created by XMFraker on 16/1/4.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNThirdFunction.h"

NSString *const kXMNThirdAPPIDKey = @"com.XMFraker.shareAPPIDKey";
NSString *const kXMNThirdAPPSecretKey = @"com.XMFraker.shareAPPSecretKey";
NSString *const kXMNThirdCallbackKey = @"com.XMFraker.shareCallBackKey";

NSString *const kXMNAuthCodeKey = @"com.XMFraker.weChat.AuthCodeKey";
NSString *const kXMNAuthTokenKey = @"com.XMFraker.authTokenKey";
NSString *const kXMNAuthRefreshTokenKey = @"com.XMFraker.authRefreshTokenKey";
NSString *const kXMNAuthUserIDKey = @"com.XMFraker.authUserIDKey";

static NSString *kXMNAuthInfoCahcePath;
static dispatch_once_t onceToken;

@implementation XMNShareContent

- (BOOL)emptyValuesForKeys:(NSArray *)emptyKeys notEmptyValuesForKeys:(NSArray *)notEmptyKeys {
    @try {
        if (emptyKeys) {
            for (NSString *key in emptyKeys) {
                if ([self valueForKey:key]) {
                    return NO;
                }
            }
        }
        if (notEmptyKeys) {
            for (NSString *key in notEmptyKeys) {
                if (![self valueForKey:key]) {
                    return NO;
                }
            }
        }
        return YES;
    }
    @catch (NSException *exception) {
        NSLog(@"isEmpty error:\n %@",exception);
        return NO;
    }
}

- (UIImage *)image {
    if (_image) {
        return _image;
    }
    if (_imageUrl) {
        return [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_imageUrl]]];
    }
    return nil;
}

@end

@implementation XMNThirdFunction

+ (instancetype)shareFunction {
    static dispatch_once_t onceToken;
    static id share;
    dispatch_once(&onceToken, ^{
        share = [[[self class] alloc] init];
    });
    return share;
}

- (instancetype)init {
    if ([super init]) {
        _appConfiguration = [NSMutableDictionary dictionary];
    }
    return self;
}


#pragma mark - Methods

+ (BOOL)canShareWithPlatform:(NSString *)platform{
    if ([self platformConfigurationForPlatform:platform]) {
        return YES;
    }else {
        NSLog(@"configure %@ platform info before use it",platform);
    }
    return NO;
}

+ (BOOL)canAuthWithPlatform:(NSString *)platform{
    if ([self platformConfigurationForPlatform:platform]) {
        return YES;
    }else {
        NSLog(@"configure %@ platform info before use it",platform);
    }
    return NO;
}

+ (void)setPlatformConfiguration:(NSDictionary *)platformConfiguration forPlatform:(NSString *)platform {
    [[XMNThirdFunction shareFunction] appConfiguration][platform] = platformConfiguration;
}

+ (NSDictionary *)platformConfigurationForPlatform:(NSString *)platform {
    return [[XMNThirdFunction shareFunction] appConfiguration][platform];
}


+ (NSDictionary *)authInfoForPlatform:(NSString *)platform {
    dispatch_once(&onceToken, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        kXMNAuthInfoCahcePath = [[paths firstObject] stringByAppendingPathComponent:@"authInfo"];
        if (![  [NSFileManager defaultManager] fileExistsAtPath:kXMNAuthInfoCahcePath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:kXMNAuthInfoCahcePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    });
    NSString *dataPath = [kXMNAuthInfoCahcePath stringByAppendingPathComponent:platform];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
        NSData *data = [NSKeyedUnarchiver unarchiveObjectWithFile:dataPath];
        if (data) {
            return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        }
        return nil;
    }
    return nil;
}

+ (BOOL)saveAuthInfo:(NSDictionary *)authInfo forPlatform:(NSString *)platform {
    
    
    dispatch_once(&onceToken, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        kXMNAuthInfoCahcePath = [[paths firstObject] stringByAppendingPathComponent:@"authInfo"];
        if (![  [NSFileManager defaultManager] fileExistsAtPath:kXMNAuthInfoCahcePath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:kXMNAuthInfoCahcePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    });
    NSString *dataPath = [kXMNAuthInfoCahcePath stringByAppendingPathComponent:platform];
    if (!authInfo) {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:dataPath error:&error];
        return error ? NO : YES;
    }else {
        NSData *data = [NSJSONSerialization dataWithJSONObject:authInfo options:NSJSONWritingPrettyPrinted error:nil];
        if (data) {
            return [NSKeyedArchiver archiveRootObject:data toFile:dataPath];
        }
        return NO;
    }
}

+ (BOOL)handleOpenURL:(NSURL*)openUrl{
    for (NSString *platform in [[XMNThirdFunction shareFunction] appConfiguration]) {
        SEL sel = NSSelectorFromString([platform stringByAppendingString:@"_handleOpenURL:"]);
        if ([self respondsToSelector:sel]) {
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                        [self methodSignatureForSelector:sel]];
            [invocation setSelector:sel];
            [invocation setTarget:self];
            [invocation setArgument:&openUrl atIndex:2];
            [invocation retainArguments];
            [invocation invoke];
            BOOL returnValue;
            [invocation getReturnValue:&returnValue];
            if (returnValue) {//如果这个url能处理，就返回YES，否则，交给下一个处理。
                return YES;
            }
        }else{
            NSLog(@"%@ should have immplment method :%@",platform,[platform stringByAppendingString:@"_handleOpenURL:"]);
        }
    }
    return NO;
}

/**
 *  取消分享平台授权
 *
 *  @param platformType  平台类型
 */
+ (void)cancelAuthorize:(NSString *)platform {
    [self saveAuthInfo:nil forPlatform:platform];
}

/**
 *  判断分享平台是否授权
 *
 *  @param platformType 平台类型
 *  @return YES 表示已授权，NO 表示尚未授权
 */
+ (BOOL)hasAuthorized:(NSString *)platform {
    return [self authInfoForPlatform:platform] != nil;
}

@end
