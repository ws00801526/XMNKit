//
//  XMNThirdFunction+QQ.h
//  XMNThirdExample
//
//  Created by XMFraker on 16/1/6.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNThirdFunction.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>

/** qq分享的类型 */
typedef NS_ENUM(NSUInteger, XMNShareQQType) {
    /** 分享到QQ好友 */
    XMNShareQQTypeFriend = kQQAPICtrlFlagQQShare,
    /** 分享到QQ空间 */
    XMNShareQQTypeQZone,
    /** 分享到QQ收藏 */
    XMNShareQQTypeFavorites = kQQAPICtrlFlagQQShareFavorites,
    /** 使用数据线分享文件 */
    XMNShareQQTypeUSB = kQQAPICtrlFlagQQShareDataline,
};

@interface XMNThirdFunction (QQ)

/**
 *  配置QQ开放平台信息
 *
 *  @param appID      QQ互联开放平台appID 不可为空
 *  @param redirectURI app对应的回调地址  可为空
 */
+ (void)connectQQWithAppID:(NSString * _Nonnull)appID redirectURI:(NSString * _Nullable)redirectURI;

/**
 *  判断QQ是否安装
 *
 *  @return 已安装 YES   未安装NO
 */
+ (BOOL)isQQInstalled;

//+ (BOOL)hasQQAuthorized;
//
//+ (void)cancelQQAuthorize;

/**
 *  分享到QQ
 *
 *  @param shareContent    分享的内容
 *  @param type            分享的类型
 *  @param completionBlock 分享完成回调
 */
+ (void)shareToQQWithShareContent:(XMNShareContent *_Nonnull)shareContent type:(XMNShareQQType)type completionBlock:(void (^_Nonnull)(XMNShareContent *_Nonnull shareContent, NSError *_Nullable error))completionBlock;

/**
 *  登录QQ平台 支持SSO登录
 *
 *  @param completionBlock 登录完成回调
 */
+ (void)authQQWithCompletionBlock:(void(^_Nonnull)(id _Nullable responseObject, NSError  * _Nullable error))completionBlock;

/**
 *  获取QQ登录用户信息
 *
 *  @param completionBlock 获取完成回调
 */
+ (void)requestQQUserInfoWithCompletionBlock:(void(^_Nullable)(id _Nullable responseObject, NSError *_Nullable error))completionBlock;


@end
