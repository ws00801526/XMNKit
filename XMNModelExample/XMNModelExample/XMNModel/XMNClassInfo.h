//
//  XMNClassInfo.h
//  XMNModelExample
//
//  Created by ChenMaolei on 15/12/25.
//  Copyright © 2015年 XMFraker. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <objc/runtime.h>
#import <libkern/OSAtomic.h>

/**
 Type encoding's type.
 */
typedef NS_OPTIONS(NSUInteger, XMNEncodingType) {
    XMNEncodingTypeMask       = 0xFF, ///< mask of type value
    XMNEncodingTypeUnknown    = 0, ///< unknown
    XMNEncodingTypeVoid       = 1, ///< void
    XMNEncodingTypeBool       = 2, ///< bool
    XMNEncodingTypeInt8       = 3, ///< char / BOOL
    XMNEncodingTypeUInt8      = 4, ///< unsigned char
    XMNEncodingTypeInt16      = 5, ///< short
    XMNEncodingTypeUInt16     = 6, ///< unsigned short
    XMNEncodingTypeInt32      = 7, ///< int
    XMNEncodingTypeUInt32     = 8, ///< unsigned int
    XMNEncodingTypeInt64      = 9, ///< long long
    XMNEncodingTypeUInt64     = 10, ///< unsigned long long
    XMNEncodingTypeFloat      = 11, ///< float
    XMNEncodingTypeDouble     = 12, ///< double
    XMNEncodingTypeLongDouble = 13, ///< long double
    XMNEncodingTypeObject     = 14, ///< id
    XMNEncodingTypeClass      = 15, ///< Class
    XMNEncodingTypeSEL        = 16, ///< SEL
    XMNEncodingTypeBlock      = 17, ///< block
    XMNEncodingTypePointer    = 18, ///< void*
    XMNEncodingTypeStruct     = 19, ///< struct
    XMNEncodingTypeUnion      = 20, ///< union
    XMNEncodingTypeCString    = 21, ///< char*
    XMNEncodingTypeCArray     = 22, ///< char[10] (for example)
    
    XMNEncodingTypeQualifierMask   = 0xFF00,   ///< mask of qualifier
    XMNEncodingTypeQualifierConst  = 1 << 8,  ///< const
    XMNEncodingTypeQualifierIn     = 1 << 9,  ///< in
    XMNEncodingTypeQualifierInout  = 1 << 10, ///< inout
    XMNEncodingTypeQualifierOut    = 1 << 11, ///< out
    XMNEncodingTypeQualifierBycopy = 1 << 12, ///< bycopy
    XMNEncodingTypeQualifierByref  = 1 << 13, ///< byref
    XMNEncodingTypeQualifierOneway = 1 << 14, ///< oneway
    
    XMNEncodingTypePropertyMask         = 0xFF0000, ///< mask of property
    XMNEncodingTypePropertyReadonly     = 1 << 16, ///< readonly
    XMNEncodingTypePropertyCopy         = 1 << 17, ///< copy
    XMNEncodingTypePropertyRetain       = 1 << 18, ///< retain
    XMNEncodingTypePropertyNonatomic    = 1 << 19, ///< nonatomic
    XMNEncodingTypePropertyWeak         = 1 << 20, ///< weak
    XMNEncodingTypePropertyCustomGetter = 1 << 21, ///< getter=
    XMNEncodingTypePropertyCustomSetter = 1 << 22, ///< setter=
    XMNEncodingTypePropertyDynamic      = 1 << 23, ///< @dynamic
};

/**
 Get the type from a Type-Encoding string.
 
 @discussion See also:
 https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
 https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
 
 @param typeEncoding  A Type-Encoding string.
 @return The encoding type.
 */
XMNEncodingType XMNEncodingGetType(const char *typeEncoding);


@interface XMNClassIvarInfo : NSObject

/** 实例变量的结构 */
@property (nonatomic, assign, readonly) Ivar ivar;

/** 实例变量的名称 */
@property (nonatomic, strong, readonly) NSString *name;         ///< Ivar's name

/** 实例变量的地址位移 */
@property (nonatomic, assign, readonly) ptrdiff_t offset;

/** 实例变量的编码字符串 */
@property (nonatomic, strong, readonly) NSString *typeEncoding;

/** 变量的编码类型 */
@property (nonatomic, assign, readonly) XMNEncodingType type;

/**
 *  根据ivar结构体 获取变量信息实例
 *
 *  @param ivar 给出的变量结构体
 *
 *  @return XMNClassIvarInfo 实例 或者 nil
 */
- (instancetype)initWithIvar:(Ivar)ivar;
@end

@interface XMNClassMethodInfo : NSObject

/** 初始化给出的method */
@property (nonatomic, assign, readonly) Method method;
/** 方法名称 */
@property (nonatomic, strong, readonly) NSString *name;
/** 方法SEL 类似key */
@property (nonatomic, assign, readonly) SEL sel;
/** 方法的具体实现地址 */
@property (nonatomic, assign, readonly) IMP imp;
/** 方法的编码字符串 */
@property (nonatomic, strong, readonly) NSString *typeEncoding;
/** 方法返回值的编码字符串 */
@property (nonatomic, strong, readonly) NSString *returnTypeEncoding;
/** 方法参数的编码字符串 */
@property (nonatomic, strong, readonly) NSArray *argumentTypeEncodings;

/**
 *  根据给出的method 创建XMNClassMethodInfo实例
 *
 *  @param method 给出的方法
 *
 *  @return XMNClassMethodInfo实例 或者 nil
 */
- (instancetype)initWithMethod:(Method)method;
@end

@interface XMNClassPropertyInfo : NSObject

/** 初始化给定的property实例 */
@property (nonatomic, assign, readonly) objc_property_t property;
/** 属性名 */
@property (nonatomic, strong, readonly) NSString *name;
/** 属性编码类型 */
@property (nonatomic, assign, readonly) XMNEncodingType type;
/** 属性编码类型字符串 */
@property (nonatomic, strong, readonly) NSString *typeEncoding;
/** 属性对应的变量名 */
@property (nonatomic, strong, readonly) NSString *ivarName;
/** 属性的cls结构体 可能为nil */
@property (nonatomic, assign, readonly) Class cls;
/** 属性的getter名 */
@property (nonatomic, strong, readonly) NSString *getter;
/** 属性的setter名 */
@property (nonatomic, strong, readonly) NSString *setter;

/**
 *  根据property创建一个XMNClassPropertyInfo实例
 *
 *  @param property 给出的property
 *
 *  @return XMNClassPropertyInfo实例 或者 nil
 */
- (instancetype)initWithProperty:(objc_property_t)property;

@end

@interface XMNClassInfo : NSObject

/** cls 结构体 */
@property (nonatomic, assign, readonly) Class cls;
/** superCls 结构体 */
@property (nonatomic, assign, readonly) Class superCls;
/** metaCls 结构体 */
@property (nonatomic, assign, readonly) Class metaCls;
/** 判断是否是metaCls */
@property (nonatomic, assign, readonly) BOOL isMeta;
/** cls的名称 */
@property (nonatomic, strong, readonly) NSString *name;
/** superClass的信息 */
@property (nonatomic, strong, readonly) XMNClassInfo *superClassInfo;
/** 类的变量信息集合    @{ivarName:XMNClassIvarInfo}*/
@property (nonatomic, strong, readonly) NSDictionary *ivarInfos;
/** 类的方法信息集合    @{methodName:XMNClassMethodInfo} */
@property (nonatomic, strong, readonly) NSDictionary *methodInfos;
/** 类的属性信息集合    @{propertyName:XMNClassPropertyInfo}*/
@property (nonatomic, strong, readonly) NSDictionary *propertyInfos;


/**
 *  设置类的信息需要更改,当使用class_addMethod()等runtime方法后,之前获取的类信息会发生变化,此时需要setNeedUpdate,并且重新获取下类信息
 */
- (void)setNeedUpdate;


/**
 *  根据给出的cls结构体创建一个classInfo实例
 *
 *  @param cls 给出的cls结构体
 *
 *  @return XMNClassInfo 实例 或者 nil
 */
+ (instancetype)classInfoWithClass:(Class)cls;


/**
 *  根据ClassName创建一个classInfo实例
 *
 *  @param className 给出的className
 *
 *  @return XMNClassInfo 实例 或者 nil
 */
+ (instancetype)classInfoWithClassName:(NSString *)className;


@end
