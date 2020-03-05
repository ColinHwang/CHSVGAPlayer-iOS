//
//  NSObject+CHBase.h
//  CHCategories
//
//  Created by Colin on 2020/1/3.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (CHBase)

#pragma mark - Base
/**
 获取类名

 @return 类名字符串
 */
+ (NSString *)ch_className;

/**
 获取类名

 @return 类名字符串
 */
- (NSString *)ch_className;

/**
 ARC下，获取对象的引用计数(参考, 或与实际有偏差)

 @return 对象的引用计数
 */
- (NSUInteger)ch_retainCountInARC;

/**
 执行父类的指定方法

 @param selector 指定方法
 @return 返回值
 */
- (nullable id)ch_performSelectorToSuperclass:(SEL)selector;

/**
 根据参数, 执行父类的指定方法

 @param selector 指定方法
 @param object 参数
 @return 返回值
 */
- (nullable id)ch_performSelectorToSuperclass:(SEL)selector withObject:(id)object;

/**
 根据参数集, 执行指定方法(类似`performSelector:withObject:afterDelay:`, 支持多个参数)

 @param selector 指定方法
 @param argument 参数集
 @return 返回值
 */
- (nullable id)ch_performSelector:(SEL)selector withObjects:(id)argument, ... NS_REQUIRES_NIL_TERMINATION;

/**
 根据延迟时间, 执行指定方法
 
 @param selector 指定方法
 @param delay 延迟时间
 */
- (void)ch_performSelector:(SEL)selector afterDelay:(NSTimeInterval)delay;

/**
 根据延迟时间及参数集, 执行指定方法(类似`performSelector:withObject:afterDelay:`, 支持多个参数)

 @param selector 指定方法
 @param delay 延迟时间
 @param argument 参数集
 */
- (void)ch_performSelector:(SEL)selector
                afterDelay:(NSTimeInterval)delay
               withObjects:(id)argument, ... NS_REQUIRES_NIL_TERMINATION;

/**
 根据参数集, 在主线程执行指定方法(类似`performSelectorOnMainThread:withObject:waitUntilDone:`, 支持多个参数)

 @param selector 指定方法
 @param wait 当前线程是否要被阻塞，直到主线程执行完毕
 @param argument 参数集
 @return 返回值
 */
- (nullable id)ch_performSelectorOnMainThread:(SEL)selector
                                waitUntilDone:(BOOL)wait
                                  withObjects:(id)argument, ... NS_REQUIRES_NIL_TERMINATION;

/**
 根据参数集及线程, 在指定线程执行指定方法(类似`performSelector:onThread:withObject:waitUntilDone:wait`, 支持多个参数)

 @param selector 指定方法
 @param thr 指定线程
 @param wait 当前线程是否要被阻塞，直到指定线程执行完毕
 @param argument 参数集
 @return 返回值
 */
- (nullable id)ch_performSelector:(SEL)selector
                         onThread:(NSThread *)thr
                    waitUntilDone:(BOOL)wait
                      withObjects:(id)argument, ... NS_REQUIRES_NIL_TERMINATION;

/**
 根据参数集, 在后台线程执行指定方法(类似`performSelectorInBackground:withObject:, 支持多个参数)

 @param selector 指定方法
 @param argument 参数集
 */
- (void)ch_performSelectorInBackground:(SEL)selector withObjects:(id)argument, ... NS_REQUIRES_NIL_TERMINATION;

/**
 遍历指定类别的所有成员变量(例:_a, 不包含property对应的_property成员变量)

 @param aClass 指定类别
 @param includingInherited 是否包含继承类上的所有成员变量
 @param block 遍历处理回调(ivar:成员变量, ivarName:成员变量名称)
 */
FOUNDATION_EXTERN void CHNSObjectEnumerateIvarsUsingBlock(Class aClass, BOOL includingInherited, void (^block)(Ivar ivar, NSString *ivarName));

/**
 遍历指定类别的所有属性

 @param aClass 指定类别
 @param includingInherited 是否包含继承类上的所有属性
 @param block 遍历处理回调(property:属性, propertyName:属性名称)
 */
FOUNDATION_EXTERN void CHNSObjectEnumeratePropertiesUsingBlock(Class aClass, BOOL includingInherited, void (^block)(objc_property_t property, NSString *propertyName));

/**
 遍历指定类别的所有方法

 @param aClass 指定类别
 @param includingInherited 是否包含继承类上的所有方法
 @param block 遍历处理回调(method:方法, selector:方法名称)
 */
FOUNDATION_EXTERN void CHNSObjectEnumerateeInstanceMethodsUsingBlock(Class aClass, BOOL includingInherited, void (^block)(Method method, SEL selector));

/**
 遍历指定协议的所有方法

 @param protocol 指定协议
 @param block 遍历处理回调(selector:方法名称)
 */
FOUNDATION_EXTERN void CHNSObjectEnumerateeProtocolMethodsUsingBlock(Protocol *protocol, void (^block)(SEL selector));

/**
 遍历当前类别的所有成员变量(例:_a, 不包含property对应的_property成员变量, 不包含父类别成员变量)

 @param block 遍历处理回调(ivar:成员变量, ivarName:成员变量名称)
 */
- (void)ch_enumrateIvarsUsingBlock:(void (^)(Ivar ivar, NSString *ivarName))block;

/**
 遍历当前类别的所有属性(不包含父类别成员属性)

 @param block 遍历处理回调(property:属性, propertyName:属性名称)
 */
- (void)ch_enumratePropertiesUsingBlock:(void (^)(objc_property_t property, NSString *propertyName))block;

/**
 遍历当前类别的所有方法(不包含父类别方法)

 @param block 遍历处理回调(method:方法, selector:方法名称)
 */
- (void)ch_enumrateInstanceMethodsUsingBlock:(void (^)(Method method, SEL selector))block;

#pragma mark - Check
/**
 判断两个类别是否相同(不考虑父类别)

 @param aClass 另一个类别
 @return 相同返回YES, 否则返回NO
 */
+ (BOOL)ch_isEqualToClass:(Class)aClass;

/**
 判断两个对象当前类别是否相同(不考虑父类别)

 @param object 另一个对象
 @return 相同返回YES, 否则返回NO
 */
- (BOOL)ch_isEqualToClass:(id)object;

/**
 判断指定类别是否重写指定父类别的指定方法

 @param aClass 指定类别
 @param superclass 指定父类别
 @param selector 指定方法
 @return 重写返回YES, 否则返回NO
 */
FOUNDATION_EXTERN BOOL CHNSObjectIsOverrideMethod(Class aClass, Class superclass, SEL selector);

/**
 判断当前类别是否重写指定父类别的指定方法

 @param selector 指定方法
 @param superclass 指定父类别
 @return 重写返回YES, 否则返回NO
 */
+ (BOOL)ch_isOverrideMethod:(SEL)selector ofSuperclass:(Class)superclass;

/**
 判断当前对象是否重写指定父类别的指定方法

 @param selector 指定方法
 @param superclass 指定父类别
 @return 重写返回YES, 否则返回NO
 */
- (BOOL)ch_isOverrideMethod:(SEL)selector ofSuperclass:(Class)superclass;

#pragma mark - Deep Copy
/**
 通过NSKeyedArchiver和NSKeyedUnarchiver, 深复制对象(error -> nil)

 @return 深复制后的对象
 */
- (nullable id)ch_deepCopy;

/**
 通过NSKeyedArchiver(子类)和NSKeyedUnarchiver(子类), 深复制对象(error -> nil)

 @param archiver   指定的NSKeyedArchiver类或子类
 @param unarchiver 指定的NSKeyedUnarchiver类或子类
 @return 深复制后的对象
 */
- (nullable id)ch_deepCopyWithArchiver:(Class)archiver unarchiver:(Class)unarchiver;

#pragma mark - NSBlock
/**
 获取Block的类别(NSBlock)

 @return Block的类别
 */
FOUNDATION_EXPORT Class CHNSBlockClass(void);

#pragma mark - Associated Value
/**
 根据Key和Value, 关联对象(retain, strong, nonatomic)
 
 @param value Value
 @param key   Key
 */
- (void)ch_setAssociatedValue:(id)value withKey:(const void *)key;

/**
 根据Key和Value, 关联对象(weak)
 
 @param value Value
 @param key   Key
 */
- (void)ch_setAssociatedWeakValue:(id)value withKey:(const void *)key;

/**
 根据Key和Value, 关联对象(copy, nonatomic)
 
 @param value Value
 @param key   Key
 */
- (void)ch_setAssociatedCopyValue:(id)value withKey:(const void *)key;

/**
 根据Key, 获取关联对象的Value
 
 @param key Key
 @return Key对应关联对象的Value
 */
- (id)ch_getAssociatedValueForKey:(const void *)key;

/**
 移除所有关联对象
 */
- (void)ch_removeAssociatedValues;

#pragma mark - Swizzle Method
/**
 替换实例方法(对象方法)
 
 @param originalSel 原方法SEL
 @param newSel      新方法SEL
 @return 替换成功返回YES, 否则返回NO
 */
+ (BOOL)ch_swizzleInstanceMethod:(SEL)originalSel withNewMethod:(SEL)newSel;

/**
 替换静态方法(类方法)
 
 @param originalSel 原方法SEL
 @param newSel      新方法SEL
 @return 替换成功返回YES, 否则返回NO
 */
+ (BOOL)ch_swizzleClassMethod:(SEL)originalSel withNewMethod:(SEL)newSel;

/**
 根据新方法前缀, 替换指定类别的实例方法集(对象方法)
 例:viewDidLoad -> _ch_viewDidLoad
 
 @param aClass 指定类别
 @param selectors 旧实例方法集
 @param newMethodPrefix 新方法前缀
 @return 替换成功返回YES, 否则返回NO
 */
FOUNDATION_EXTERN BOOL CHNSObjectSwizzleInstanceMethodsWithNewMethodPrefix(Class aClass, SEL _Nonnull * _Nullable selectors, NSString *newMethodPrefix);

/**
 根据新方法前缀, 替换指定类别的静态方法集(类方法)

 @param aClass 指定类别
 @param selectors 旧静态方法集
 @param newMethodPrefix 新方法前缀
 @return 替换成功返回YES, 否则返回NO
 */
FOUNDATION_EXTERN BOOL CHNSObjectSwizzleClassMethodsWithNewMethodPrefix(Class aClass, SEL _Nonnull * _Nullable selectors, NSString *newMethodPrefix);

@end

NS_ASSUME_NONNULL_END
