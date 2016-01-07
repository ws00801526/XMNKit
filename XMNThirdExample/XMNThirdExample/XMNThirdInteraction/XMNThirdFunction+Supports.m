//
//  XMNThirdFunction+Supports.m
//  XMNThirdExample
//
//  Created by XMFraker on 16/1/4.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNThirdFunction+Supports.h"

@implementation XMNThirdFunction (Supports)


/// ========================================
/// @name   公用类方法
/// ========================================

+ (NSData *)dataWithImage:(UIImage *)image {
    if (!image) {
        return nil;
    }
    return UIImageJPEGRepresentation(image, 1);
}

+ (NSData *)dataWithImage:(UIImage *)image scale:(CGSize)size {
    if (!image) {
        return nil;
    }
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0, size.width, size.height)];
    UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return UIImageJPEGRepresentation(scaledImage, 1);
}

@end
