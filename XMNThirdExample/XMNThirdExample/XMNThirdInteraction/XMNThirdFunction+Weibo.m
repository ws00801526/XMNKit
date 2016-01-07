//
//  XMNThirdFunction+Weibo.m
//  XMNThirdExample
//
//  Created by XMFraker on 16/1/5.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNThirdFunction+Weibo.h"
#import "XMNThirdFunction+Supports.h"

#import "WeiboUser.h"
#import "WeiboSDK.h"

NSString *const kXMNWeiboPlatform  = @"wb";

@interface XMNWeiboManager : NSObject <WeiboSDKDelegate>

@property (nonatomic, strong) XMNShareContent *shareContent;
@property (nonatomic, copy)   XMNShareCompletionBlock shareCompletionBlock;
@property (nonatomic, copy)   XMNAuthCompletionBlock  authCompletionBlock;


+ (instancetype)shareManager;

@end

@implementation XMNWeiboManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    static id manager;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] init];
    });
    return manager;
}

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {
    NSLog(@"receive weibo request :%@",request);
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    
    NSMutableDictionary *authInfo = [NSMutableDictionary dictionaryWithDictionary:[XMNThirdFunction authInfoForPlatform:kXMNWeiboPlatform]];
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
        WBSendMessageToWeiboResponse* sendMessageToWeiboResponse = (WBSendMessageToWeiboResponse*)response;
        NSString* access_token = [sendMessageToWeiboResponse.authResponse accessToken];
        NSString* userID = [sendMessageToWeiboResponse.authResponse userID];
        if (access_token && userID) {
            authInfo[kXMNAuthTokenKey] = access_token;
            authInfo[kXMNAuthUserIDKey] = userID;
            [XMNThirdFunction saveAuthInfo:authInfo forPlatform:kXMNWeiboPlatform];
        }
        NSError *error = response.statusCode != WeiboSDKResponseStatusCodeSuccess ? [NSError errorWithDomain:kXMNWeiboPlatform code:response.statusCode userInfo:@{@"errorMsg":[self _responseErrorMsgForStatusCode:response.statusCode]}] : nil;
        self.shareCompletionBlock ? self.shareCompletionBlock(self.shareContent, error) : nil;
    } else if ([response isKindOfClass:WBAuthorizeResponse.class]) {
        
        NSString *access_token = [(WBAuthorizeResponse *)response accessToken];
        NSString *userID = [(WBAuthorizeResponse *)response userID];
        NSString *refresh_token = [(WBAuthorizeResponse *)response refreshToken];
        authInfo[kXMNAuthTokenKey] = access_token;
        authInfo[kXMNAuthUserIDKey] = userID;
        authInfo[kXMNAuthRefreshTokenKey] = refresh_token;
        [XMNThirdFunction saveAuthInfo:authInfo forPlatform:kXMNWeiboPlatform];
        NSError *error = response.statusCode != WeiboSDKResponseStatusCodeSuccess ? [NSError errorWithDomain:kXMNWeiboPlatform code:response.statusCode userInfo:@{@"errorMsg":[self _responseErrorMsgForStatusCode:response.statusCode]}] : nil;
        self.authCompletionBlock ? self.authCompletionBlock(authInfo, error) : nil;
    }
}

- (NSString *)_responseErrorMsgForStatusCode:(WeiboSDKResponseStatusCode)statusCode {
    switch (statusCode) {
        case WeiboSDKResponseStatusCodeSuccess:
            return @"分享成功";
            break;
        case WeiboSDKResponseStatusCodeUserCancel:
            return @"用户取消";
            break;
        case WeiboSDKResponseStatusCodeAuthDeny:
            return @"授权失败";
            break;
        case WeiboSDKResponseStatusCodePayFail:
            return @"支付失败";
            break;
        case WeiboSDKResponseStatusCodeSentFail:
            return @"发送消息失败";
            break;
        case WeiboSDKResponseStatusCodeShareInSDKFailed:
            return @"分享到SDK失败";
            break;
        case WeiboSDKResponseStatusCodeUserCancelInstall:
            return @"用户取消安装微博客户端";
            break;
        case WeiboSDKResponseStatusCodeUnsupport:
            return @"不支持的请求操作";
            break;
        default:
            return @"未知错误类型";
            break;
    }
}

@end


@implementation XMNThirdFunction (Weibo)

/**
 *  配置微博开放平台信息
 *
 *  @param appKey      微博开放平台appKey
 *  @param redirectURI app对应的回调地址
 */
+ (void)connectWeiboWithAPPKey:(NSString *)appKey redirectURI:(NSString *)redirectURI {
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:appKey];
    [self setPlatformConfiguration:@{kXMNThirdAPPIDKey:appKey,kXMNThirdCallbackKey:redirectURI} forPlatform:kXMNWeiboPlatform];
}

/**
 *  判断微博是否安装
 *
 *  @return 已安装 YES   未安装NO
 */
+ (BOOL)isWeiboInstalled {
    return [WeiboSDK isWeiboAppInstalled];
}

/**
 *  分享到微博平台
 *
 *  @param shareContent 分享的内容
 *  @param completionBlock       分享的回调
 *  @param authCompletionBlock   认证的回调
 */
+ (void)shareToWeiboWithShareContent:(XMNShareContent *)shareContent completionBlock:(void(^)(XMNShareContent *shareContent, NSError *error))completionBlock authCompletionBlock:(void(^)(id responseObject, NSError *error))authCompletionBlock {
    if (![self canShareWithPlatform:kXMNWeiboPlatform]) {
        NSLog(@"you should you '+ (void)connectWeiboWithAPPKey:(NSString *)appKey redirectURI:(NSString *)redirectURI' method to register weibo");
        return;
    }
    if ((shareContent.contentType == XMNShareContentTypeAudio ||shareContent.contentType == XMNShareContentTypeNews ||shareContent.contentType == XMNShareContentTypeVideo) && ![self isWeiboInstalled]) {
        completionBlock ? completionBlock(shareContent, [NSError errorWithDomain:kXMNWeiboPlatform code:-1 userInfo:@{@"errormsg":@"未安装微博客户端,无法分享当前内容"}]) : nil;
        return;
    }
    
    [XMNWeiboManager shareManager].authCompletionBlock = authCompletionBlock;
    [XMNWeiboManager shareManager].shareCompletionBlock = completionBlock;
    [XMNWeiboManager shareManager].shareContent = shareContent;
    NSDictionary *platfromConfiguration = [self platformConfigurationForPlatform:kXMNWeiboPlatform];
    NSDictionary *authInfo = [self authInfoForPlatform:kXMNWeiboPlatform];
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = platfromConfiguration[kXMNThirdCallbackKey];
    authRequest.scope = @"all";
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:[self _generateWBMessage:shareContent] authInfo:authRequest access_token:authInfo[@"access_token"]];
    request.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
    [WeiboSDK sendRequest:request];
}

+ (void)authWeiboWithCompletionBlock:(void(^)(id responseObject, NSError *error))completionBlock {
    if ([self canAuthWithPlatform:kXMNWeiboPlatform]) {
        [XMNWeiboManager shareManager].authCompletionBlock = completionBlock;
        NSDictionary *platfromConfiguration = [self platformConfigurationForPlatform:kXMNWeiboPlatform];
        WBAuthorizeRequest *request = [WBAuthorizeRequest request];
        request.redirectURI = platfromConfiguration[kXMNThirdCallbackKey];
        request.scope = @"all";
        [WeiboSDK sendRequest:request];
    }else {
        NSLog(@"you should you '+ (void)connectWeiboWithAPPKey:(NSString *)appKey redirectURI:(NSString *)redirectURI' method to register weibo");
    }
    
}


+ (void)requestWeiboUserInfoWithCompletionBlock:(void(^)(WeiboUser *userInfo,NSError *error))completionBlock {
    NSInteger errcode = -1000;
    NSString *errmsg = @"获取微博用户信息失败";
    NSMutableDictionary *authInfo = [NSMutableDictionary dictionaryWithDictionary:[self authInfoForPlatform:kXMNWeiboPlatform]];
    if (![self hasAuthorized:kXMNWeiboPlatform]) {
        completionBlock ? completionBlock(nil,[NSError errorWithDomain:kXMNWeiboPlatform code:errcode userInfo:@{@"errorMsg":[errmsg stringByAppendingString:@",用户未登录"]}]) : nil;
        return;
    }
    //刷新下token
    [WBHttpRequest requestForRenewAccessTokenWithRefreshToken:authInfo[kXMNAuthRefreshTokenKey] queue:[[NSOperationQueue alloc] init] withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
        if (error) {
            //刷新token出错,让用户登出
            [self cancelAuthorize:kXMNWeiboPlatform];
            completionBlock ? completionBlock(nil, error) : nil;
        }else {
            authInfo[kXMNAuthUserIDKey] = result[@"uid"];
            authInfo[kXMNAuthTokenKey] = result[@"access_token"];
            authInfo[kXMNAuthRefreshTokenKey] = result[@"refresh_token"];
            [self saveAuthInfo:authInfo forPlatform:kXMNWeiboPlatform];
            //刷新token成功,保存新的token,获取用户数据
            [WBHttpRequest requestForUserProfile:authInfo[kXMNAuthUserIDKey] withAccessToken:authInfo[kXMNAuthTokenKey] andOtherProperties:nil queue:[NSOperationQueue mainQueue] withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
                if (error) {
                    completionBlock ? completionBlock(nil,error) : nil;
                }else {
                    completionBlock ? completionBlock(result, nil) : nil;
                }
            }];
        }
    }];
}

+ (BOOL)wb_handleOpenURL:(NSURL *)openURL {
    return [WeiboSDK handleOpenURL:openURL delegate:[XMNWeiboManager shareManager]];
}

+ (WBMessageObject *)_generateWBMessage:(XMNShareContent *)shareContent {
    WBMessageObject *message = [WBMessageObject message];
    switch (shareContent.contentType) {
        case XMNShareContentTypeText:
            message.text = shareContent.desc;
            break;
        case XMNShareContentTypeImage:
        {
            WBImageObject *imageObject = [WBImageObject object];
            imageObject.imageData = [self dataWithImage:shareContent.image];
            message.text = shareContent.desc ? : shareContent.title;
            message.imageObject = imageObject;
            break;
        }
        case XMNShareContentTypeNews:
        {
            WBWebpageObject *webpage = [WBWebpageObject object];
            webpage.title = shareContent.title;
            webpage.description = shareContent.desc;
            webpage.thumbnailData = shareContent.thumbnail ? [self dataWithImage:shareContent.thumbnail] : [self dataWithImage:shareContent.image scale:CGSizeMake(100, 100)];
            webpage.webpageUrl = shareContent.link;
            webpage.objectID = shareContent.objectID;
            message.mediaObject = webpage;
            break;
        }
        case XMNShareContentTypeAudio:
        {
            WBMusicObject *musicObject = [WBMusicObject object];
            musicObject.title = shareContent.title;
            musicObject.description = shareContent.desc;
            musicObject.thumbnailData = shareContent.thumbnail ? [self dataWithImage:shareContent.thumbnail] : [self dataWithImage:shareContent.image scale:CGSizeMake(100, 100)];
            musicObject.musicUrl = shareContent.link;
            musicObject.musicUrl = shareContent.mediaUrl;
            musicObject.objectID = shareContent.objectID;
            message.mediaObject = musicObject;
            message.text = shareContent.desc ? : shareContent.title;
            break;
        }
        case XMNShareContentTypeVideo:
        {
            WBVideoObject *videoObject = [WBVideoObject object];
            videoObject.title = shareContent.title;
            videoObject.description = shareContent.desc;
            videoObject.thumbnailData = shareContent.thumbnail ? [self dataWithImage:shareContent.thumbnail] : [self dataWithImage:shareContent.image scale:CGSizeMake(100, 100)];
            videoObject.videoUrl = shareContent.link;
            videoObject.videoStreamUrl = shareContent.mediaUrl;
            videoObject.objectID = shareContent.objectID;
            message.mediaObject = videoObject;
            message.text = shareContent.desc ? : shareContent.title;
            break;
        }
        default:
            NSLog(@"微博分享不支持 :%ld 类型",shareContent.contentType);
            break;
    }
    
    return message;
}


@end
