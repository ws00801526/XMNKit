//
//  XMNShare+WeChat.m
//  XMNShareExample
//
//  Created by ChenMaolei on 15/12/30.
//  Copyright © 2015年 XMFraker. All rights reserved.
//

#import "XMNShare+WeChat.h"
#import "XMNShare+Supports.h"

#define kXMNWeChatPlatform   @"wx"
#define kXMNWeChatSDKVersion @"2.0"

@implementation XMNShare (WeChat)

+ (void)connectWeChatWithAPPID:(NSString *)appID {
    [self setPlatformConfiguration:@{kXMNShareAPPIDKey:appID} forPlatform:kXMNWeChatPlatform];
}

+ (BOOL)isWeChatInstalled {
    return [self canOpenURLString:@"wechat://"];
}

+ (void)shareToWeChatWithShareContent:(XMNShareContent *)shareContent type:(XMNShareWechatType)type successBlock:(void (^)(XMNShareContent *))successBlock failBlock:(void (^)(XMNShareContent *, NSError *))failBlock {
    if ([self canShareWithPlatform:kXMNWeChatPlatform shareContent:shareContent shareSuccessBlock:successBlock shareFailBlock:failBlock]) {
        [self openURLString:[self _generateWeChatShareURLWithShareContent:shareContent shareType:type]];
    }
}

+ (void)authWeChatWithScope:(NSString *)scope successBlock:(void (^)(NSDictionary *))successBlock failBlock:(void (^)(NSDictionary *, NSError *))failBlock {
    if ([self canAuthWithPlatform:kXMNWeChatPlatform authSuccessBlock:successBlock authFailBlock:failBlock]) {
        [self openURLString:[NSString stringWithFormat:@"weixin://app/%@/auth/?scope=%@&state=Weixinauth",[self platformConfigurationForPlatform:kXMNWeChatPlatform][kXMNShareAPPIDKey],scope]];
    }
}

+ (NSString *)_generateWeChatShareURLWithShareContent:(XMNShareContent *)shareContent shareType:(XMNShareWechatType)shareType {
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] initWithDictionary:@{@"result":@"1",@"returnFromApp" :@"0",@"scene" : [NSString stringWithFormat:@"%ld",shareType],@"sdkver" : kXMNWeChatSDKVersion,@"command" : @"1010"}];
    switch ([self _weChatShareContentTypeForShareContent:shareContent]) {
        case XMNShareContentTypeText:
            //文本
            dic[@"command"] = @"1020";
            dic[@"title"] = shareContent.title;
            break;
        case XMNShareContentTypeImage:
            //图片
            dic[@"title"] = shareContent.title?:@"";
            dic[@"fileData"] = [self dataWithImage:shareContent.image];
            dic[@"thumbData"] = shareContent.thumbnail ? [self dataWithImage:shareContent.thumbnail] : [self dataWithImage:shareContent.image scale:CGSizeMake(100, 100)];
            dic[@"objectType"]=@"2";
            break;
        case XMNShareContentTypeNews:
            //有链接。
            dic[@"description"]=shareContent.desc?:shareContent.title;
            dic[@"mediaUrl"]=shareContent.link;
            dic[@"objectType"]=@"5";
            dic[@"thumbData"]=shareContent.thumbnail? [self dataWithImage:shareContent.thumbnail]:[self dataWithImage:shareContent.image scale:CGSizeMake(100, 100)];
            dic[@"title"] =shareContent.title;
            break;
        case XMNShareContentTypeGif:
            //gif
            dic[@"fileData"]= shareContent.file ? shareContent.file : [self dataWithImage:shareContent.image];
            dic[@"thumbData"]=shareContent.thumbnail ? [self dataWithImage:shareContent.thumbnail] : [self dataWithImage:shareContent.image scale:CGSizeMake(100, 100)];
            dic[@"objectType"]=@"8";
            break;
        case XMNShareContentTypeAudio:
            //music
            dic[@"description"]=shareContent.desc?:shareContent.title;
            dic[@"mediaUrl"]=shareContent.link;
            dic[@"mediaDataUrl"]=shareContent.mediaUrl;
            dic[@"objectType"]=@"3";
            dic[@"thumbData"]=shareContent.thumbnail? [self dataWithImage:shareContent.thumbnail]:[self dataWithImage:shareContent.image scale:CGSizeMake(100, 100)];;
            dic[@"title"] =shareContent.title;
            break;
        case XMNShareContentTypeVideo:
            //video
            dic[@"description"]=shareContent.desc?:shareContent.title;
            dic[@"mediaUrl"]=shareContent.link;
            dic[@"objectType"]=@"4";
            dic[@"thumbData"]=shareContent.thumbnail? [self dataWithImage:shareContent.thumbnail]:[self dataWithImage:shareContent.image scale:CGSizeMake(100, 100)];;
            dic[@"title"] =shareContent.title;
            break;
        case XMNShareContentTypeeApp:
            //app
            dic[@"description"]=shareContent.desc?:shareContent.title;
            if(shareContent.extInfo)dic[@"extInfo"]=shareContent.extInfo;
            dic[@"fileData"]=[self dataWithImage:shareContent.image];
            dic[@"mediaUrl"]=shareContent.link;
            dic[@"objectType"]=@"7";
            dic[@"thumbData"]=shareContent.thumbnail? [self dataWithImage:shareContent.thumbnail]:[self dataWithImage:shareContent.image scale:CGSizeMake(100, 100)];;
            dic[@"title"] =shareContent.title;
            break;
        case XMNShareContentTypeFile:
            //file
            dic[@"description"]=shareContent.desc?:shareContent.title;
            dic[@"fileData"]=shareContent.file;
            dic[@"objectType"]=@"6";
            dic[@"fileExt"]=shareContent.fileExt?:@"";
            dic[@"thumbData"]=shareContent.thumbnail? [self dataWithImage:shareContent.thumbnail]:[self dataWithImage:shareContent.image scale:CGSizeMake(100, 100)];;
            dic[@"title"] =shareContent.title;
            break;
        default:
            break;
    }
    NSData *output=[NSPropertyListSerialization dataWithPropertyList:@{[self platformConfigurationForPlatform:kXMNWeChatPlatform][kXMNShareAPPIDKey]:dic} format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
    [[UIPasteboard generalPasteboard] setData:output forPasteboardType:@"content"];
    return [NSString stringWithFormat:@"weixin://app/%@/sendreq/?",[self platformConfigurationForPlatform:kXMNWeChatPlatform][kXMNShareAPPIDKey]];
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
            return XMNShareContentTypeGif;
        }
    }
    return shareContent.contentType;
}


+(BOOL)wx_handleOpenURL{
    NSURL* url = [[XMNShare share] returnURL];
    if ([url.scheme hasPrefix:@"wx"]) {
        NSDictionary *retDic=[NSPropertyListSerialization propertyListWithData:[[UIPasteboard generalPasteboard] dataForPasteboardType:@"content"]?:[[NSData alloc] init] options:0 format:0 error:nil][[self platformConfigurationForPlatform:kXMNWeChatPlatform][kXMNShareAPPIDKey]];
        NSLog(@"retDic\n%@",retDic);
        if ([url.absoluteString rangeOfString:@"://oauth"].location != NSNotFound) {
            //login succcess
            [XMNShare share].authSuccessBlock ? [XMNShare share].authSuccessBlock([self parseUrl:url]) : nil;
        }else if([url.absoluteString rangeOfString:@"://pay/"].location != NSNotFound){
            //TODO 此处处理支付会掉
        }else{
            if (retDic[@"state"]&&[retDic[@"state"] isEqualToString:@"Weixinauth"]&&[retDic[@"result"] intValue]!=0) {
                //登录失败
                [XMNShare share].authFailBlock ? [XMNShare share].authFailBlock(retDic,[NSError errorWithDomain:@"WeChat_Auth" code:[retDic[@"result"] intValue] userInfo:retDic]) : nil;
            }else if([retDic[@"result"] intValue]==0){
                [XMNShare share].shareSuccessBlock ? [XMNShare share].shareSuccessBlock([XMNShare share].shareContent) : nil;
            }else{
                [XMNShare share].shareFailBlock ? [XMNShare share].shareFailBlock([XMNShare share].shareContent, [NSError errorWithDomain:@"WeChat_Share" code:[retDic[@"result"] integerValue] userInfo:retDic]) : nil;
            }
        }
        return YES;
    }else{
        return NO;
    }
}


@end
