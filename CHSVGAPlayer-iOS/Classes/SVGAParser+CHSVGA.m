//
//  SVGAParser+CHSVGA.m
//  CHSVGAPlayer-iOS
//
//  Created by CHwang on 2020/1/9.
//

#import "SVGAParser+CHSVGA.h"
#import "SVGAVideoEntity.h"
#import <CHCategories/NSObject+CHBase.h>

@interface SVGAParser ()

- (nonnull NSString *)cacheKey:(NSURL *)URL;

- (void)clearCache:(nonnull NSString *)cacheKey;

- (nullable NSString *)cacheDirectory:(NSString *)cacheKey;

- (void)parseWithCacheKey:(nonnull NSString *)cacheKey
          completionBlock:(void ( ^ _Nullable)(SVGAVideoEntity * _Nonnull videoItem))completionBlock
             failureBlock:(void ( ^ _Nullable)(NSError * _Nonnull error))failureBlock;

@end

@implementation SVGAParser (CHSVGA)

#pragma mark - Life cycle
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self jx_swizzleInstanceMethod:@selector(init) withNewMethod:@selector(_jx_svga_init)];
        [self jx_swizzleInstanceMethod:@selector(parseWithURLRequest:completionBlock:failureBlock:) withNewMethod:@selector(_jx_svga_parseWithURLRequest:completionBlock:failureBlock:)];
    });
}

#pragma mark - Swizzle methods
- (instancetype)_jx_svga_init {
    SVGAParser *instance = [self _jx_svga_init];
    instance.enabledMemoryCache = YES;
    return instance;
}

- (void)_jx_svga_parseWithURLRequest:(NSURLRequest *)URLRequest completionBlock:(void (^)(SVGAVideoEntity * _Nullable))completionBlock failureBlock:(void (^)(NSError * _Nullable))failureBlock {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self cacheDirectory:[self cacheKey:URLRequest.URL]]]) {
        [self parseWithCacheKey:[self cacheKey:URLRequest.URL] completionBlock:^(SVGAVideoEntity * _Nonnull videoItem) {
            if (completionBlock) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    completionBlock(videoItem);
                }];
            }
        } failureBlock:^(NSError * _Nonnull error) {
            [self clearCache:[self cacheKey:URLRequest.URL]];
            if (failureBlock) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    failureBlock(error);
                }];
            }
        }];
        return;
    }
    
    if (self.enabledMemoryCache) {
        SVGAVideoEntity *cacheItem = [SVGAVideoEntity readCache:[self cacheKey:URLRequest.URL]];
        if (cacheItem != nil) {
            if (completionBlock) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    completionBlock(cacheItem);
                }];
            }
            return;
        }
    }
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:URLRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil && data != nil) {
            [self parseWithData:data cacheKey:[self cacheKey:URLRequest.URL] completionBlock:^(SVGAVideoEntity * _Nonnull videoItem) {
                if (completionBlock) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        completionBlock(videoItem);
                    }];
                }
            } failureBlock:^(NSError * _Nonnull error) {
                [self clearCache:[self cacheKey:URLRequest.URL]];
                if (failureBlock) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        failureBlock(error);
                    }];
                }
            }];
        }
        else {
            if (failureBlock) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    failureBlock(error);
                }];
            }
        }
    }] resume];
}

@end
