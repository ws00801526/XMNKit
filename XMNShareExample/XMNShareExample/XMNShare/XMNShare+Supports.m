//
//  XMNShare+Supports.m
//  XMNShareExample
//
//  Created by ChenMaolei on 15/12/30.
//  Copyright © 2015年 XMFraker. All rights reserved.
//

#import "XMNShare+Supports.h"

@implementation XMNShare (Supports)


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

- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0, size.width, size.height)];
    UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}


+ (NSMutableDictionary *)parseUrl:(NSURL*)url{
    NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
    NSArray *urlComponents = [[url query] componentsSeparatedByString:@"&"];
    
    for (NSString *keyValuePair in urlComponents)
    {
        NSRange range=[keyValuePair rangeOfString:@"="];
        [queryStringDictionary setObject:range.length>0?[keyValuePair substringFromIndex:range.location+1]:@"" forKey:(range.length?[keyValuePair substringToIndex:range.location]:keyValuePair)];
    }
    return queryStringDictionary;
}


+ (NSString* )base64Encode:(NSString *)input{
    return  [[input dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
}
+ (NSString*)base64Decode:(NSString *)input{
    return [[NSString alloc ] initWithData:[[NSData alloc] initWithBase64EncodedString:input options:0] encoding:NSUTF8StringEncoding];
}
+ (NSString*)CFBundleDisplayName{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
}
+ (NSString*)CFBundleIdentifier{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}
+ (void)setGeneralPasteboard:(NSString*)key Value:(NSDictionary*)value encoding:(XMNPboardEncoding)encoding{
    if (value&&key) {
        NSData *data=nil;
        NSError *err;
        switch (encoding) {
            case XMNPboardEncodingKeyedArchiver:
                data=[NSKeyedArchiver archivedDataWithRootObject:value];
                break;
            case XMNPboardEncodingPropertyListSerialization:
                data=[NSPropertyListSerialization dataWithPropertyList:value format:NSPropertyListBinaryFormat_v1_0 options:0 error:&err];
            default:
                NSLog(@"encoding not implemented");
                break;
        }
        if (err) {
            NSLog(@"error when NSPropertyListSerialization: %@",err);
        }else if (data){
            [[UIPasteboard generalPasteboard] setData:data forPasteboardType:key];
        }
    }
}

+ (NSDictionary* )generalPasteboardData:(NSString*)key encoding:(XMNPboardEncoding)encoding{
    NSData *data=[[UIPasteboard generalPasteboard] dataForPasteboardType:key];
    NSDictionary *dic=nil;
    if (data) {
        NSError *err;
        switch (encoding) {
            case XMNPboardEncodingKeyedArchiver:
                dic= [NSKeyedUnarchiver unarchiveObjectWithData:data];
                break;
            case XMNPboardEncodingPropertyListSerialization:
                dic=[NSPropertyListSerialization propertyListWithData:data options:0 format:0 error:&err];
            default:
                break;
        }
        if (err) {
            NSLog(@"error when NSPropertyListSerialization: %@",err);
        }
    }
    return dic;
}
+ (NSString* )urlEncodeAfterBase64:(NSString *)string{
    return  [[self base64Encode:string] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
}
+ (NSString* )urlDecode:(NSString*)input{
    return [[input stringByReplacingOccurrencesOfString:@"+" withString:@" "]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end
