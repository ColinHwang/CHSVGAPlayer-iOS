//
//  SVGAVideoEntity+CHSVGA.m
//  CHSVGAPlayer-iOS
//
//  Created by CHwang on 2020/1/9.
//

#import "SVGAVideoEntity+CHSVGA.h"
#import <CHCategories/NSObject+CHBase.h>
#import <YYCache/YYCache.h>

static YYCache *jxVideoCache;

@implementation SVGAVideoEntity (CHSVGA)

#pragma mark - Life cycle
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        jxVideoCache = [YYCache cacheWithName:@"JX_SVGA_CACHE"];
        [self chsvga_setupMemoryCacheCostLimit:10 * 1024];
    
        [self jx_swizzleClassMethod:@selector(readCache:) withNewMethod:@selector(_jx_svga_readCache:)];
        [self jx_swizzleInstanceMethod:@selector(saveCache:) withNewMethod:@selector(_jx_svga_saveCache:)];
    });
}

#pragma mark - Public methods

+ (void)chsvga_clearMemoryCache {
    [jxVideoCache.memoryCache removeAllObjects];
}

+ (void)chsvga_setupMemoryCacheCostLimit:(NSUInteger)costLimit {
    [jxVideoCache.memoryCache setCostLimit:costLimit];
}

#pragma mark - Swizzle methods
+ (SVGAVideoEntity *)_jx_svga_readCache:(NSString *)cacheKey {
    return (SVGAVideoEntity *)[jxVideoCache objectForKey:cacheKey];
}

- (void)_jx_svga_saveCache:(NSString *)cacheKey {
    [jxVideoCache setObject:self forKey:cacheKey];
}


@end
