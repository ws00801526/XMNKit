//
//  XMNThridFunction+WeChat.m
//  XMNThirdExample
//
//  Created by XMFraker on 16/1/4.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNThridFunction+WeChat.h"
#import "XMNThirdFunction+Supports.h"

#import "WXApi.h"

static NSString *const kXMNWeChatAuthScope = @"snsapi_userinfo,snsapi_base";
NSString *const kXMNWeChatPlatform  = @"wx";


/**
 *  处理微信发送消息,支付等回调
 */
@interface XMNWxApiManager : NSObject <WXApiDelegate>

@property (nonatomic, strong) XMNShareContent *shareContent;
@property (nonatomic, copy)   XMNShareCompletionBlock shareCompletionBlock;
@property (nonatomic, copy)   XMNAuthCompletionBlock  authCompletionBlock;


+ (instancetype)shareManager;

@end


@interface XMNThirdFunction (WeChatPrivateMethods)

+ (NSURLSessionDataTask *)_getAccessTokenWithCompletionHandler:(void(^)(id authInfo, NSError *error))completionHandler;
+ (NSURLSessionDataTask *)_refreshTokenWithCompletionHandler:(void(^)(id _Nullable responseObject, NSError * _Nullable error))completionHandler;
+ (void)_getWeChatUserInfoWithCompletionHandler:(void(^)(id  _Nullable responseObject, NSError * _Nullable error))completionHandler;

@end

@implementation XMNWxApiManager

+(instancetype)shareManager {
    static dispatch_once_t onceToken;
    static XMNWxApiManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[XMNWxApiManager alloc] init];
    });
    return instance;
}

#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        SendMessageToWXResp *messageResp = (SendMessageToWXResp *)resp;
        NSError *error;
        if (messageResp.errCode == WXSuccess) {
            error = nil;
        }else if (messageResp.errCode == WXErrCodeUserCancel) {
            error = [NSError errorWithDomain:kXMNWeChatPlatform code:messageResp.errCode userInfo:@{@"errorMsg":@"用户取消分享"}];
        }else {
            error = [NSError errorWithDomain:kXMNWeChatPlatform code:messageResp.errCode userInfo:@{@"errorMsg":resp.errStr ? : @"分享失败"}];
        }
        self.shareCompletionBlock ? self.shareCompletionBlock(self.shareContent, error) : nil;
        
    }else if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *authResp = (SendAuthResp *)resp;
        NSError *error = nil;
        if (resp.errCode == WXSuccess) {
            [XMNThirdFunction saveAuthInfo:@{kXMNAuthCodeKey:authResp.code} forPlatform:kXMNWeChatPlatform];
            [XMNThirdFunction _getAccessTokenWithCompletionHandler:^(id authInfo, NSError *error) {
                self.authCompletionBlock ? self.authCompletionBlock(authInfo, error) : nil;
            }];
            return;
        }else if (resp.errCode == WXErrCodeUserCancel) {
            error =  [NSError errorWithDomain:kXMNWeChatPlatform code:resp.errCode userInfo:@{@"errorMsg":@"用户取消授权"}];
        }else{
            error = [NSError errorWithDomain:kXMNWeChatPlatform code:resp.errCode userInfo:@{@"errorMsg":resp.errStr ? : @"微信登录失败"}];
        }
        self.authCompletionBlock ? self.authCompletionBlock (nil, error) : nil;
    }else if ([resp isKindOfClass:[PayResp class]]) {
        //TODO 处理支付成功回调结果
    }
}

@end



@implementation XMNThirdFunction (WeChat)

+ (void)connectWeChatWithAPPID:(NSString *)appID appSecret:(NSString *)appSecret {
    [WXApi registerApp:appID withDescription:kXMNWeChatPlatform];
    [self setPlatformConfiguration:@{kXMNThirdAPPIDKey:appID,kXMNThirdAPPSecretKey:appSecret} forPlatform:kXMNWeChatPlatform];
}

/**
 *  判断微信是否安装
 *
 *  @return 已安装 YES   未安装NO
 */
+ (BOOL)isWeChatInstalled {
    return [WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi];
}

/**
 *  分享到微信平台
 *
 *  @param shareContent 分享的内容
 *  @param type         分享到平台对应的类型
 *  @param completionBlock 分享完成的回调
 */
+ (void)shareToWeChatWithShareContent:(XMNShareContent *)shareContent type:(XMNShareWechatType)type completionBlock:(void(^)(XMNShareContent *shareContent,NSError *error))completionBlock {
    if ([self canShareWithPlatform:kXMNWeChatPlatform]) {
        [[XMNWxApiManager shareManager] setShareCompletionBlock:completionBlock];
        [[XMNWxApiManager shareManager] setShareContent:shareContent];
        SendMessageToWXReq *messageReq = [self _generateWeChatShareURLWithShareContent:shareContent shareType:type];
        //        messageReq.openID = [self _weChatPlatformConfigration][kXMNThirdAPPIDKey];
        [WXApi sendReq:messageReq];
    }
}

/**
 *  使用微信登录功能,最简单的获取用户信息,支持用户未安装微信
 *
 *  @param viewController 使用登录功能所在的页面
 *  @param delegate       登录后回调参考WXApiDelegate协议
 *  @param completionBlock 完成回调
 */
+ (void)authWeChatInController:(UIViewController *)viewController withDelegate:(id<WXApiDelegate>)delegate completionBlock:(void(^)(NSDictionary *responseObject, NSError *error))completionBlock {
    if ([self canAuthWithPlatform:kXMNWeChatPlatform]) {
        [XMNWxApiManager shareManager].authCompletionBlock = completionBlock;
        SendAuthReq *authReq = [self _generateWeChatAuthReq];
        //        authReq.openID =  [self _weChatPlatformConfigration][kXMNThirdAPPIDKey];
        [WXApi sendAuthReq:authReq viewController:viewController delegate:delegate];
    }
}

+ (void)requestWeChatUserInfoWithCompletionBlock:(void(^)(NSDictionary *responseObject, NSError *error))completionBlock {
    NSDictionary *weChatAuthInfo = [self authInfoForPlatform:kXMNWeChatPlatform];
    //1.检测是否有access_token
    //2.检测是否有code
    if (weChatAuthInfo[kXMNAuthTokenKey]) {
        //3.有access_token 直接获取用户信息
        [self _getWeChatUserInfoWithCompletionHandler:^(id  _Nullable responseObject, NSError * _Nullable error) {
            completionBlock(responseObject,error);
        }];
    } else {
        completionBlock(nil,[NSError errorWithDomain:kXMNWeChatPlatform code:-1 userInfo:@{@"errorMsg":@"用户还未登录微信"}]);
    }
}


+ (BOOL)wx_handleOpenURL:(NSURL *)openURL {
    return [WXApi handleOpenURL:openURL delegate:[XMNWxApiManager shareManager]];
}


/// ========================================
/// @name   微信授权,分享等私有方法
/// ========================================


+ (SendMessageToWXReq *)_generateWeChatShareURLWithShareContent:(XMNShareContent *)shareContent shareType:(XMNShareWechatType)shareType {
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.message = [WXMediaMessage message];
    req.scene = shareType;
    req.bText = NO;
    switch ([self _weChatShareContentTypeForShareContent:shareContent]) {
        case XMNShareContentTypeText:
        {
            //文本
            req = nil;
            req = [[SendMessageToWXReq alloc] init];
            req.bText = YES;
            req.text = shareContent.desc;
            break;
        }
        case XMNShareContentTypeImage:
        {
            //图片
            WXImageObject *imageObject = [WXImageObject object];
            imageObject.imageData = [self dataWithImage:shareContent.image];
            imageObject.imageUrl = shareContent.imageUrl;
            req.message.thumbData = shareContent.thumbnail ? [self dataWithImage:shareContent.thumbnail] : [self dataWithImage:shareContent.image scale:CGSizeMake(100, 100)];
            req.message.mediaObject = imageObject;
            break;
        }
        case XMNShareContentTypeNews:
        {
            req.message.title = shareContent.title;
            req.message.description = shareContent.desc ? : shareContent.title;
            WXWebpageObject *webpageObject = [WXWebpageObject object];
            webpageObject.webpageUrl = shareContent.link;
            req.message.thumbData = shareContent.thumbnail ? [self dataWithImage:shareContent.thumbnail] : [self dataWithImage:shareContent.image scale:CGSizeMake(100, 100)];
            req.message.mediaObject = webpageObject;
            break;
        }
        case XMNShareContentTypeEmotion:
        {
            WXEmoticonObject *emoticonObject = [WXEmoticonObject object];
            emoticonObject.emoticonData = shareContent.file ? : [self dataWithImage:shareContent.image];
            req.message.thumbData = shareContent.thumbnail ? [self dataWithImage:shareContent.thumbnail] : [self dataWithImage:shareContent.image scale:CGSizeMake(100, 100)];
            req.message.mediaObject = emoticonObject;
            break;
        }
        case XMNShareContentTypeAudio:
            //music
        {
            WXMusicObject *musicObject = [WXMusicObject object];
            req.message.title = shareContent.title;
            req.message.description = shareContent.desc ? : shareContent.title;
            musicObject.musicDataUrl = shareContent.mediaUrl;
            musicObject.musicUrl = shareContent.link;
            req.message.thumbData = shareContent.thumbnail ? [self dataWithImage:shareContent.thumbnail] : [self dataWithImage:shareContent.image scale:CGSizeMake(100, 100)];
            req.message.mediaObject = musicObject;
            break;
        }
        case XMNShareContentTypeVideo:
            //video
        {
            WXVideoObject *videoObject = [WXVideoObject object];
            req.message.title = shareContent.title;
            req.message.description = shareContent.desc ? : shareContent.title;
            videoObject.videoUrl = shareContent.mediaUrl;
            req.message.thumbData = shareContent.thumbnail ? [self dataWithImage:shareContent.thumbnail] : [self dataWithImage:shareContent.image scale:CGSizeMake(100, 100)];
            req.message.mediaObject = videoObject;
            break;
        }
        case XMNShareContentTypeeApp:
            //app
        {
            WXAppExtendObject *appObject = [WXAppExtendObject object];
            req.message.title = shareContent.title;
            req.message.description = shareContent.desc ? : shareContent.title;
            appObject.extInfo = shareContent.extInfo;
            appObject.fileData = shareContent.file;
            appObject.url = shareContent.link;
            req.message.thumbData = shareContent.thumbnail ? [self dataWithImage:shareContent.thumbnail] : [self dataWithImage:shareContent.image scale:CGSizeMake(100, 100)];
            req.message.mediaObject = appObject;
            break;
        }
        case XMNShareContentTypeFile:
        {
            //file
            WXFileObject *fileObject = [WXFileObject object];
            req.message.title = shareContent.title;
            req.message.description = shareContent.desc ? : shareContent.title;
            fileObject.fileExtension = shareContent.fileExt;
            fileObject.fileData = shareContent.file;
            req.message.thumbData = shareContent.thumbnail ? [self dataWithImage:shareContent.thumbnail] : [self dataWithImage:shareContent.image scale:CGSizeMake(100, 100)];
            req.message.mediaObject = fileObject;
            break;
        }
        default:
            break;
    }
    return req;
}

+ (SendAuthReq *)_generateWeChatAuthReq {
    SendAuthReq *authReq = [[SendAuthReq alloc] init];
    authReq.scope = kXMNWeChatAuthScope;
    authReq.state = @"start send auth";
    return authReq;
}

+ (XMNShareContentType)_weChatShareContentTypeForShareContent:(XMNShareContent *)shareContent {
    if (shareContent.contentType == XMNShareContentTypeUnknow) {
        if ([shareContent emptyValuesForKeys:@[@"image",@"link", @"file"] notEmptyValuesForKeys:@[@"title"]]) {
            return XMNShareContentTypeText;
        }else if ([shareContent emptyValuesForKeys:@[@"link"] notEmptyValuesForKeys:@[@"image"]]) {
            return XMNShareContentTypeImage;
        }else if ([shareContent emptyValuesForKeys:nil notEmptyValuesForKeys:@[@"link",@"title",@"image"]]) {
            return XMNShareContentTypeNews;
        }else if ([shareContent emptyValuesForKeys:@[@"link"] notEmptyValuesForKeys:@[@"file"]]) {
            return XMNShareContentTypeEmotion;
        }
    }
    return shareContent.contentType;
}

+ (NSDictionary *)_weChatPlatformConfigration {
    return [self platformConfigurationForPlatform:kXMNWeChatPlatform];
}


/// ========================================
/// @name   获取微信用户信息相关接口请求
/// ========================================

/**
 *  获取access_token授权接口
 *
 *  @param completionHandler 完成回调block
 *
 *  @return 接口实例
 */
+ (NSURLSessionDataTask *)_getAccessTokenWithCompletionHandler:(void(^)(id authInfo, NSError *error))completionHandler {
    NSMutableDictionary *weChatAuthInfo = [NSMutableDictionary dictionaryWithDictionary:[self authInfoForPlatform:kXMNWeChatPlatform]];
    NSURLSessionDataTask *accessTokenTask = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",[self _weChatPlatformConfigration][kXMNThirdAPPIDKey],[self _weChatPlatformConfigration][kXMNThirdAPPSecretKey],weChatAuthInfo[@"code"]]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger errcode = -1000;
        NSString *errmsg = @"获取用户信息出错,请重试";
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if (dict[@"errcode"]) {
            errcode = [dict[@"errcode"] integerValue];
            errmsg = dict[@"errmsg"];
            NSError *error = [NSError errorWithDomain:kXMNWeChatPlatform code:errcode userInfo:@{@"errorMsg":errmsg}];
            [self saveAuthInfo:nil forPlatform:kXMNWeChatPlatform];
            completionHandler(nil,error);
        }else {
            NSDictionary *info = @{kXMNAuthTokenKey:dict[@"access_token"],kXMNAuthRefreshTokenKey:dict[@"refresh_toekn"],kXMNAuthUserIDKey:dict[@"openid"]};
            [weChatAuthInfo addEntriesFromDictionary:info];
            [self saveAuthInfo:weChatAuthInfo forPlatform:kXMNWeChatPlatform];
            completionHandler(info,nil);
        }
    }];
    [accessTokenTask resume];
    return accessTokenTask;
}


/**
 *  刷新token接口
 *
 *  @param completionHandler 回调完成block
 *
 *  @return 刷新token接口的实例
 */
+ (NSURLSessionDataTask *)_refreshTokenWithCompletionHandler:(void(^)(id _Nullable responseObject, NSError * _Nullable error))completionHandler {
    NSMutableDictionary *weChatAuthInfo = [NSMutableDictionary dictionaryWithDictionary:[self authInfoForPlatform:kXMNWeChatPlatform]];
    NSURLSessionDataTask *refreshTokenTask = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=%@&grant_type=refresh_token&refresh_token=%@",[self _weChatPlatformConfigration][kXMNThirdAPPIDKey],weChatAuthInfo[kXMNAuthRefreshTokenKey]]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger errcode = -1000;
        NSString *errmsg = @"获取用户信息出错,请重试";
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if (dict[@"errcode"]) {
            errcode = [dict[@"errcode"] integerValue];
            errmsg = dict[@"errmsg"];
            NSError *error = [NSError errorWithDomain:kXMNWeChatPlatform code:errcode userInfo:@{@"errorMsg":errmsg}];
            [self saveAuthInfo:nil forPlatform:kXMNWeChatPlatform];
            completionHandler(nil,error);
        }else {
            NSDictionary *info = @{kXMNAuthTokenKey:dict[@"access_token"],kXMNAuthRefreshTokenKey:dict[@"refresh_toekn"],kXMNAuthUserIDKey:dict[@"openid"]};
            [weChatAuthInfo addEntriesFromDictionary:info];
            [self saveAuthInfo:weChatAuthInfo forPlatform:kXMNWeChatPlatform];
            completionHandler(info,nil);
        }
    }];
    [refreshTokenTask resume];
    return refreshTokenTask;
}

/**
 *  通过接口获取微信用
 户信息
 *  先刷新token ->  在获取信息
 *  @param completionHandler 完成后回调
 *
 */
+ (void)_getWeChatUserInfoWithCompletionHandler:(void(^)(id  _Nullable responseObject, NSError * _Nullable error))completionHandler {
    [self _refreshTokenWithCompletionHandler:^(id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            completionHandler(nil, error);
        }else {
            NSURLSessionDataTask *userInfoTask = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",responseObject[@"access_toekn"],responseObject[@"openid"]]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSInteger errcode = -1000;
                NSString *errmsg = @"获取用户信息出错,请重试";
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                if (dict[@"errcode"]) {
                    errcode = [dict[@"errcode"] integerValue];
                    errmsg = dict[@"errmsg"];
                    NSError *error = [NSError errorWithDomain:kXMNWeChatPlatform code:errcode userInfo:@{@"errorMsg":errmsg}];
                    completionHandler(nil,error);
                }else {
                    completionHandler(dict,nil);
                }
            }];
            [userInfoTask resume];
        }
    }];
}

@end

