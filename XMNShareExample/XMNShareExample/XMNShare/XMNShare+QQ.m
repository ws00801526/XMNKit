//
//  XMNShare+QQ.m
//  XMNShareExample
//
//  Created by ChenMaolei on 15/12/30.
//  Copyright © 2015年 XMFraker. All rights reserved.
//

#import "XMNShare+QQ.h"
#import "XMNShare+Supports.h"

#define kXMNQQPlatform @"qq"
#define kXMNQQSDKVersion @"2.9"

@implementation XMNShare (QQ)

/**
 *  配置QQ平台账号
 *  URLSchems需要配置  xxxx为您的appid
 *  tencentxxxx
 *  tencentxxxx.content
 *  QQXXXXX -- appid对应的16进制
 *  @param appid QQ互联开放平台的APPID
 */
+ (void)connectQQWithAppID:(NSString *)appid {
    [XMNShare share].appConfiguration[kXMNQQPlatform] = @{kXMNThirdAPPIDKey:appid,kXMNThirdCallbackKey:[NSString stringWithFormat:@"QQ%02llx",[appid longLongValue]]};
}

/**
 *  判断QQ是否安装
 *
 *  @return QQ是否安装 YES NO
 */
+ (BOOL)isQQInstalled {
    return [self canOpenURLString:@"mqqapi://"];
}

/**
 *  分享到QQ对应平台
 *
 *  @param shareContent 分享内容
 *  @param type         分享类型
 *  @param successBlock 分享成功回调
 *  @param failBlock    分享失败回调
 */
+ (void)shareQQWithContent:(XMNShareContent *)shareContent type:(XMNShareQQType)type successBlock:(void (^)(XMNShareContent *shareContent))successBlock failBlock:(void (^)(XMNShareContent *shareContent, NSError *error))failBlock {
    if ([self canShareWithPlatform:kXMNQQPlatform shareContent:shareContent shareSuccessBlock:successBlock shareFailBlock:failBlock]) {
        
    }
}


/**
 *  使用QQ登录功能
 *
 *  @param scope        登录权限
 *  scope对应类型        默认不传则为get_user_info
 @"get_user_info,get_simple_userinfo,add_album,add_idol,add_one_blog,add_pic_t,add_share,add_topic,check_page_fans,del_idol,del_t,get_fanslist,get_idollist,get_info,get_other_info,get_repost_list,list_album,upload_pic,get_vip_info,get_vip_rich_info,get_intimate_friends_weibo,match_nick_tips_weibo",
 *  @param successBlock 成功回调
 *  @param failBlock    失败回调
 */
+ (void)authQQWithScope:(NSString *)scope successBlock:(void(^)(NSDictionary *responseObject))successBlock failBlock:(void(^)(NSDictionary *responseObject,NSError *error))failBlock {
    if ([self canAuthWithPlatform:kXMNQQPlatform authSuccessBlock:successBlock authFailBlock:failBlock]) {
        NSDictionary *authData=@{@"app_id" : [self platformConfigurationForPlatform:kXMNQQPlatform][kXMNThirdAPPIDKey],
                                 @"app_name" : [self CFBundleDisplayName],
                                 //@"bundleid":[self CFBundleIdentifier],//或者有，或者正确(和后台配置一致)，建议不填写。
                                 @"client_id" :[self platformConfigurationForPlatform:kXMNQQPlatform][kXMNThirdAPPIDKey],
                                 @"response_type" : @"token",
                                 @"scope" : scope ? scope : @"",//@"get_user_info,get_simple_userinfo,add_album,add_idol,add_one_blog,add_pic_t,add_share,add_topic,check_page_fans,del_idol,del_t,get_fanslist,get_idollist,get_info,get_other_info,get_repost_list,list_album,upload_pic,get_vip_info,get_vip_rich_info,get_intimate_friends_weibo,match_nick_tips_weibo",
                                 @"sdkp" :@"i",
                                 @"sdkv" : kXMNQQSDKVersion,
                                 @"status_machine" : [[UIDevice currentDevice] model],
                                 @"status_os" : [[UIDevice currentDevice] systemVersion],
                                 @"status_version" : [[UIDevice currentDevice] systemVersion]
                                 };
        
        [self setGeneralPasteboard:[@"com.tencent.tencent" stringByAppendingString:[self platformConfigurationForPlatform:kXMNQQPlatform][kXMNThirdAPPIDKey]] Value:authData encoding:XMNPboardEncodingKeyedArchiver];
        [self openURLString:[NSString stringWithFormat:@"mqqOpensdkSSoLogin://SSoLogin/tencent%@/com.tencent.tencent%@?generalpastboard=1",[self platformConfigurationForPlatform:kXMNQQPlatform][kXMNThirdAPPIDKey],[self platformConfigurationForPlatform:kXMNQQPlatform][kXMNThirdAPPIDKey]]];
    }
}

+ (BOOL)qq_handleOpenURL{
    NSURL* url=[[XMNShare share] returnURL];
    if ([url.scheme hasPrefix:@"QQ"]) {
        //分享
        NSDictionary *dic=[self parseUrl:url];
        if (dic[@"error_description"]) {
            [dic setValue:[self base64Decode:dic[@"error_description"]] forKey:@"error_description"];
        }
        if ([dic[@"error"] intValue]!=0) {
            NSError *err=[NSError errorWithDomain:@"response_from_qq" code:[dic[@"error"] intValue] userInfo:dic];
            [[XMNShare share] shareFailBlock] ? [[XMNShare share] shareFailBlock]([XMNShare share].shareContent,err) : nil;
        }else{
            [[XMNShare share] shareSuccessBlock] ? [[XMNShare share] shareSuccessBlock]([XMNShare share].shareContent) : nil;
        }
        return YES;
    }else if([url.scheme hasPrefix:@"tencent"]){
        //登陆auth
        NSDictionary *ret=[self generalPasteboardData:[@"com.tencent.tencent" stringByAppendingString:[self platformConfigurationForPlatform:kXMNQQPlatform][kXMNThirdAPPIDKey]] encoding:XMNPboardEncodingKeyedArchiver];
        if (ret[@"ret"]&&[ret[@"ret"] intValue]==0) {
            [XMNShare share].authSuccessBlock ? [XMNShare share].authSuccessBlock(ret) : nil;
        }else{
            NSError *err=[NSError errorWithDomain:@"auth_from_QQ" code:-1 userInfo:ret];
            [XMNShare share].authFailBlock ? [XMNShare share].authFailBlock(ret,err) : nil;
        }
        return YES;
    }
    else{
        return NO;
    }
}

/**
 *  把msg分享到shareTO
 *
 *  @param msg     OSmessage
 *  @param shareTo 0是好友／1是QQ空间。
 *
 *  @return 需要打开的url
 */
+ (NSString *)_generateQQShareUrl:(XMNShareContent *)msg to:(XMNShareQQType)shareTo{
    NSMutableString *ret=[[NSMutableString alloc] initWithString:@"mqqapi://share/to_fri?thirdAppDisplayName="];
    [ret appendString:[self base64Encode:[self CFBundleDisplayName]]];
    [ret appendString:@"&version=1&cflag="];
    [ret appendFormat:@"%ld",shareTo];
    [ret appendString:@"&callback_type=scheme&generalpastboard=1"];
    [ret appendString:@"&callback_name="];
    [ret appendString:[self platformConfigurationForPlatform:kXMNQQPlatform][kXMNThirdCallbackKey]];
    [ret appendString:@"&src_type=app&shareType=0&file_type="];
    switch ([self _qqShareContentTypeWithShareContent:msg]) {
        case XMNShareContentTypeText:
        {
            //纯文本分享。
            [ret appendString:@"text&file_data="];
            [ret appendString:[self urlEncodeAfterBase64:msg.title]];
        }
            break;
        case XMNShareContentTypeImage:
        {
            //图片分享
            NSDictionary *data=@{@"file_data":[self dataWithImage:msg.image],
                                 @"previewimagedata":msg.thumbnail?  [self dataWithImage:msg.thumbnail] :[self dataWithImage:msg.image scale:CGSizeMake(36, 36)]
                                 };
            [self setGeneralPasteboard:@"com.tencent.mqq.api.apiLargeData" Value:data encoding:XMNPboardEncodingKeyedArchiver];
            [ret appendString:@"img&title="];
            [ret appendString:[self base64Encode:msg.title]];
            [ret appendString:@"&objectlocation=pasteboard&description="];
            [ret appendString:[self base64Encode:msg.desc]];
        }
            break;
        case XMNShareContentTypeNews:
        {
            //新闻／多媒体分享（图片加链接）发送新闻消息 预览图像数据，最大1M字节 URL地址,必填，最长512个字符 via QQApiInterfaceObject.h
            NSDictionary *data=@{@"previewimagedata":[self dataWithImage:msg.image]};
            [self setGeneralPasteboard:@"com.tencent.mqq.api.apiLargeData" Value:data encoding:XMNPboardEncodingKeyedArchiver];
            NSString *msgType=@"news";
            [ret appendFormat:@"%@&title=%@&url=%@&description=%@&objectlocation=pasteboard",msgType,[self urlEncodeAfterBase64:msg.title],[self urlEncodeAfterBase64:msg.link],[self urlEncodeAfterBase64:msg.desc]];
        }
        case XMNShareContentTypeAudio:
        {
            NSDictionary *data=@{@"previewimagedata":[self dataWithImage:msg.image]};
            [self setGeneralPasteboard:@"com.tencent.mqq.api.apiLargeData" Value:data encoding:XMNPboardEncodingKeyedArchiver];
            NSString *msgType=@"audio";
            [ret appendFormat:@"%@&title=%@&url=%@&description=%@&objectlocation=pasteboard",msgType,[self urlEncodeAfterBase64:msg.title],[self urlEncodeAfterBase64:msg.link],[self urlEncodeAfterBase64:msg.desc]];
        }
            break;
        default:
            break;
    }
    return ret;
}

+ (XMNShareContentType)_qqShareContentTypeWithShareContent:(XMNShareContent *)shareContent{
    //修正如果有link，则默认是news分享类型。
    if (shareContent.link && shareContent.contentType == XMNShareContentTypeUnknow) {
        return XMNShareContentTypeNews;
    }
    if ([shareContent emptyValuesForKeys:@[@"image",@"link"] notEmptyValuesForKeys:@[@"title"]]) {
        return XMNShareContentTypeText;
    }else if ([shareContent emptyValuesForKeys:@[@"link"] notEmptyValuesForKeys:@[@"title",@"image",@"desc"]]) {
        return XMNShareContentTypeImage;
    }else if ([shareContent emptyValuesForKeys:nil notEmptyValuesForKeys:@[@"title",@"desc",@"image",@"link"]]) {
        return XMNShareContentTypeNews;
    }
    return XMNShareContentTypeUnknow;
}

@end
