//
//  XMNShare.m
//  XMNShareExample
//
//  Created by ChenMaolei on 15/12/29.
//  Copyright © 2015年 XMFraker. All rights reserved.
//

#import "XMNShare.h"


NSString *const kXMNThirdAPPIDKey = @"com.XMFraker.shareAPPIDKey";
NSString *const kXMNShareAPPSecreatKey = @"com.XMFraker.shareAPPSecreatKey";
NSString *const kXMNThirdCallbackKey = @"com.XMFraker.shareCallBackKey";

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

@end

@implementation XMNShare

#pragma mark - Life Cycle

+ (instancetype)share {
    static dispatch_once_t onceToken;
    static id share;
    dispatch_once(&onceToken, ^{
        share = [[XMNShare alloc] init];
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

+ (BOOL)canShareWithPlatform:(NSString *)platform shareContent:(XMNShareContent *)shareContent shareSuccessBlock:(void (^)(XMNShareContent *))shareSuccessBlock shareFailBlock:(void (^)(XMNShareContent *, NSError *))shareFailBlock {
    if ([self platformConfigurationForPlatform:platform]) {
        [[XMNShare share] setShareContent:shareContent];
        [[XMNShare share] setShareSuccessBlock:shareSuccessBlock];
        [[XMNShare share] setShareFailBlock:shareFailBlock];
        return YES;
    }else {
        NSLog(@"configure %@ platform info before use it",platform);
    }
    return NO;
}

+ (BOOL)canAuthWithPlatform:(NSString *)platform authSuccessBlock:(void (^)(NSDictionary *))authSuccessBlock authFailBlock:(void (^)(NSDictionary *, NSError *))authFailBlock {
    if ([self platformConfigurationForPlatform:platform]) {
        [[XMNShare share] setAuthFailBlock:authFailBlock];
        [[XMNShare share] setAuthSuccessBlock:authSuccessBlock];
        return YES;
    }else {
        NSLog(@"configure %@ platform info before use it",platform);
    }
    return NO;
}

+ (void)setPlatformConfiguration:(NSDictionary *)platformConfiguration forPlatform:(NSString *)platform {
    [[XMNShare share] appConfiguration][platform] = platformConfiguration;
}

+ (NSDictionary *)platformConfigurationForPlatform:(NSString *)platform {
    return [[XMNShare share] appConfiguration][platform];
}

+ (void)openURLString:(NSString *)URLString {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URLString]];
}

+ (BOOL)canOpenURLString:(NSString *)URLString {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:URLString]];
}

+(BOOL)handleOpenURL:(NSURL*)openUrl{
    [XMNShare share].returnURL = openUrl;
    for (NSString *platform in [[XMNShare share] appConfiguration]) {
        SEL sel = NSSelectorFromString([platform stringByAppendingString:@"_handleOpenURL"]);
        if ([self respondsToSelector:sel]) {
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                        [self methodSignatureForSelector:sel]];
            [invocation setSelector:sel];
            [invocation setTarget:self];
            [invocation invoke];
            BOOL returnValue;
            [invocation getReturnValue:&returnValue];
            if (returnValue) {//如果这个url能处理，就返回YES，否则，交给下一个处理。
                return YES;
            }
        }else{
            NSLog(@"%@ should have immplment method :%@",platform,[platform stringByAppendingString:@"_handleOpenURL"]);
        }
    }
    return NO;
}

@end
