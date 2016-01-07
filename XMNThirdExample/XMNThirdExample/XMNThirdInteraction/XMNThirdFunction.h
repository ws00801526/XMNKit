//
//  XMNThridFunction.h
//  XMNThirdExample
//
//  Created by XMFraker on 16/1/4.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const kXMNThirdAPPIDKey;
FOUNDATION_EXPORT NSString *const kXMNThirdAPPSecretKey;
FOUNDATION_EXPORT NSString *const kXMNThirdCallbackKey;


/** 微信专用保存授权code的key */
FOUNDATION_EXPORT NSString *const kXMNAuthCodeKey;
/** 保存授权token的key */
FOUNDATION_EXPORT NSString *const kXMNAuthTokenKey;
/** 保存授权刷新token的key */
FOUNDATION_EXPORT NSString *const kXMNAuthRefreshTokenKey;
/** 保存授权用户id的key */
FOUNDATION_EXPORT NSString *const kXMNAuthUserIDKey;


FOUNDATION_EXPORT NSString *const kXMNWeChatPlatform;
FOUNDATION_EXPORT NSString *const kXMNWeiboPlatform;
FOUNDATION_EXPORT NSString *const kXMNQQPlatform;

#define kXMNError(domain,code,errorMsg) ([NSError errorWithDomain:domain code:code userInfo:@{@"errorMsg":errorMsg}])


/** 分享内容的类型 */
typedef NS_ENUM(NSUInteger, XMNShareContentType) {
    /** 未知的分享内容 */
    XMNShareContentTypeUnknow = 0,
    /** 分享纯文本内容 */
    XMNShareContentTypeText,
    /** 分享图片内容 */
    XMNShareContentTypeImage,
    /** 分享表情 */
    XMNShareContentTypeEmotion,
    /** 分享新闻类型内容 */
    XMNShareContentTypeNews,
    /** 分享音频内容 */
    XMNShareContentTypeAudio,
    /** 分享视频内容 */
    XMNShareContentTypeVideo,
    /** 分享app */
    XMNShareContentTypeeApp,
    /** fen'x */
    XMNShareContentTypeFile
};



@interface XMNShareContent : NSObject

@property (nonatomic, copy)   NSString *title;
@property (nonatomic, copy)   NSString *desc;

/** 分享的链接地址,当分享微博Video时不能为空 */
@property (nonatomic, copy)   NSString *link;


/** 分享的图片 */
@property (nonatomic, strong) UIImage  *image;
/** 分享的图片地址,分享图片时 image,imageUrl不能同时为空 */
@property (nonatomic, copy)   NSString  *imageUrl;

/** 分享的缩略图,如果无则用image->制作100x100的缩略图 */
@property (nonatomic, strong) UIImage  *thumbnail;
@property (nonatomic, assign) XMNShareContentType contentType;


/// ========================================
/// @name   QQ分享需要的特殊参数
/// ========================================

/** QQ分享到收藏的时候可以分享多张图片 */
@property (nonatomic, copy)   NSArray *images;



/// ========================================
/// @name   微博特需的分享参数
/// ========================================

/** 分享微博多媒体消息时的唯一ID,不能为空 */
@property (nonatomic, copy)   NSString *objectID;


/// ========================================
/// @name   微信相关配置参数
/// ========================================

/** 微信分享app时,额外信息参数 */
@property (nonatomic, copy)   NSString *extInfo;
/** 微信分享Video,Music地址 */
@property (nonatomic, copy)   NSString *mediaUrl;
/** 微信分享文件时使用,文件的后缀名 */
@property (nonatomic, copy)   NSString *fileExt;
/** 微信分享文件,app文件,gif文件等 */
@property (nonatomic, copy)   NSData   *file;


- (BOOL)emptyValuesForKeys:(NSArray *)emptyKeys notEmptyValuesForKeys:(NSArray *)notEmptyKeys;
@end


typedef void(^XMNShareCompletionBlock)(XMNShareContent *shareContent,NSError *error);
typedef void(^XMNAuthCompletionBlock)(id responseObject,NSError *error);


@interface XMNThirdFunction : NSObject


#pragma mark - Properties

/** 保存配置过的平台配置信息,appkey,appSecret,callBack等 */
@property (nonatomic, strong) NSMutableDictionary *appConfiguration;

+ (instancetype)shareFunction;

/// ========================================
/// @name   configure Methods
/// ========================================

/**
 *  配置platformConfiguration
 *  存储在单例share的appConfiguration中
 *  @param platformConfiguration 存储AppID,AppScreat,AppCallBack等信息
 *  @param platform              存储对应的平台key
 */
+ (void)setPlatformConfiguration:(NSDictionary *)platformConfiguration forPlatform:(NSString *)platform;

/**
 *  获取对应平台的配置信息
 *
 *  @param paltform 对应平台的key
 *
 *  @return 存储的对应平台配置信息
 */
+ (NSDictionary *)platformConfigurationForPlatform:(NSString *)paltform;

/**
 *  判断平台可否被分享
 *  主要查看是否配置了对应平台的配置信息
 *  @param platform          平台key
 *
 *  @return 是否可以分享  YES NO
 */
+ (BOOL)canShareWithPlatform:(NSString *)platform;

/**
 *  判断平台可否使用登录功能
 *
 *  @param platform         平台key
 *
 *  @return 是否可以登录 YES NO
 */
+ (BOOL)canAuthWithPlatform:(NSString *)platform;

/**
 *  处理UIApplication 中openURL回调
 *  在此方法中,会将URL分发给每个category进行处理,知道返回YES,否则返回为NO
 *  @param URL 需要处理URL
 *
 *  @return 是否可以处理
 */
+ (BOOL)handleOpenURL:(NSURL *)URL;

/**
 *  获取对应平台的授权信息,如果用户授权,则存储起授权信息
 *
 *  @param platform 对应的授权平台
 *
 *  @return 授权平台授权的信息  或者 nil
 */
+ (NSDictionary *)authInfoForPlatform:(NSString *)platform;

/**
 *  保存对应平台的授权信息
 *
 *  @param authInfo 授权信息 或者 nil,nil时删除已有授权信息
 *  @param platform 对应的授权平台
 *
 *  @return 是否保存成功
 */
+ (BOOL)saveAuthInfo:(NSDictionary *)authInfo forPlatform:(NSString *)platform;


/**
 *  取消分享平台授权
 *
 *  @param platformType  平台类型
 */
+ (void)cancelAuthorize:(NSString *)platform;

/**
 *  判断分享平台是否授权
 *
 *  @param platformType 平台类型
 *  @return YES 表示已授权，NO 表示尚未授权
 */
+ (BOOL)hasAuthorized:(NSString *)platform;

@end
