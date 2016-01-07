//
//  XMNThridFunction+WeChat.h
//  XMNThirdExample
//
//  Created by XMFraker on 16/1/4.
//  Copyright © 2016年 XMFraker. All rights reserved.
//


#import "XMNThirdFunction.h"

@protocol WXApiDelegate;

/** 分享到微信平台对应类型 */
typedef NS_ENUM(NSUInteger, XMNShareWechatType) {
    /** 分享到微信好友 */
    XMNShareWechatTypeSession = 0,
    /** 分享到微信朋友圈 */
    XMNShareWechatTypeTimeline,
    /** 分享到微信收藏 */
    XMNShareWechatTypeFavorite,
};


@interface XMNThirdFunction (WeChat)

/**
 *  配置微信开放平台信息
 *
 *  @param appID     微信开放平台appID
 *  @param appSecret 微信开放平台secret 用于获取用户信息使用
 */
+ (void)connectWeChatWithAPPID:(NSString *)appID appSecret:(NSString *)appSecret;

/**
 *  判断微信是否安装
 *
 *  @return 已安装 YES   未安装NO
 */
+ (BOOL)isWeChatInstalled;


/**
 *  分享到微信平台
 *
 *  @param shareContent 分享的内容
 *  @param type         分享到平台对应的类型
 *  @param completionBlock 分享完成的回调
 */
+ (void)shareToWeChatWithShareContent:(XMNShareContent *)shareContent type:(XMNShareWechatType)type completionBlock:(void(^)(XMNShareContent *shareContent,NSError *error))completionBlock;

/**
 *  使用微信登录功能,最简单的获取用户信息,支持用户未安装微信
 *
 *  @param viewController 使用登录功能所在的页面
 *  @param delegate       登录后回调参考WXApiDelegate协议
 *  @param completionBlock 完成回调
 */
+ (void)authWeChatInController:(UIViewController *)viewController withDelegate:(id<WXApiDelegate>)delegate completionBlock:(void(^)(NSDictionary *responseObject, NSError *error))completionBlock;

/**
 *  微信用户登录后,获取微信用户信息
 *
 *  @param completionBlock 获取信息完成后回调
 */
+ (void)requestWeChatUserInfoWithCompletionBlock:(void(^)(NSDictionary *responseObject, NSError *error))completionBlock;

@end
