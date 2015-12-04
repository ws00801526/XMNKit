//
//  XMNFuncMacro.h
//  XMNCategoryExample
//
//  Created by shscce on 15/12/4.
//  Copyright © 2015年 xmfraker. All rights reserved.
//

#ifndef XMNFuncMacro_h
#define XMNFuncMacro_h

#pragma mark - 功能相关

/**
 利用runtime动态给category添加指针类型的属性
 
 @param association  ASSIGN / RETAIN / COPY / RETAIN_NONATOMIC / COPY_NONATOMIC
 @warning #import <objc/runtime.h>
 Example:
 @interface NSObject (MyAdd)
 @property (nonatomic, retain) UIColor *myColor;
 @end
 
 #import <objc/runtime.h>
 @implementation NSObject (MyAdd)
 XMNSYNTH_DYNAMIC_PROPERTY_OBJECT(myColor, setMyColor, RETAIN, UIColor *)
 @end
 */
#ifndef XMNSYNTH_DYNAMIC_PROPERTY_OBJECT
#define XMNSYNTH_DYNAMIC_PROPERTY_OBJECT(_getter_, _setter_, _association_, _type_) \
- (void)_setter_ : (_type_)object { \
[self willChangeValueForKey:@#_getter_]; \
objc_setAssociatedObject(self, _cmd, object, OBJC_ASSOCIATION_ ## _association_); \
[self didChangeValueForKey:@#_getter_]; \
} \
- (_type_)_getter_ { \
return objc_getAssociatedObject(self, @selector(_setter_:)); \
}
#endif


/**
 利用runtime特性,给category添加基础类型属性
 @warning #import <objc/runtime.h>
 Example:
 @interface NSObject (MyAdd)
 @property (nonatomic, retain) CGPoint myPoint;
 @end
 
 #import <objc/runtime.h>
 @implementation NSObject (MyAdd)
 XMNSYNTH_DYNAMIC_PROPERTY_CTYPE(myPoint, setMyPoint, CGPoint)
 @end
 */
#ifndef XMNSYNTH_DYNAMIC_PROPERTY_CTYPE
#define XMNSYNTH_DYNAMIC_PROPERTY_CTYPE(_getter_, _setter_, _type_) \
- (void)_setter_ : (_type_)object { \
[self willChangeValueForKey:@#_getter_]; \
NSValue *value = [NSValue value:&object withObjCType:@encode(_type_)]; \
objc_setAssociatedObject(self, _cmd, value, OBJC_ASSOCIATION_RETAIN); \
[self didChangeValueForKey:@#_getter_]; \
} \
- (type)_getter_ { \
_type_ cValue = { 0 }; \
NSValue *value = objc_getAssociatedObject(self, @selector(_setter_:)); \
[value getValue:&cValue]; \
return cValue; \
}
#endif


#endif /* XMNFuncMacro_h */