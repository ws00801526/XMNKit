//
//  XMNClassInfo.m
//  XMNModelExample
//
//  Created by ChenMaolei on 15/12/25.
//  Copyright © 2015年 XMFraker. All rights reserved.
//

#import "XMNClassInfo.h"

/// ========================================
/// @name   从typeEncoding中获取XMNEncodingType
/// ========================================

XMNEncodingType XMNEncodingGetType(const char *typeEncoding) {
    char *type = (char *)typeEncoding;
    if (!type) return XMNEncodingTypeUnknown;
    size_t len = strlen(type);
    if (len == 0) return XMNEncodingTypeUnknown;
    
    XMNEncodingType qualifier = 0;
    bool prefix = true;
    while (prefix) {
        switch (*type) {
            case 'r': {
                qualifier |= XMNEncodingTypeQualifierConst;
                type++;
            } break;
            case 'n': {
                qualifier |= XMNEncodingTypeQualifierIn;
                type++;
            } break;
            case 'N': {
                qualifier |= XMNEncodingTypeQualifierInout;
                type++;
            } break;
            case 'o': {
                qualifier |= XMNEncodingTypeQualifierOut;
                type++;
            } break;
            case 'O': {
                qualifier |= XMNEncodingTypeQualifierBycopy;
                type++;
            } break;
            case 'R': {
                qualifier |= XMNEncodingTypeQualifierByref;
                type++;
            } break;
            case 'V': {
                qualifier |= XMNEncodingTypeQualifierOneway;
                type++;
            } break;
            default: { prefix = false; } break;
        }
    }
    
    len = strlen(type);
    if (len == 0) return XMNEncodingTypeUnknown | qualifier;
    
    switch (*type) {
        case 'v': return XMNEncodingTypeVoid | qualifier;
        case 'B': return XMNEncodingTypeBool | qualifier;
        case 'c': return XMNEncodingTypeInt8 | qualifier;
        case 'C': return XMNEncodingTypeUInt8 | qualifier;
        case 's': return XMNEncodingTypeInt16 | qualifier;
        case 'S': return XMNEncodingTypeUInt16 | qualifier;
        case 'i': return XMNEncodingTypeInt32 | qualifier;
        case 'I': return XMNEncodingTypeUInt32 | qualifier;
        case 'l': return XMNEncodingTypeInt32 | qualifier;
        case 'L': return XMNEncodingTypeUInt32 | qualifier;
        case 'q': return XMNEncodingTypeInt64 | qualifier;
        case 'Q': return XMNEncodingTypeUInt64 | qualifier;
        case 'f': return XMNEncodingTypeFloat | qualifier;
        case 'd': return XMNEncodingTypeDouble | qualifier;
        case 'D': return XMNEncodingTypeLongDouble | qualifier;
        case '#': return XMNEncodingTypeClass | qualifier;
        case ':': return XMNEncodingTypeSEL | qualifier;
        case '*': return XMNEncodingTypeCString | qualifier;
        case '^': return XMNEncodingTypePointer | qualifier;
        case '[': return XMNEncodingTypeCArray | qualifier;
        case '(': return XMNEncodingTypeUnion | qualifier;
        case '{': return XMNEncodingTypeStruct | qualifier;
        case '@': {
            if (len == 2 && *(type + 1) == '?')
                return XMNEncodingTypeBlock | qualifier;
            else
                return XMNEncodingTypeObject | qualifier;
        }
        default: return XMNEncodingTypeUnknown | qualifier;
    }
}

/// ========================================
/// @name   XMNClassIvarInfo实现
/// ========================================

@implementation XMNClassIvarInfo

- (instancetype)initWithIvar:(Ivar)ivar {
    if (!ivar) {
        return nil;
    }
    if ([super init]) {
        _ivar = ivar;
        const char *name = ivar_getName(ivar);
        if (name) {
            _name = [NSString stringWithUTF8String:name];
        }
        _offset = ivar_getOffset(ivar);
        const char *typeEncoding = ivar_getTypeEncoding(ivar);
        if (typeEncoding) {
            _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
            _type = XMNEncodingGetType(typeEncoding);
        }
    }
    return self;
}

@end

/// ========================================
/// @name   XMNClassMethodInfo实现
/// ========================================

@implementation XMNClassMethodInfo

- (instancetype)initWithMethod:(Method)method {
    if (!method) {
        return nil;
    }
    if ([super init]) {
        _method = method;
        _sel = method_getName(method);
        const char *name = sel_getName(_sel);
        if (name) {
            _name = [NSString stringWithUTF8String:name];
        }
        _imp = method_getImplementation(method);
        const char *typeEncoding = method_getTypeEncoding(method);
        if (typeEncoding) {
            _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
        }
        char *returnType = method_copyReturnType(method);
        if (returnType) {
            _returnTypeEncoding = [NSString stringWithUTF8String:returnType];
            free(returnType);
        }
        unsigned int argumentsCount = method_getNumberOfArguments(method);
        if (argumentsCount > 0) {
            NSMutableArray *argumentTypeEncodings = [NSMutableArray array];
            for (int i = 0; i < argumentsCount; i ++) {
                char *argumentType = method_copyArgumentType(method, i);
                NSString *argumentTypeName = argumentType ? [NSString stringWithUTF8String:argumentType] : @"";
                [argumentTypeEncodings addObject:argumentTypeName];
                argumentType ? free(argumentType) : nil;
            }
            _argumentTypeEncodings = argumentTypeEncodings;
        }
    }
    return self;
}

@end

/// ========================================
/// @name   XMNClassPropertyInfo实现
/// ========================================

@implementation XMNClassPropertyInfo

- (instancetype)initWithProperty:(objc_property_t)property {
    
    if (!property) {
        return nil;
    }
    if ([super init]) {
        _property = property;
        const char *name = property_getName(property);
        _name = name ? [NSString stringWithUTF8String:name] : nil;
        XMNEncodingType type = 0;
        unsigned int attrCount = 0;
        objc_property_attribute_t *attrs = property_copyAttributeList(property, &attrCount);
        
        for (unsigned int i = 0; i < attrCount; i ++) {
            switch (attrs[i].name[0]) {
                case 'T':
                {
                    if (attrs[i].value) {
                        _typeEncoding = [NSString stringWithUTF8String:attrs[i].value];
                        type = XMNEncodingGetType(attrs[i].value);
                        if (type & XMNEncodingTypeObject) {
                            size_t len = strlen(attrs[i].value);
                            if (len > 3) {
                                char name[len - 2];
                                name[len - 3] = '\0';
                                memcpy(name, attrs[i].value + 2, len - 3);
                                _cls = objc_getClass(name);
                            }
                        }
                    }
                }
                    break;
                case 'V':
                {
                    if (attrs[i].value) {
                        _ivarName = [NSString stringWithUTF8String:attrs[i].value];
                    }
                } break;
                case 'R': {
                    type |= XMNEncodingTypePropertyReadonly;
                } break;
                case 'C': {
                    type |= XMNEncodingTypePropertyCopy;
                } break;
                case '&': {
                    type |= XMNEncodingTypePropertyRetain;
                } break;
                case 'N': {
                    type |= XMNEncodingTypePropertyNonatomic;
                } break;
                case 'D': {
                    type |= XMNEncodingTypePropertyDynamic;
                } break;
                case 'W': {
                    type |= XMNEncodingTypePropertyWeak;
                } break;
                case 'G': {
                    type |= XMNEncodingTypePropertyCustomGetter;
                    if (attrs[i].value) {
                        _getter = [NSString stringWithUTF8String:attrs[i].value];
                    }
                } break;
                case 'S': {
                    type |= XMNEncodingTypePropertyCustomSetter;
                    if (attrs[i].value) {
                        _setter = [NSString stringWithUTF8String:attrs[i].value];
                    }
                }
                default:
                    break;
            }
        }
        attrs ? free(attrs) : nil;
        _type = type;
        if (_name.length) {
            if (!_getter) {
                _getter = _name;
            }
            if (!_setter) {
                _setter = [NSString stringWithFormat:@"set%@%@:", [_name substringToIndex:1].uppercaseString, [_name substringFromIndex:1]];
            }
        }
        
    }
    return self;
    
}

@end

/// ========================================
/// @name   XMNClassInfo实现
/// ========================================


//创建静态可变Dict缓存已经获取过的classInfo metaInfo
static CFMutableDictionaryRef classCache;
static CFMutableDictionaryRef metaCache;
static dispatch_once_t onceToken;
static OSSpinLock lock;


@implementation XMNClassInfo
{
    BOOL _needUpdate;
}

#pragma mark - XMNClassInfo LifeCycle

- (instancetype)initWithClass:(Class)cls {
    if (!cls) return nil;
    if ([super init]) {
        _cls = cls;
        _superCls = class_getSuperclass(cls);
        _isMeta = class_isMetaClass(cls);
        _isMeta ? nil : objc_getMetaClass(class_getName(cls));
        _name = NSStringFromClass(cls);
        [self _update];
        _superClassInfo = [self.class classInfoWithClass:_superCls];
    }
    return self;
    self = [super init];
    _cls = cls;
    _superCls = class_getSuperclass(cls);
    _isMeta = class_isMetaClass(cls);
    if (!_isMeta) {
        _metaCls = objc_getMetaClass(class_getName(cls));
    }
    _name = NSStringFromClass(cls);
    [self _update];
    
    _superClassInfo = [self.class classInfoWithClass:_superCls];
    return self;
}

+ (instancetype)classInfoWithClass:(Class)cls {
    if (!cls) {
        return nil;
    }

    //使用dispatch_once 保证只会实例化一次
    dispatch_once(&onceToken, ^{
        classCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        metaCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        lock = OS_SPINLOCK_INIT;
    });
    
    //使用lock保证从CFDictionary中获取数据时线程安全
    OSSpinLockLock(&lock);
    XMNClassInfo *info = CFDictionaryGetValue(class_isMetaClass(cls) ? metaCache : classCache, (__bridge const void *)(cls));
    if (info && info->_needUpdate) {
        [info _update];
    }
    OSSpinLockUnlock(&lock);
    if (!info) {
        info = [[XMNClassInfo alloc] initWithClass:cls];
        if (info) {
            OSSpinLockLock(&lock);
            CFDictionarySetValue(info.isMeta ? metaCache : classCache, (__bridge const void *)(cls), (__bridge const void *)(info));
            OSSpinLockUnlock(&lock);
        }
    }
    return info;
    
}

+ (instancetype)classInfoWithClassName:(NSString *)className {
    Class cls = NSClassFromString(className);
    return [self classInfoWithClass:cls];
}

#pragma mark - XMNClassInfo Methods

- (void)_update {
    _ivarInfos = nil;
    _methodInfos = nil;
    _propertyInfos = nil;
    
    Class cls = self.cls;
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(cls, &methodCount);
    if (methods) {
        NSMutableDictionary *methodInfos = [NSMutableDictionary new];
        _methodInfos = methodInfos;
        for (unsigned int i = 0; i < methodCount; i++) {
            XMNClassMethodInfo *info = [[XMNClassMethodInfo alloc] initWithMethod:methods[i]];
            if (info.name) methodInfos[info.name] = info;
        }
        free(methods);
    }
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(cls, &propertyCount);
    if (properties) {
        NSMutableDictionary *propertyInfos = [NSMutableDictionary new];
        _propertyInfos = propertyInfos;
        for (unsigned int i = 0; i < propertyCount; i++) {
            XMNClassPropertyInfo *info = [[XMNClassPropertyInfo alloc] initWithProperty:properties[i]];
            if (info.name) propertyInfos[info.name] = info;
        }
        free(properties);
    }
    
    unsigned int ivarCount = 0;
    Ivar *ivars = class_copyIvarList(cls, &ivarCount);
    if (ivars) {
        NSMutableDictionary *ivarInfos = [NSMutableDictionary new];
        _ivarInfos = ivarInfos;
        for (unsigned int i = 0; i < ivarCount; i++) {
            XMNClassIvarInfo *info = [[XMNClassIvarInfo alloc] initWithIvar:ivars[i]];
            if (info.name) ivarInfos[info.name] = info;
        }
        free(ivars);
    }
    _needUpdate = NO;
}

- (void)setNeedUpdate {
    _needUpdate = YES;
}

@end
