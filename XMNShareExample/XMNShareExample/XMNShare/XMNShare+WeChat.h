//
//  XMNShare+WeChat.h
//  XMNShareExample
//
//  Created by ChenMaolei on 15/12/30.
//  Copyright © 2015年 XMFraker. All rights reserved.
//

#import "XMNShare.h"

/** 分享到微信平台对应类型 */
typedef NS_ENUM(NSUInteger, XMNShareWechatType) {
    /** 分享到微信好友 */
    XMNShareWechatTypeSession = 0,
    /** 分享到微信朋友圈 */
    XMNShareWechatTypeTimeline,
    /** 分享到微信收藏 */
    XMNShareWechatTypeFavorite,
};

@interface XMNShare (WeChat)

/**
 *  配置微信开放平台信息
 *
 *  @param appID 微信开放平台appID
 */
+ (void)connectWeChatWithAPPID:(NSString *)appID;

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
 *  @param successBlock 分享成功的回调
 *  @param failBlock    分享失败的回调
 */
+ (void)shareToWeChatWithShareContent:(XMNShareContent *)shareContent type:(XMNShareWechatType)type successBlock:(void(^)(XMNShareContent *shareContent))successBlock failBlock:(void(^)(XMNShareContent *shareContent, NSError *error))failBlock;

/**
 *  使用微信登录功能
 *
 *  @param scope        登录权限类型,默认snsapi_userinfo获取用户信息
 *  @param successBlock 授权成功回调
 *  @param failBlock    授权失败回调
 */
+ (void)authWeChatWithScope:(NSString *)scope successBlock:(void(^)(NSDictionary *responseObject))successBlock failBlock:(void(^)(NSDictionary *responseObject, NSError *error))failBlock;

@end
