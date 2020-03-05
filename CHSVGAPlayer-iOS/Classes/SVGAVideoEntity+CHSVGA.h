//
//  SVGAVideoEntity+CHSVGA.h
//  CHSVGAPlayer-iOS
//
//  Created by CHwang on 2020/1/9.
//

#import <SVGAPlayer/SVGA.h>

NS_ASSUME_NONNULL_BEGIN

@interface SVGAVideoEntity (CHSVGA)

+ (void)chsvga_setupMemoryCacheCostLimit:(NSUInteger)costLimit;

+ (void)chsvga_clearMemoryCache;

@end

NS_ASSUME_NONNULL_END
