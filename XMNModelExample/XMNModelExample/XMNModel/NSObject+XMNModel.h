//
//  NSObject+XMNModel.h
//  XMNModelExample
//
//  Created by ChenMaolei on 15/12/25.
//  Copyright © 2015年 XMFraker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (XMNModel)

/**
*  根据给出的json创建并返回一个实例
*
*  @param json 一个json类型Object => NSDictionary,NSString,NSData
*
*  @return 一个Object对应的实例  或者 nil
*/
+ (instancetype)xmn_modelWithJSON:(id)json;

/**
 *  根据给定的dictionary创建一个NSObject的实例
 *
 *  @param dictionary 给出的NSDictionary
 *  @discussion  `dictionary`中的key 如果 与NSObject定义的property name不符合,会根据以下基本规范进行转化
    `NSString` or `NSNumber` -> BOOS,int,long,float,NSUinteger等等
    `NSString` -> NSDate  根据以下格式转化 `yyyy-MM-DD'T'HH:mm:ssZ`,`yyyy-MM-dd HH:mm:ss`,`yyyy-MM-dd`
    `NSString` -> NSURL
    `NSValue`  -> CGRect CGSize CGPoint等等
    `NSString` -> SEL,Class
 *  @return 一个NSObject实例 或者 nil
 */
+ (instancetype)xmn_modelWithDictionary:(NSDictionary *)dictionary;

/**
 *  根据给出的json创建并返回一个实例
 *
 *  @param json 一个json类型Object => NSDictionary,NSString,NSData
 *
 *  @return 是否创建成功
 */
- (BOOL)xmn_modelSetWithJSON:(id)json;

/**
 *  根据给定的dictionary创建一个NSObject的实例
 *
 *  @param dictionary 给出的NSDictionary
 *  @discussion  `dictionary`中的key 如果 与NSObject定义的property name不符合,会根据以下基本规范进行转化
 `NSString` or `NSNumber` -> BOOS,int,long,float,NSUinteger等等
 `NSString` -> NSDate  根据以下格式转化 `yyyy-MM-DD'T'HH:mm:ssZ`,`yyyy-MM-dd HH:mm:ss`,`yyyy-MM-dd`
 `NSString` -> NSURL
 `NSValue`  -> CGRect CGSize CGPoint等等
 `NSString` -> SEL,Class
 *  @return 是否创建成功
 */
- (BOOL)xmn_modelSetWithDictionary:(NSDictionary *)dic;

/**
 *  将实例转化成JSONObject
 *
 *  @return JSONObject 或者 nil
 */
- (id)xmn_modelToJSONObject;

/**
 *  将实例转化为NSData
 *
 *  @return NSData 实例 或者 nil
 */
- (NSData *)xmn_modelToJSONData;


/**
 *  将实例转化为 json格式字符串
 *
 *  @return json格式字符串 或者 nil
 */
- (NSString *)xmn_modelToJSONString;


/**
 *  赋值一份NSObject
 *
 *  @return 复制的NSObject实例 或者 nil
 */
- (id)xmn_modelCopy;

/**
 *  将实例进行编码
 *
 *  @param aCoder 编码规范
 */
- (void)xmn_modelEncodeWithCoder:(NSCoder *)aCoder;


/**
 *  从aDecoder中解码出一份实例
 *
 *  @param aDecoder 解码规范
 *
 *  @return 实例 or nil
 */
- (id)xmn_modelInitWithCoder:(NSCoder *)aDecoder;


/**
 *  进行hash编码
 *
 */
- (NSUInteger)xmn_modelHash;


/**
 *  进行相等比较
 *
 *  @return 是否相等
 */
- (BOOL)xmn_modelIsEqual:(id)model;

@end


@interface NSArray (XMNModel)


/**
*  从json-array 中解析出一个array
*
*  @param cls  array的集合类型
*  @param json json array
*
*  @return 包含Class类型的数组  或者 nil
*/
+ (NSArray *)xmn_modelArrayWithClass:(Class)cls json:(id)json;

@end

@interface NSDictionary (XMNModel)

/**
*  cong json-array中解析出对应的class实例
*
*  @param cls  json-array中的实例Class类型
*  @param json json-array @{@"key1":@{@"name":@"1"},@"key2":@{@"name":@"2"}}
*
*  @return @{key1:object1,key2:object2}
*/
+ (NSDictionary *)xmn_modelDictionaryWithClass:(Class)cls json:(id)json;
@end


/**
 If the default model transform does not fit to your model class, implement one or
 more method in this protocol to change the default key-value transform process.
 There's no need to add '<YYModel>' to your class header.
 */
@protocol XMNModel <NSObject>
@optional

/**
 *  自定义一个类的键值对映射
 *
 *  @return 自定义的键值对映射 @{propertyName:json-key-name},@{propertyName:@[id1,id2]}
 */
+ (NSDictionary *)modelCustomPropertyMapper;

/**
 *  集合中Class类型
 *  @{key:Class},@{key:className}
 *  @return 自定义集合中Class类型
 */
+ (NSDictionary *)modelContainerPropertyGenericClass;

/**
 *  根据dictionary中的key值决定对应集合类型
 *
 *  @param dictionary 自定义的集合类型
 *
 *  dictionary[@"a"] != nil ? [YY class] : [self class];
 *  @return 返回对应的类
 */
+ (Class)modelCustomClassForDictionary:(NSDictionary*)dictionary;


/**
 *  自定义的不需要解析的属性名称
 *
 *  @return 数组 包含不需要解析的属性名
 */
+ (NSArray *)modelPropertyBlacklist;

/**
 *  自定义只需要解析数组内属性名称
 *
 *  @return 数组 包含直直接此类属性名称
 */
+ (NSArray *)modelPropertyWhitelist;

/**
 *  此方法中可以进行数据校验
 *  当 JSON 转为 Model 完成后，该方法会被调用。
 *  @param dic key-value键值对
 *
 *  @return 进行数据校验,model不合法返回NO 否则返回YES   不合法则忽略该model
 */
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic;


/**
 *  此方法可以进行数据校验
 *  当 Model 转为 JSON 完成后，该方法会被调用。
 *  @param dic 需要校验的键值对
 *
 *  @return 是否合法
 */
- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic;

@end
