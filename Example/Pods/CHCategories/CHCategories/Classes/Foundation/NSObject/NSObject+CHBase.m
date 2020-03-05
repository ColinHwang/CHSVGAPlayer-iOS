//
//  NSObject+CHBase.m
//  CHCategories
//
//  Created by Colin on 2020/1/3.
//

#import "NSObject+CHBase.h"
#import <objc/message.h>

@implementation NSObject (CHBase)

#pragma mark - Base
+ (NSString *)ch_className {
    return NSStringFromClass(self);
}

- (NSString *)ch_className {
    return [NSString stringWithUTF8String:class_getName([self class])];
}

- (NSUInteger)ch_retainCountInARC {
    return [[self valueForKey:@"retainCount"] unsignedLongValue];
}

#define CHObjectInitInvocation(_last_arg_, _return_) \
NSMethodSignature *signature = [self methodSignatureForSelector:selector]; \
if (!signature) { [self doesNotRecognizeSelector:selector]; return _return_; } \
NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature]; \
if (!invocation) { [self doesNotRecognizeSelector:selector]; return _return_; } \
[invocation setTarget:self]; \
[invocation setSelector:selector]; \
if (_last_arg_) { \
va_list args; \
va_start(args, _last_arg_); \
[NSObject _ch_setInvocation:invocation withSignature:signature arguments:args]; \
va_end(args); \
}

+ (void)_ch_setInvocation:(NSInvocation *)inv withSignature:(NSMethodSignature *)sig arguments:(va_list)args {
    NSUInteger count = [sig numberOfArguments];
    for (int index = 2; index < count; index++) {
        char *type = (char *)[sig getArgumentTypeAtIndex:index];
        while (*type == 'r' || // const
               *type == 'n' || // in
               *type == 'N' || // inout
               *type == 'o' || // out
               *type == 'O' || // bycopy
               *type == 'R' || // byref
               *type == 'V') { // oneway
            type++; // cutoff useless prefix
        }
        
        BOOL unsupportedType = NO;
        switch (*type) {
            case 'v': // 1: void
            case 'B': // 1: bool
            case 'c': // 1: char / BOOL
            case 'C': // 1: unsigned char
            case 's': // 2: short
            case 'S': // 2: unsigned short
            case 'i': // 4: int / NSInteger(32bit)
            case 'I': // 4: unsigned int / NSUInteger(32bit)
            case 'l': // 4: long(32bit)
            case 'L': // 4: unsigned long(32bit)
            { // 'char' and 'short' will be promoted to 'int'.
                int arg = va_arg(args, int);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case 'q': // 8: long long / long(64bit) / NSInteger(64bit)
            case 'Q': // 8: unsigned long long / unsigned long(64bit) / NSUInteger(64bit)
            {
                long long arg = va_arg(args, long long);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case 'f': // 4: float / CGFloat(32bit)
            { // 'float' will be promoted to 'double'.
                double arg = va_arg(args, double);
                float argf = arg;
                [inv setArgument:&argf atIndex:index];
            } break;
                
            case 'd': // 8: double / CGFloat(64bit)
            {
                double arg = va_arg(args, double);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case 'D': // 16: long double
            {
                long double arg = va_arg(args, long double);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case '*': // char *
            case '^': // pointer
            {
                void *arg = va_arg(args, void *);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case ':': // SEL
            {
                SEL arg = va_arg(args, SEL);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case '#': // Class
            {
                Class arg = va_arg(args, Class);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case '@': // id
            {
                id arg = va_arg(args, id);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case '{': // struct
            {
                if (strcmp(type, @encode(CGPoint)) == 0) {
                    CGPoint arg = va_arg(args, CGPoint);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(CGSize)) == 0) {
                    CGSize arg = va_arg(args, CGSize);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(CGRect)) == 0) {
                    CGRect arg = va_arg(args, CGRect);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(CGVector)) == 0) {
                    CGVector arg = va_arg(args, CGVector);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(CGAffineTransform)) == 0) {
                    CGAffineTransform arg = va_arg(args, CGAffineTransform);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(CATransform3D)) == 0) {
                    CATransform3D arg = va_arg(args, CATransform3D);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(NSRange)) == 0) {
                    NSRange arg = va_arg(args, NSRange);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(UIOffset)) == 0) {
                    UIOffset arg = va_arg(args, UIOffset);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(UIEdgeInsets)) == 0) {
                    UIEdgeInsets arg = va_arg(args, UIEdgeInsets);
                    [inv setArgument:&arg atIndex:index];
                } else {
                    unsupportedType = YES;
                }
            } break;
                
            case '(': // union
            {
                unsupportedType = YES;
            } break;
                
            case '[': // array
            {
                unsupportedType = YES;
            } break;
                
            default: // what?!
            {
                unsupportedType = YES;
            } break;
        }
        
        if (unsupportedType) {
            // Try with some dummy type...
            
            NSUInteger size = 0;
            NSGetSizeAndAlignment(type, &size, NULL);
            
#define case_size(_size_) \
else if (size <= 4 * _size_ ) { \
struct dummy { char tmp[4 * _size_]; }; \
struct dummy arg = va_arg(args, struct dummy); \
[inv setArgument:&arg atIndex:index]; \
}
            if (size == 0) { }
            case_size( 1) case_size( 2) case_size( 3) case_size( 4)
            case_size( 5) case_size( 6) case_size( 7) case_size( 8)
            case_size( 9) case_size(10) case_size(11) case_size(12)
            case_size(13) case_size(14) case_size(15) case_size(16)
            case_size(17) case_size(18) case_size(19) case_size(20)
            case_size(21) case_size(22) case_size(23) case_size(24)
            case_size(25) case_size(26) case_size(27) case_size(28)
            case_size(29) case_size(30) case_size(31) case_size(32)
            case_size(33) case_size(34) case_size(35) case_size(36)
            case_size(37) case_size(38) case_size(39) case_size(40)
            case_size(41) case_size(42) case_size(43) case_size(44)
            case_size(45) case_size(46) case_size(47) case_size(48)
            case_size(49) case_size(50) case_size(51) case_size(52)
            case_size(53) case_size(54) case_size(55) case_size(56)
            case_size(57) case_size(58) case_size(59) case_size(60)
            case_size(61) case_size(62) case_size(63) case_size(64)
            else {
                /*
                 Larger than 256 byte?! I don't want to deal with this stuff up...
                 Ignore this argument.
                 */
                struct dummy {char tmp;};
                for (int i = 0; i < size; i++) va_arg(args, struct dummy);
                NSLog(@"CHCategories performSelector unsupported type:%s (%lu bytes)",
                      [sig getArgumentTypeAtIndex:index],(unsigned long)size);
            }
#undef case_size
            
        }
    }
}

+ (id)_ch_getReturnFromInvocation:(NSInvocation *)inv withSignature:(NSMethodSignature *)sig {
    NSUInteger length = [sig methodReturnLength];
    if (length == 0) return nil;
    
    char *type = (char *)[sig methodReturnType];
    while (*type == 'r' || // const
           *type == 'n' || // in
           *type == 'N' || // inout
           *type == 'o' || // out
           *type == 'O' || // bycopy
           *type == 'R' || // byref
           *type == 'V') { // oneway
        type++; // cutoff useless prefix
    }
    
#define return_with_number(_type_) \
do { \
_type_ ret; \
[inv getReturnValue:&ret]; \
return @(ret); \
} while (0)
    
    switch (*type) {
        case 'v': return nil; // void
        case 'B': return_with_number(bool);
        case 'c': return_with_number(char);
        case 'C': return_with_number(unsigned char);
        case 's': return_with_number(short);
        case 'S': return_with_number(unsigned short);
        case 'i': return_with_number(int);
        case 'I': return_with_number(unsigned int);
        case 'l': return_with_number(int);
        case 'L': return_with_number(unsigned int);
        case 'q': return_with_number(long long);
        case 'Q': return_with_number(unsigned long long);
        case 'f': return_with_number(float);
        case 'd': return_with_number(double);
        case 'D': { // long double
            long double ret;
            [inv getReturnValue:&ret];
            return [NSNumber numberWithDouble:ret];
        };
            
        case '@': { // id
            __autoreleasing id ret = nil; // fix EXC_BAD_ACCESS
            [inv getReturnValue:&ret];
            return ret;
        };
            
        case '#': { // Class
            Class ret = nil;
            [inv getReturnValue:&ret];
            return ret;
        };
            
        default: { // struct / union / SEL / void* / unknown
            const char *objCType = [sig methodReturnType];
            char *buf = calloc(1, length);
            if (!buf) return nil;
            [inv getReturnValue:buf];
            NSValue *value = [NSValue valueWithBytes:buf objCType:objCType];
            free(buf);
            return value;
        };
    }
#undef return_with_number
}

- (id)ch_performSelectorToSuperclass:(SEL)selector {
    struct objc_super aSuper;
    aSuper.receiver = self;
    aSuper.super_class = class_getSuperclass(object_getClass(self));
    
    id (*objc_superAllocTyped)(struct objc_super *, SEL) = (void *)&objc_msgSendSuper;
    return (*objc_superAllocTyped)(&aSuper, selector);
}

- (id)ch_performSelectorToSuperclass:(SEL)selector withObject:(id)object {
    /*
     http://stackoverflow.com/questions/14635024/using-objc-msgsendsuper-to-invoke-a-class-method
     */
    struct objc_super aSuper;
    aSuper.receiver = self;
    aSuper.super_class = class_getSuperclass(object_getClass(self));
    
    id (*objc_superAllocTyped)(struct objc_super *, SEL, ...) = (void *)&objc_msgSendSuper;
    return (*objc_superAllocTyped)(&aSuper, selector, object);
}

- (id)ch_performSelector:(SEL)selector withObjects:(id)argument, ... {
    CHObjectInitInvocation(argument, nil);
    [invocation invoke];
    return [NSObject _ch_getReturnFromInvocation:invocation withSignature:signature];
}

- (void)ch_performSelector:(SEL)selector afterDelay:(NSTimeInterval)delay {
    [self performSelector:selector withObject:nil afterDelay:delay];
}

- (void)ch_performSelector:(SEL)selector afterDelay:(NSTimeInterval)delay withObjects:(id)argument, ... {
    CHObjectInitInvocation(argument, );
    [invocation retainArguments];
    [invocation performSelector:@selector(invoke) withObject:nil afterDelay:delay];
}

- (id)ch_performSelectorOnMainThread:(SEL)selector waitUntilDone:(BOOL)wait withObjects:(id)argument, ... {
    CHObjectInitInvocation(argument, nil);
    if (!wait) [invocation retainArguments];
    [invocation performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:wait];
    return wait ? [NSObject _ch_getReturnFromInvocation:invocation withSignature:signature] : nil;
}

- (id)ch_performSelector:(SEL)selector onThread:(NSThread *)thr waitUntilDone:(BOOL)wait withObjects:(id)argument, ...  {
    CHObjectInitInvocation(argument, nil);
    if (!wait) [invocation retainArguments];
    [invocation performSelector:@selector(invoke) onThread:thr withObject:nil waitUntilDone:wait];
    return wait ? [NSObject _ch_getReturnFromInvocation:invocation withSignature:signature] : nil;
}

- (void)ch_performSelectorInBackground:(SEL)selector withObjects:(id)argument, ... {
    CHObjectInitInvocation(argument, );
    [invocation retainArguments];
    [invocation performSelectorInBackground:@selector(invoke) withObject:nil];
}

#undef CHObjectInitInvocation

void CHNSObjectEnumerateIvarsUsingBlock(Class aClass, BOOL includingInherited, void (^block)(Ivar ivar, NSString *ivarName)) {
    unsigned int outCount = 0;
    Ivar *ivars = class_copyIvarList(aClass, &outCount);
    for (unsigned int i = 0; i < outCount; i ++) {
        Ivar ivar = ivars[i];
        if (block) block(ivar, [NSString stringWithFormat:@"%s", ivar_getName(ivar)]);
    }
    free(ivars);
    
    if (includingInherited) {
        Class superclass = class_getSuperclass(aClass);
        if (superclass) {
            CHNSObjectEnumerateIvarsUsingBlock(superclass, includingInherited, block);
        }
    }
}

void CHNSObjectEnumeratePropertiesUsingBlock(Class aClass, BOOL includingInherited, void (^block)(objc_property_t property, NSString *propertyName)) {
    /*
     https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101-SW1
     */
    unsigned int propertiesCount = 0;
    objc_property_t *properties = class_copyPropertyList(aClass, &propertiesCount);
    for (unsigned int i = 0; i < propertiesCount; i++) {
        objc_property_t property = properties[i];
        if (block) block(property, [NSString stringWithFormat:@"%s", property_getName(property)]);
    }
    free(properties);
    
    if (includingInherited) {
        Class superclass = class_getSuperclass(aClass);
        if (superclass) {
            CHNSObjectEnumeratePropertiesUsingBlock(superclass, includingInherited, block);
        }
    }
}

void CHNSObjectEnumerateInstanceMethodsUsingBlock(Class aClass, BOOL includingInherited, void (^block)(Method method, SEL selector)) {
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(aClass, &methodCount);
    for (unsigned int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        SEL selector = method_getName(method);
        if (block) block(method, selector);
    }
    free(methods);
    
    if (includingInherited) {
        Class superclass = class_getSuperclass(aClass);
        if (superclass) {
            CHNSObjectEnumerateInstanceMethodsUsingBlock(superclass, includingInherited, block);
        }
    }
}

void CHNSObjectEnumerateProtocolMethodsUsingBlock(Protocol *protocol, void (^block)(SEL selector)) {
    unsigned int methodCount = 0;
    struct objc_method_description *methods = protocol_copyMethodDescriptionList(protocol, NO, YES, &methodCount);
    for (int i = 0; i < methodCount; i++) {
        struct objc_method_description methodDescription = methods[i];
        if (block) {
            block(methodDescription.name);
        }
    }
    free(methods);
}

- (void)ch_enumrateIvarsUsingBlock:(void (^)(Ivar ivar, NSString *ivarName))block {
    CHNSObjectEnumerateIvarsUsingBlock(self.class, NO, block);
}

- (void)ch_enumratePropertiesUsingBlock:(void (^)(objc_property_t property, NSString *propertyName))block {
    CHNSObjectEnumeratePropertiesUsingBlock(self.class, NO, block);
}

- (void)ch_enumrateInstanceMethodsUsingBlock:(void (^)(Method method, SEL selector))block {
    CHNSObjectEnumerateInstanceMethodsUsingBlock(self.class, NO, block);
}

#pragma mark - Check
+ (BOOL)ch_isEqualToClass:(Class)aClass {
    return [[self ch_className] isEqualToString:[aClass ch_className]];
}

- (BOOL)ch_isEqualToClass:(id)object {
    return [[self ch_className] isEqualToString:[object ch_className]];
}

BOOL CHNSObjectIsOverrideMethod(Class aClass, Class superclass, SEL selector) {
    if (![aClass isSubclassOfClass:superclass]) return NO;
    
    if (![superclass instancesRespondToSelector:selector]) return NO;
    
    Method superclassMethod = class_getInstanceMethod(superclass, selector);
    Method instanceMethod = class_getInstanceMethod(aClass, selector);
    
    if (!instanceMethod || instanceMethod == superclassMethod) return NO;
    
    return YES;
}

+ (BOOL)ch_isOverrideMethod:(SEL)selector ofSuperclass:(Class)superclass {
    return CHNSObjectIsOverrideMethod(self, superclass, selector);
}

- (BOOL)ch_isOverrideMethod:(SEL)selector ofSuperclass:(Class)superclass {
    return [self.class ch_isOverrideMethod:selector ofSuperclass:superclass];
}

#pragma mark - Deep Copy
- (id)ch_deepCopy {
    id obj = nil;
    @try {
        obj = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    return obj;
}

- (id)ch_deepCopyWithArchiver:(Class)archiver unarchiver:(Class)unarchiver {
    id obj = nil;
    @try {
        obj = [unarchiver unarchiveObjectWithData:[archiver archivedDataWithRootObject:self]];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    return obj;
}

#pragma mark - NSBlock
Class CHNSBlockClass(void) {
    static Class class;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        void (^block)(void) = ^{};
        class = ((NSObject *)block).class;
        while (class_getSuperclass(class) != [NSObject class]) {
            class = class_getSuperclass(class);
        }
    });
    return class; // current is "NSBlock"
}

#pragma mark - Associated Value
- (void)ch_setAssociatedValue:(id)value withKey:(const void *)key {
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)ch_setAssociatedWeakValue:(id)value withKey:(const void *)key {
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_ASSIGN);
}

- (void)ch_setAssociatedCopyValue:(id)value withKey:(const void *)key {
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (id)ch_getAssociatedValueForKey:(const void *)key {
    return objc_getAssociatedObject(self, key);
}

- (void)ch_removeAssociatedValues {
    objc_removeAssociatedObjects(self);
}

#pragma mark - Swizzle Method
+ (BOOL)ch_swizzleInstanceMethod:(SEL)originalSel withNewMethod:(SEL)newSel {
    Method originalMethod = class_getInstanceMethod(self, originalSel);
    Method newMethod = class_getInstanceMethod(self, newSel);
    if (!originalMethod || !newMethod) return NO;
    
    class_addMethod(self,
                    originalSel,
                    class_getMethodImplementation(self, originalSel),
                    method_getTypeEncoding(originalMethod));
    class_addMethod(self,
                    newSel,
                    class_getMethodImplementation(self, newSel),
                    method_getTypeEncoding(newMethod));
    
    method_exchangeImplementations(class_getInstanceMethod(self, originalSel),
                                   class_getInstanceMethod(self, newSel));
    
    return YES;
}

+ (BOOL)ch_swizzleClassMethod:(SEL)originalSel withNewMethod:(SEL)newSel {
    Class class = object_getClass(self);
    Method originalMethod = class_getInstanceMethod(class, originalSel);
    Method newMethod = class_getInstanceMethod(class, newSel);
    if (!originalMethod || !newMethod) return NO;
    
    method_exchangeImplementations(originalMethod, newMethod);
    
    return YES;
}

BOOL CHNSObjectSwizzleInstanceMethodsWithNewMethodPrefix(Class aClass, SEL *selectors, NSString *newMethodPrefix) {
    if (!newMethodPrefix.length) return NO;
    
    int count = sizeof(selectors) / sizeof(SEL);
    if (!count) return NO;
    
    for (NSUInteger index = 0; index < count; index++) {
        SEL originalSelector = selectors[index];
        SEL swizzledSelector = NSSelectorFromString([newMethodPrefix stringByAppendingString:NSStringFromSelector(originalSelector)]);
        [aClass ch_swizzleInstanceMethod:originalSelector withNewMethod:swizzledSelector];
    }
    return YES;
}

BOOL CHNSObjectSwizzleClassMethodsWithNewMethodPrefix(Class aClass, SEL *selectors, NSString *newMethodPrefix) {
    if (!newMethodPrefix.length) return NO;
    
    int count = sizeof(selectors) / sizeof(SEL);
    if (!count) return NO;
    
    for (NSUInteger index = 0; index < count; index++) {
        SEL originalSelector = selectors[index];
        SEL swizzledSelector = NSSelectorFromString([newMethodPrefix stringByAppendingString:NSStringFromSelector(originalSelector)]);
        [aClass ch_swizzleClassMethod:originalSelector withNewMethod:swizzledSelector];
    }
    return YES;
}

@end
