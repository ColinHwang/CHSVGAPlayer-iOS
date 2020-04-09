//
//  SVGAVideoEntity+CHSVGA.m
//  CHSVGAPlayer-iOS
//
//  Created by CHwang on 2020/1/9.
//

#import "SVGAVideoEntity+CHSVGA.h"
#import <CHCategories/NSObject+CHBase.h>
#import <YYCache/YYCache.h>

static YYCache *chVideoCache;

@interface SVGAVideoEntity () <NSCoding>
@end

@implementation SVGAVideoEntity (CHSVGA)

#pragma mark - Life cycle
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        chVideoCache = [YYCache cacheWithName:@"CH_SVGA_CACHE"];
        [self chsvga_setupMemoryCacheCostLimit:10 * 1024];
    
        [self ch_swizzleClassMethod:@selector(readCache:) withNewMethod:@selector(_ch_svga_readCache:)];
        [self ch_swizzleInstanceMethod:@selector(saveCache:) withNewMethod:@selector(_ch_svga_saveCache:)];
    });
}

#pragma mark - Public methods
+ (void)chsvga_setupMemoryCacheCostLimit:(NSUInteger)costLimit {
    [chVideoCache.memoryCache setCostLimit:costLimit];
}

+ (void)chsvga_clearMemoryCache {
    [chVideoCache.memoryCache removeAllObjects];
}

+ (void)chsvga_removeCache:(NSString *)key {
    [chVideoCache removeObjectForKey:key];
}

#pragma mark - Swizzle methods
+ (SVGAVideoEntity *)_ch_svga_readCache:(NSString *)cacheKey {
    return (SVGAVideoEntity *)[chVideoCache objectForKey:cacheKey];
}

- (void)_ch_svga_saveCache:(NSString *)cacheKey {
    [chVideoCache setObject:self forKey:cacheKey];
}

@end
