//
//  XMNShare.h
//  XMNShareExample
//
//  Created by ChenMaolei on 15/12/29.
//  Copyright © 2015年 XMFraker. All rights reserved.
//


#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString *const kXMNThirdAPPIDKey;
FOUNDATION_EXPORT NSString *const kXMNShareAPPSecreatKey;
FOUNDATION_EXPORT NSString *const kXMNThirdCallbackKey;

/** 分享内容的类型 */
typedef NS_ENUM(NSUInteger, XMNShareContentType) {
    /** 未知的分享内容 */
    XMNShareContentTypeUnknow,
    /** 分享纯文本内容 */
    XMNShareContentTypeText,
    /** 分享图片内容 */
    XMNShareContentTypeImage,
    /** 分享gif */
    XMNShareContentTypeGif,
    /** 分享新闻类型内容 */
    XMNShareContentTypeNews,
    /** 分享音频内容 */
    XMNShareContentTypeAudio,
    /** 分享视频内容 */
    XMNShareContentTypeVideo,
    /** 分享app */
    XMNShareContentTypeApp,
    /** fen'x */
    XMNShareContentTypeFile
};


/**
 粘贴板数据编码方式，目前只有两种:
 1. [NSKeyedArchiver archivedDataWithRootObject:data];
 2. [NSPropertyListSerialization dataWithPropertyList:data format:NSPropertyListBinaryFormat_v1_0 options:0 error:&err];
 */
typedef enum : NSUInteger {
    /** 使用keyArchiver归档数据 */
    XMNPboardEncodingKeyedArchiver,
    /** 使用propertyList归档数据 */
    XMNPboardEncodingPropertyListSerialization,
} XMNPboardEncoding;


@interface XMNShareContent : NSObject

@property (nonatomic, copy)   NSString *title;
@property (nonatomic, copy)   NSString *desc;
@property (nonatomic, copy)   NSString *link;
@property (nonatomic, strong) UIImage  *image;
@property (nonatomic, strong) UIImage  *thumbnail;
@property (nonatomic, assign) XMNShareContentType contentType;

/// ========================================
/// @name   微信相关配置参数
/// ========================================
@property (nonatomic, copy)   NSString *extInfo;

/** Video,Music地址 */
@property (nonatomic, copy)   NSString *mediaUrl;
@property (nonatomic, copy)   NSString *fileExt;
/** 微信分享文件 gif 等 */
@property (nonatomic, copy)   NSData   *file;

- (BOOL)emptyValuesForKeys:(NSArray *)emptyKeys notEmptyValuesForKeys:(NSArray *)notEmptyKeys;
@end

@interface XMNShare : NSObject


#pragma mark - Properties

@property (nonatomic, strong) NSMutableDictionary *appConfiguration;

@property (nonatomic, copy)   void(^shareSuccessBlock)(XMNShareContent *shareContent);
@property (nonatomic, copy)   void(^shareFailBlock)(XMNShareContent *shareContent, NSError *error);
@property (nonatomic, copy)   void(^authSuccessBlock)(NSDictionary *responseObject);
@property (nonatomic, copy)   void(^authFailBlock)(NSDictionary *responseObject, NSError *error);

@property (nonatomic, strong) XMNShareContent *shareContent;
@property (nonatomic, strong) NSURL *returnURL;


#pragma mark - Methods

/// ========================================
/// @name   Life Cycle Methods
/// ========================================

+ (instancetype)share;

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


+ (void)openURLString:(NSString *)URLString;
/**
 *  判断URLString是否能被打开
 *  主要用来判断app是否被安装
 *  @param URLString 需要被打开的URLString
 *
 *  @return 是否可以打开 YES NO
 */
+ (BOOL)canOpenURLString:(NSString *)URLString;


/**
 *  判断平台可否被分享
 *  主要查看是否配置了对应平台的配置信息
 *  @param platform          平台key
 *  @param shareContent      需要分享的内容,此时将此内容存储到XMNShare单例中
 *  @param shareSuccessBlock 分享成功的回调,此时将block存储到XMNShare单例中
 *  @param shareFailBlock    分享失败的回调,此时将block存储到XMNShare单例中
 *
 *  @return 是否可以分享  YES NO
 */
+ (BOOL)canShareWithPlatform:(NSString *)platform shareContent:(XMNShareContent *)shareContent shareSuccessBlock:(void(^)(XMNShareContent *shareContent))shareSuccessBlock shareFailBlock:(void(^)(XMNShareContent *shareContent, NSError *error))shareFailBlock;

/**
 *  判断平台可否使用登录功能
 *
 *  @param platform         平台key
 *  @param authSuccessBlock 授权成功的回调,此时将block存储到XMNShare单例中
 *  @param authFailBlock    授权失败的回调,此时将block存储到XMNShare单例中
 *
 *  @return 是否可以登录 YES NO
 */
+ (BOOL)canAuthWithPlatform:(NSString *)platform authSuccessBlock:(void(^)(NSDictionary *responseObject))authSuccessBlock authFailBlock:(void(^)(NSDictionary *responseObject, NSError *error))authFailBlock;

/**
 *  处理UIApplication 中openURL回调
 *  在此方法中,会将URL分发给每个category进行处理,知道返回YES,否则返回为NO
 *  @param URL 需要处理URL
 *
 *  @return 是否可以处理
 */
+ (BOOL)handleOpenURL:(NSURL *)URL;


@end
