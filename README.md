# CHSVGAPlayer-iOS

[![CI Status](https://img.shields.io/travis/ColinHwang/CHSVGAPlayer-iOS.svg?style=flat)](https://travis-ci.org/ColinHwang/CHSVGAPlayer-iOS)
[![Version](https://img.shields.io/cocoapods/v/CHSVGAPlayer-iOS.svg?style=flat)](https://cocoapods.org/pods/CHSVGAPlayer-iOS)
[![License](https://img.shields.io/cocoapods/l/CHSVGAPlayer-iOS.svg?style=flat)](https://cocoapods.org/pods/CHSVGAPlayer-iOS)
[![Platform](https://img.shields.io/cocoapods/p/CHSVGAPlayer-iOS.svg?style=flat)](https://cocoapods.org/pods/CHSVGAPlayer-iOS)

## 缘由

SVGAPlayer2.0缓存策略默认为NSURLCache+NSCache，缓存优先级上，NSURLCache > NSCache，这样会导致一些问题：

- NSURLCache的HTTP配置选项需符合要求：`如果服务器返回的头部信息包含 cache-control / etag / expired 这些键值，这个请求会被合理地缓存到本地`[https://github.com/yyued/SVGAPlayer-iOS/blob/master/readme.zh.md]，如不符合要求，则会重复进行下载，导致应用带宽被频繁占用。
- NSCache只支持内存缓存且不不支持手动清理缓存，无法适应需手动释放的业务场景。

## 解决方案

针对SVGA存在的问题，使用YYCache替代NSURLCache+NSCache，通过YYCache本身的二级缓存机制优化SVGAPlayer2.0缓存策略。

## 使用方案

- 移除SVGAPlayer组件

- 添加CHSVGAPlayer-iOS组件

```ruby
pod 'CHSVGAPlayer-iOS'
```

- 使用的地方导入

```
#import "SVGAVideoEntity+CHSVGA.h"

// 支持内存缓存, 默认为YES
- (SVGAParser *)parser {
    if (_parser == nil) {
        _parser = [[SVGAParser alloc] init];
        _parser.enabledMemoryCache = YES;
    }
    return _parser;
}

// 清除内存缓存
[SVGAVideoEntity chsvga_clearMemoryCache];

// 设置内存缓存最大值, 默认为10M
[SVGAVideoEntity chsvga_setupMemoryCacheCostLimit:10 * 1024]
```

## Author

ColinHwang, chwnag7158@gmail.com

## License

CHSVGAPlayer-iOS is available under the MIT license. See the LICENSE file for more info.
