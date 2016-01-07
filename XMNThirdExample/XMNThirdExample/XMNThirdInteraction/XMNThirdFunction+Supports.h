//
//  XMNThirdFunction+Supports.h
//  XMNThirdExample
//
//  Created by XMFraker on 16/1/4.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNThirdFunction.h"

@interface XMNThirdFunction (Supports)


/// ========================================
/// @name   公用类方法
/// ========================================

+ (NSData *)dataWithImage:(UIImage *)image;

+ (NSData *)dataWithImage:(UIImage *)image scale:(CGSize)size;

@end
