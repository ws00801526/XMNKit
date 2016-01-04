//
//  XMNShare+Supports.h
//  XMNShareExample
//
//  Created by ChenMaolei on 15/12/30.
//  Copyright © 2015年 XMFraker. All rights reserved.
//

#import "XMNShare.h"


/// ========================================
/// @name   公用类方法,提供写公用功能
/// ========================================


@interface XMNShare (Supports)

/**
*  将UIImage转成NSData
*  使用UIImageJPEGRepresentation转换
*  @param image 需要转换的UIImage
*
*  @return 转换后的NSData 或者 nil
*/
+ (NSData *)dataWithImage:(UIImage *)image;


/**
 *  将UIImage按照给定只存进行裁剪后转换成NSData
 *
 *  @param image 需要转换的UIImage
 *  @param size  UIImage目标大小
 *
 *  @return 转换后的NSData 或者 nil
 */
+ (NSData *)dataWithImage:(UIImage *)image scale:(CGSize)size;

/**
 *  解析URL
 *  解析get类型URLString  将参数按照键值对解析出来
 *  @param url 需要解析的URL
 *
 *  @return 返回解析的URL参数
 */
+ (NSMutableDictionary *)parseUrl:(NSURL*)url;

/**
 *  使用Base64加密字符串
 *
 *  @param input 需要加密的字符串
 *
 *  @return 加密后的字符串
 */
+(NSString*)base64Encode:(NSString *)input;

/**
 *  使用Base64解密字符串
 *
 *  @param input 需要解密的字符串
 *
 *  @return 解密后的字符串
 */
+(NSString*)base64Decode:(NSString *)input;

/**
 *  APP bundle 名称
 *
 *  @return app 名称
 */
+(NSString*)CFBundleDisplayName;

/**
 *  APP identifier
 *
 *  @return app identifier
 */
+(NSString*)CFBundleIdentifier;

/**
 *  将key value 赋值到黏贴板,方便打开的支付宝,微信等调用
 *
 *  @param key      key
 *  @param value    key对应的value
 *  @param encoding 编码方式
 */
+(void)setGeneralPasteboard:(NSString*)key Value:(NSDictionary*)value encoding:(XMNPboardEncoding)encoding;

/**
 *  从剪贴板中获取key对应的value
 *
 *  @param key      对应的key
 *  @param encoding 编码方式
 *
 *  @return 获取到的value
 */
+ (NSDictionary *)generalPasteboardData:(NSString*)key encoding:(XMNPboardEncoding)encoding;

/**
 *  对string进行url编码,然后使用base64加密
 *
 *  @param string 需要进行转换的字符串
 *
 *  @return 转换后的字符串
 */
+ (NSString *)urlEncodeAfterBase64:(NSString *)string;

/**
 *  对字符串进行url解码
 *  此处仅仅替换了+号
 *  @param input 需要解码的字符串
 *
 *  @return 解码后的字符串
 */
+ (NSString *)urlDecode:(NSString*)input;
@end
