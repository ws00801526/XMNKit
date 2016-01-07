//
//  XMNThirdFunction+Weibo.h
//  XMNThirdExample
//
//  Created by XMFraker on 16/1/5.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNThirdFunction.h"

@class WeiboUser;

@interface XMNThirdFunction (Weibo)

/**
*  配置微博开放平台信息
*
*  @param appKey      微博开放平台appKey
*  @param redirectURI app对应的回调地址
*/
+ (void)connectWeiboWithAPPKey:(NSString *)appKey redirectURI:(NSString *)redirectURI;

/**
 *  判断微信是否安装
 *
 *  @return 已安装 YES   未安装NO
 */
+ (BOOL)isWeiboInstalled;


/**
 *  分享到微博平台
 *
 *  @param shareContent 分享的内容
 *  @param completionBlock       分享的回调
 *  @param authCompletionBlock   认证的回调
 */
+ (void)shareToWeiboWithShareContent:(XMNShareContent *)shareContent completionBlock:(void(^)(XMNShareContent *shareContent, NSError *error))completionBlock authCompletionBlock:(void(^)(id responseObject, NSError *error))authCompletionBlock;

/**
 *  登录微博平台 支持SSO登录
 *
 *  @param completionBlock 登录完成回调
 */
+ (void)authWeiboWithCompletionBlock:(void(^)(id responseObject, NSError *error))completionBlock;

/**
 *  获取登录用户的微博信息
 *
 *  @param completionBlock 获取信息完成回调
 */
+ (void)requestWeiboUserInfoWithCompletionBlock:(void(^)(WeiboUser *userInfo,NSError *error))completionBlock;

@end
