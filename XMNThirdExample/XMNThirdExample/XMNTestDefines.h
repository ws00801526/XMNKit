//
//  XMNTestDefines.h
//  XMNThirdExample
//
//  Created by XMFraker on 16/1/5.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#ifndef XMNTestDefines_h
#define XMNTestDefines_h


#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]

#define TIPSLABEL_TAG 10086
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define BUFFER_SIZE 1024 * 100

static const int kHeadViewHeight = 135;
static const int kSceneViewHeight = 100;

static NSString *kTextMessage = @"人文的东西并不是体现在你看得到的方面，它更多的体现在你看不到的那些方面，它会影响每一个功能，这才是最本质的。但是，对这点可能很多人没有思考过，以为人文的东西就是我们搞一个很小清新的图片什么的。”综合来看，人文的东西其实是贯穿整个产品的脉络，或者说是它的灵魂所在。";

static NSString *kImageTagName = @"WECHAT_TAG_JUMP_APP";
static NSString *kMessageExt = @"这是第三方带的测试字段";
static NSString *kMessageAction = @"<action>dotalist</action>";

static NSString *kLinkURL = @"http://tech.qq.com/zt2012/tmtdecode/252.htm";
static NSString *kLinkTagName = @"WECHAT_TAG_JUMP_SHOWRANK";
static NSString *kLinkTitle = @"专访张小龙：产品之上的世界观";
static NSString *kLinkDescription = @"微信的平台化发展方向是否真的会让这个原本简洁的产品变得臃肿？在国际化发展方向上，微信面临的问题真的是文化差异壁垒吗？腾讯高级副总裁、微信产品负责人张小龙给出了自己的回复。";

static NSString *kMusicURL = @"http://mp3.baidu.com";
static NSString *kMusicDataURL = @"http://stream20.qqmusic.qq.com/32464723.mp3";
static NSString *kMusicTitle = @"一无所有";
static NSString *kMusicDescription = @"崔健";

static NSString *kVideoURL = @"http://v.youku.com/v_show/id_XNTUxNDY1NDY4.html";
static NSString *kVideoTitle = @"乔布斯访谈";
static NSString *kVideoDescription = @"饿着肚皮，傻逼着。";

static NSString *kAPPContentTitle = @"App消息";
static NSString *kAPPContentDescription = @"这种消息只有App自己才能理解，由App指定打开方式";
static NSString *kAppContentExInfo = @"<xml>extend info</xml>";
static NSString *kAppContnetExURL = @"http://weixin.qq.com";
static NSString *kAppMessageExt = @"这是第三方带的测试字段";
static NSString *kAppMessageAction = @"<action>dotaliTest</action>";

static NSString *kAuthScope = @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact";
static NSString *kAuthOpenID = @"0c806938e2413ce73eef92cc3";
static NSString *kAuthState = @"xxx";

static NSString *kFileTitle = @"iphone4.pdf";
static NSString *kFileDescription = @"Pro CoreData";
static NSString *kFileExtension = @"pdf";
static NSString *kFileName = @"iphone4";

static const NSInteger kRecvGetMessageReqAlertTag = 1000;
static const NSInteger kProfileAppIdAlertTag = 2000;
static const NSInteger kProfileUserNameAlertTag = 3000;
static const NSInteger kBizWebviewAppIdAlerttag = 4000;
static const NSInteger kBizWebviewTousernameAlertTag = 6000;

static NSString *kProfileExtMsg = @"http://we.qq.com/d/AQCIc9a3EqRfb19z8WnLB6iFNCxX5bO2S3lHwMQL";
static NSString *kBizWebviewExtMsg = @"KOoCKdavezBjdj2wJZsq67N2j_g3XEQ5JP_pkLhBYS4";

static NSString *kShareText = @"测试分享文本";
static NSString *kShareImage = @"测试分享图片";
static NSString *kShareMusic = @"测试分享音乐";
static NSString *kShareVideo = @"测试分享视频";
static NSString *kShareNews = @"测试分享新闻";
static NSString *kShareFile = @"测试分享文件";
static NSString *kShareApp = @"测试分享app";
static NSString *kShareEmotion = @"测试分享表情";
static NSString *kShareLogin = @"测试登录";
static NSString *kShareLoginOut = @"测试登出";
static NSString *kSharePay = @"测试支付";



#endif /* XMNTestDefines_h */
