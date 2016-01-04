//
//  NSString+AESCryptor.h
//  iYunBao
//  将字符串进行AES加密
//  Created by XMFraker on 16/1/4.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (AESCryptor)

/**
 *  将一串字符串进行AES加密
 *  
 *  @param message  需要加密的字符串  message -> NSUTF8StringEncoding -> NSData
 *  @param password 加密密码 password->NSUTF8StringEncoding->NSData->SHA256Hash->NSData
 *
 *  @return 加密后的字符串
 */
+ (NSString *)encrypt:(NSString *)message password:(NSString *)password;

/**
 *  将一串AES加密后的字符串进行解密
 *
 *  @param base64EncodedString 加密后字符串 base64编码
 *  @param password            加密的密码
 *
 *  @return 解密后字符串
 */
+ (NSString *)decrypt:(NSString *)base64EncodedString password:(NSString *)password;

@end
