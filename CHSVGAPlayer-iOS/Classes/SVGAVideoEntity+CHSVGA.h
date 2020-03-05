//
//  SVGAVideoEntity+CHSVGA.h
//  CHSVGAPlayer-iOS
//
//  Created by CHwang on 2020/1/9.
//

#import <SVGAPlayer/SVGA.h>

NS_ASSUME_NONNULL_BEGIN

@interface SVGAVideoEntity (CHSVGA)

/**
 设置缓存内存占用值, 默认为10M

 @param costLimit 内存占用值
*/
+ (void)chsvga_setupMemoryCacheCostLimit:(NSUInteger)costLimit;

/**
 清除内存中的缓存数据
*/
+ (void)chsvga_clearMemoryCache;

@end

NS_ASSUME_NONNULL_END
