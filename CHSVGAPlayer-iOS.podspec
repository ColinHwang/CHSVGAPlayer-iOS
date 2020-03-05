#
# Be sure to run `pod lib lint CHSVGAPlayer-iOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CHSVGAPlayer-iOS'
  s.version          = '0.0.1'
  s.summary          = '基于YYCache对SVGAPlayeri-iOS缓存策略的优化改造'
  s.homepage         = 'https://github.com/ColinHwang/CHSVGAPlayer-iOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ColinHwang' => 'chwnag7158@gmail.com' }
  s.source           = { :git => 'https://github.com/ColinHwang/CHSVGAPlayer-iOS.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'CHSVGAPlayer-iOS/Classes/**/*'
  s.requires_arc = true
  s.dependency 'YYCache'
  s.dependency 'SVGAPlayer', '~> 2.3'
  s.dependency 'CHCategories/Foundation/NSObject/NSObject+CHBase'
end
