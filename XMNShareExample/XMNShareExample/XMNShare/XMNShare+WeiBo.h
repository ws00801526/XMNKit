//
//  XMNShare+WeiBo.h
//  XMNShareExample
//
//  Created by ChenMaolei on 15/12/30.
//  Copyright © 2015年 XMFraker. All rights reserved.
//

#import "XMNShare.h"

@interface XMNShare (WeiBo)

+ (void)connectWeiBoWithAppid:(NSString *)appid;

+ (BOOL)isWeiBoInstalled;

@end
