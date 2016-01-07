//
//  ViewController.m
//  XMNThirdExample
//
//  Created by XMFraker on 16/1/4.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "ViewController.h"

#import "WXApi.h"
#import "XMNTestDefines.h"

#import "XMNThridFunction+WeChat.h"
#import "XMNThirdFunction+Weibo.h"
#import "XMNThirdFunction+QQ.h"
#import "UIControl+Blocks.h"


@interface ViewController () <UIScrollViewDelegate,WXApiDelegate>

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak)   UISegmentedControl *segmentControl;

@property (nonatomic, assign) NSUInteger weChatScene;
@property (nonatomic, assign) NSInteger qqSence;


@property (nonatomic, copy)   NSDictionary *typeDict;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.weChatScene = XMNShareWechatTypeSession;
    self.qqSence = XMNShareQQTypeFriend;
    
    UISegmentedControl *segmentControl = [[UISegmentedControl alloc] initWithItems:@[@"微信",@"微博",@"QQ"]];
    segmentControl.center = CGPointMake(self.view.frame.size.width/2, 60);
    segmentControl.selectedSegmentIndex = 0;
    [segmentControl addEventHandler:^(UISegmentedControl *sender) {
        [self.scrollView setContentOffset:CGPointMake(self.view.frame.size.width * sender.selectedSegmentIndex, 0)];
    } forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:self.segmentControl = segmentControl];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height - 100)];
    scrollView.delegate = self;
    scrollView.userInteractionEnabled = YES;
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.scrollView = scrollView];
    [self.scrollView setContentSize:CGSizeMake(SCREEN_WIDTH * 3, self.scrollView.frame.size.height)];
    [scrollView addSubview:[self weChatView]];
    [scrollView addSubview:[self weiboView]];
    [scrollView addSubview:[self qqView]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.segmentControl.selectedSegmentIndex = scrollView.contentOffset.x / SCREEN_WIDTH;
}


#pragma mark - Methods

/**
 *  处理微信相关动作
 *  分享相关动作测试通过
 *  获取用户信息未测试
 */
- (void)_handleWeChatAction:(UIButton *)button {
    if (button.tag == XMNShareContentTypeFile + 1) {
        
        if ([XMNThirdFunction hasAuthorized:kXMNWeChatPlatform]) {
            [XMNThirdFunction requestWeChatUserInfoWithCompletionBlock:^(NSDictionary *responseObject, NSError *error) {
                [self _handleAuthAlert:responseObject error:error];
            }];
        }else {
            [XMNThirdFunction authWeChatInController:self withDelegate:nil completionBlock:^(NSDictionary *responseObject, NSError *error) {
                [self _handleAuthAlert:responseObject error:error];
            }];
        }
    }else if (button.tag == XMNShareContentTypeFile + 2){
        [XMNThirdFunction cancelAuthorize:kXMNWeChatPlatform];
    }else {
        XMNShareContent *content = [self shareContentWithType:button.tag];
        [XMNThirdFunction shareToWeChatWithShareContent:content type:self.weChatScene completionBlock:^(XMNShareContent *shareContent, NSError *error) {
            [self _handleShareAlert:shareContent error:error];
        }];
    }
    
}


/**
 *  处理微博相关动作
 *  测试全部通过
 */
- (void)_handleWeiboAction:(UIButton *)button {
    if (button.tag == XMNShareContentTypeFile + 1) {
        if ([XMNThirdFunction hasAuthorized:kXMNWeiboPlatform]) {
            [XMNThirdFunction requestWeiboUserInfoWithCompletionBlock:^(WeiboUser *userInfo, NSError *error) {
                [self _handleAuthAlert:userInfo error:error];
            }];
        }else {
            [XMNThirdFunction authWeiboWithCompletionBlock:^(id responseObject, NSError *error) {
                NSLog(@"auth succes ?%@",error);
                if (!error) {
                    [XMNThirdFunction requestWeiboUserInfoWithCompletionBlock:^(WeiboUser *userInfo, NSError *error) {
                        [self _handleAuthAlert:userInfo error:error];
                    }];
                }
            }];
        }
    }else if (button.tag == XMNShareContentTypeFile + 2){
        [XMNThirdFunction cancelAuthorize:kXMNWeiboPlatform];
    }else {
        XMNShareContent *content = [self shareContentWithType:button.tag];
        [XMNThirdFunction shareToWeiboWithShareContent:content completionBlock:^(XMNShareContent *shareContent, NSError *error) {
            [self _handleShareAlert:shareContent error:error];
        } authCompletionBlock:^(id responseObject, NSError *error) {
            [self _handleAuthAlert:responseObject error:error];
        }];
    }
}


/**
 *  处理QQ的相关操作
 *  测试基本都通过了,QQ文件分享无法大于5MB 所以调用不起来
 *
 */
- (void)_handleQQAction:(UIButton *)button {
    if (button.tag == XMNShareContentTypeFile + 1) {
        if ([XMNThirdFunction hasAuthorized:kXMNQQPlatform]) {
            [XMNThirdFunction requestQQUserInfoWithCompletionBlock:^(id responseObject, NSError *error) {
                [self _handleAuthAlert:responseObject error:error];
            }];
        }else {
            [XMNThirdFunction authQQWithCompletionBlock:^(id responseObject, NSError *error) {
                [XMNThirdFunction requestQQUserInfoWithCompletionBlock:^(id responseObject, NSError *error) {
                    [self _handleAuthAlert:responseObject error:error];
                }];
            }];
        }
    }else if (button.tag == XMNShareContentTypeFile + 2){
        [XMNThirdFunction cancelAuthorize:kXMNQQPlatform];
    }else {
        XMNShareContent *content = [self shareContentWithType:button.tag];
        [XMNThirdFunction shareToQQWithShareContent:content type:self.qqSence completionBlock:^(XMNShareContent * _Nonnull shareContent, NSError * _Nullable error) {
            [self _handleShareAlert:shareContent error:error];
        }];
    }
}


- (void)_handleShareAlert:(XMNShareContent *)shareContent error:(NSError *)error {
    NSString *message = [self contentTitleFromContentType:shareContent.contentType];
    message = [message stringByAppendingString:error ? [NSString stringWithFormat:@"失败,错误原因 :%@",error.userInfo] : @"成功"];

    
    
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"分享提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alertC addAction:cancelAction];
    [self showDetailViewController:alertC sender:nil];
}

- (void)_handleAuthAlert:(id)responseObject error:(NSError *)error {
    NSString *message = @"授权,获取用户信息";
    message = [message stringByAppendingString:error ? [NSString stringWithFormat:@"失败,错误原因 :%@",error.userInfo] : [NSString stringWithFormat:@"成功,用户信息:%@",responseObject]];
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"分享提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alertC addAction:cancelAction];
    [self showDetailViewController:alertC sender:nil];
}


#pragma mark - Getters

- (UIButton *)buttonWithTitle:(NSString *)title center:(CGPoint)center{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [button setTitle:title forState:UIControlStateNormal];
    [button sizeToFit];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    button.center = center;
    return button;
}

- (UIView *)weChatView {
    UIView *weChatView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    weChatView.userInteractionEnabled = YES;
    
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:@[@"好友",@"朋友圈",@"收藏"]];
    segment.selectedSegmentIndex = 0;
    segment.center = CGPointMake(SCREEN_WIDTH/2, 20);
    [segment addEventHandler:^(UISegmentedControl *sender) {
        self.weChatScene = sender.selectedSegmentIndex;
    } forControlEvents:UIControlEventValueChanged];
    [weChatView addSubview:segment];
    
    CGFloat x = SCREEN_WIDTH/2;
    __block CGFloat y = 60;
    
    for (NSString *title in [self weChatActions]) {
        UIButton *button = [self buttonWithTitle:title center:CGPointMake(x, y)];
        y += 30;
        button.tag = [self contentTypeFromTitle:title];
        [button addTarget:self action:@selector(_handleWeChatAction:) forControlEvents:UIControlEventTouchUpInside];
        [weChatView addSubview:button];
    }
    
    return weChatView;
}

- (NSArray *)weChatActions {
    return @[kShareText,kShareImage,kShareEmotion,kShareNews,kShareMusic,kShareVideo,kShareApp,kShareFile,kShareLogin,kSharePay];
}

- (UIView *)weiboView {
    UIView *weiboView = [[UIView alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width , 0, self.scrollView.frame.size.width , self.scrollView.frame.size.height)];
    weiboView.userInteractionEnabled = YES;
    
    CGFloat x = SCREEN_WIDTH/2;
    __block CGFloat y = 60;
    
    for (NSString *title in [self weiboActions]) {
        UIButton *button = [self buttonWithTitle:title center:CGPointMake(x, y)];
        y += 30;
        button.tag = [self contentTypeFromTitle:title];
        [button addTarget:self action:@selector(_handleWeiboAction:) forControlEvents:UIControlEventTouchUpInside];
        [weiboView addSubview:button];
    }
    
    return weiboView;
}

- (NSArray *)weiboActions {
    return @[kShareText,kShareImage,kShareNews,kShareMusic,kShareVideo,kShareLogin,kShareLoginOut];
}


- (UIView *)qqView {
    UIView *qqView = [[UIView alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 , 0, self.scrollView.frame.size.width , self.scrollView.frame.size.height)];
    qqView.userInteractionEnabled = YES;
    
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:@[@"QQ好友",@"QQ空间",@"QQ收藏",@"QQ数据线"]];
    segment.center = CGPointMake(SCREEN_WIDTH/2, 20);
    segment.selectedSegmentIndex = 0;
    [segment addEventHandler:^(UISegmentedControl *sender) {
        if (sender.selectedSegmentIndex == 0) {
            self.qqSence = XMNShareQQTypeFriend;
        }else if (sender.selectedSegmentIndex == 1) {
            self.qqSence = XMNShareQQTypeQZone;
        }else if (sender.selectedSegmentIndex == 2) {
            self.qqSence = XMNShareQQTypeFavorites;
        }else if (sender.selectedSegmentIndex == 3) {
            self.qqSence = XMNShareQQTypeUSB;
        }
    } forControlEvents:UIControlEventValueChanged];
    [qqView addSubview:segment];
    
    CGFloat x = SCREEN_WIDTH/2;
    __block CGFloat y = 60;
    
    for (NSString *title in [self qqActions]) {
        UIButton *button = [self buttonWithTitle:title center:CGPointMake(x, y)];
        y += 30;
        button.tag = [self contentTypeFromTitle:title];
        [button addTarget:self action:@selector(_handleQQAction:) forControlEvents:UIControlEventTouchUpInside];
        [qqView addSubview:button];
    }

    return qqView;
}

- (NSArray *)qqActions {
    return @[kShareLogin,kShareLoginOut,kShareText,kShareImage,kShareMusic,kShareVideo,kShareNews,kShareFile];
}

- (XMNShareContent *)shareContentWithType:(XMNShareContentType)contentType {
    XMNShareContent *shareContent = [[XMNShareContent alloc] init];
    shareContent.contentType = contentType;
    shareContent.objectID = [NSString stringWithFormat:@"%@",[NSDate date]];
    switch (contentType) {
        case XMNShareContentTypeAudio:
        {
            shareContent.thumbnail = [UIImage imageNamed:@"res3.jpg"];
            shareContent.mediaUrl = kMusicDataURL;
            shareContent.title = kMusicTitle;
            shareContent.link = kMusicURL;
            shareContent.desc = kMusicDescription;
            shareContent.contentType = XMNShareContentTypeAudio;
        }
            break;
        case XMNShareContentTypeEmotion:
        {
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"res6"
                                                                 ofType:@"gif"];
            NSData *emoticonData = [NSData dataWithContentsOfFile:filePath];
            
            shareContent.file = emoticonData;
            shareContent.thumbnail = [UIImage imageNamed:@"res6thumb.png"];
            shareContent.contentType = XMNShareContentTypeEmotion;

            break;
        }
        case XMNShareContentTypeeApp:
        {
            Byte* pBuffer = (Byte *)malloc(BUFFER_SIZE);
            memset(pBuffer, 0, BUFFER_SIZE);
            NSData* data = [NSData dataWithBytes:pBuffer length:BUFFER_SIZE];
            free(pBuffer);
            
            shareContent.extInfo = kAppContentExInfo;
            shareContent.file = data;
            shareContent.title = kAPPContentTitle;
            shareContent.fileExt = kAppContentExInfo;
            shareContent.thumbnail = [UIImage imageNamed:@"res2.jpg"];
            shareContent.desc = kAPPContentDescription;
            shareContent.contentType = XMNShareContentTypeeApp;
            
            break;
        }
        case XMNShareContentTypeFile:
        {
            NSString* filePath = [[NSBundle mainBundle] pathForResource:kFileName ofType:kFileExtension];
            NSData *fileData = [NSData dataWithContentsOfFile:filePath];
            shareContent.file = fileData;
            shareContent.thumbnail = [UIImage imageNamed:@"res2.jpg"];
            shareContent.contentType = XMNShareContentTypeFile;
            shareContent.fileExt = @"pdf";
            shareContent.title = kFileTitle;
            shareContent.desc = kFileDescription;
            break;
        }
        case XMNShareContentTypeImage:
        {
            
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"res1" ofType:@"jpg"];
            NSData *imageData = [NSData dataWithContentsOfFile:filePath];
            shareContent.image = [UIImage imageWithData:imageData];
            shareContent.thumbnail = [UIImage imageNamed:@"res1thumb.png"];
            shareContent.contentType = XMNShareContentTypeImage;
            break;
        }
        case XMNShareContentTypeNews:
        {
            shareContent.link = kLinkURL;
            shareContent.title = kLinkTitle;
            shareContent.desc = kLinkDescription;
            shareContent.thumbnail = [UIImage imageNamed:@"res2.jpg"];
            shareContent.contentType = XMNShareContentTypeNews;
            break;
        }
        case XMNShareContentTypeText:
        {
            shareContent.desc = kTextMessage;
            break;
        }
        case XMNShareContentTypeVideo:
        {
            shareContent.thumbnail = [UIImage imageNamed:@"res7.jpg"];
            //!!!分享微博video时link不能为空
            shareContent.link = kLinkURL;
            shareContent.mediaUrl = kVideoURL;
            shareContent.title = kVideoTitle;
            shareContent.desc = kVideoDescription;
            shareContent.contentType = XMNShareContentTypeVideo;
            break;
        }
        default:
            NSLog(@"unknow share content type");
            break;
    }
    return shareContent;
}

- (XMNShareContentType)contentTypeFromTitle:(NSString *)title {
    return [self.typeDict[title] integerValue];
}

- (NSString *)contentTitleFromContentType:(XMNShareContentType)contentType {
    __block NSString *title = @"分享未知消息";
    [[self typeDict] enumerateKeysAndObjectsUsingBlock:^(NSString  *key, NSNumber  *obj, BOOL *stop) {
        if ([obj integerValue] == contentType) {
            title = key;
            *stop = YES;
        }
    }];
    return title;
}

- (NSDictionary *)typeDict {
    return @{@"未知分享类型":@(XMNShareContentTypeUnknow),
             kShareText:@(XMNShareContentTypeText),
             kShareImage:@(XMNShareContentTypeImage),
             kShareMusic:@(XMNShareContentTypeAudio),
             kShareVideo:@(XMNShareContentTypeVideo),
             kShareNews:@(XMNShareContentTypeNews),
             kShareFile:@(XMNShareContentTypeFile),
             kShareApp:@(XMNShareContentTypeeApp),
             kShareEmotion:@(XMNShareContentTypeEmotion),
             kShareLogin:@(XMNShareContentTypeFile + 1),
             kShareLoginOut:@(XMNShareContentTypeFile + 2),
             kSharePay:@(XMNShareContentTypeFile + 3)};
}

@end
