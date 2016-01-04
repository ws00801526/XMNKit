//
//  XMNShare+QQ.h
//  XMNShareExample
//
//  Created by ChenMaolei on 15/12/30.
//  Copyright © 2015年 XMFraker. All rights reserved.
//

#import "XMNShare.h"

/** QQ分享对应类型 */
typedef NS_ENUM(NSUInteger, XMNShareQQType) {
    /** 分享到QQ好友 */
    XMNShareQQTypeFriends = 0,
    /** 分享到QQ空间 */
    XMNShareQQTypeQZone = 0x01,
    /** 分享到QQ收藏 */
    XMNShareQQTypeFavorite = 0x08,
    /** 分享到数据线 */
    XMNShareQQTypeDataline = 0x10
};

@interface XMNShare (QQ)

/**
 *  配置QQ平台账号
 *  URLSchems需要配置  xxxx为您的appid
 *  tencentxxxx
 *  tencentxxxx.content
 *  QQXXXXX -- appid对应的16进制
 *  @param appid QQ互联开放平台的APPID
 */
+ (void)connectQQWithAppID:(NSString *)appid;

/**
 *  判断QQ是否安装
 *
 *  @return QQ是否安装 YES NO
 */
+ (BOOL)isQQInstalled;

/**
 *  分享到QQ对应平台
 *
 *  @param shareContent 分享内容
 *  @param type         分享类型
 *  @param successBlock 分享成功回调
 *  @param failBlock    分享失败回调
 */
+ (void)shareQQWithContent:(XMNShareContent *)shareContent type:(XMNShareQQType)type successBlock:(void (^)(XMNShareContent *shareContent))successBlock failBlock:(void (^)(XMNShareContent *shareContent, NSError *error))failBlock;


/**
 *  使用QQ登录功能
 *
 *  @param scope        登录权限
 *  scope对应类型        默认不传则为get_user_info
@"get_user_info,get_simple_userinfo,add_album,add_idol,add_one_blog,add_pic_t,add_share,add_topic,check_page_fans,del_idol,del_t,get_fanslist,get_idollist,get_info,get_other_info,get_repost_list,list_album,upload_pic,get_vip_info,get_vip_rich_info,get_intimate_friends_weibo,match_nick_tips_weibo",
 *  @param successBlock 成功回调
 *  @param failBlock    失败回调
 */
+ (void)authQQWithScope:(NSString *)scope successBlock:(void(^)(NSDictionary *responseObject))successBlock failBlock:(void(^)(NSDictionary *responseObject,NSError *error))failBlock;

@end
